function [out_header,out_data]=LW_warping_angular_correction(header,data,varargin);

event_code={'s1'};
f0=[];
steps=2;
hierarchy=0;

%parse varagin
if isempty(varargin);
else
    %event_code
    a=find(strcmpi(varargin,'event_code'));
    if isempty(a);
    else
        event_code=varargin{a+1};
    end;
    %f0
    a=find(strcmpi(varargin,'f0'));
    if isempty(a);
    else
        f0=varargin{a+1};
    end;
    %steps
    a=find(strcmpi(varargin,'steps'));
    if isempty(a);
    else
        steps=varargin{a+1};
    end;
end;

epoch_num       = size(data,1);
data_length     = size(data,6);
Fs              = header.xstep;
t               = header.xstart+(Fs:Fs:Fs*data_length);



   
%% get latencies info
% get the event latencies for every code separately
for Evevent_code=1:length(event_code)
    events = cell(epoch_num,1);
    for k=1:length(header.events)
        if strcmp(header.events(k).code,event_code{Evevent_code})
            events{header.events(k).epoch} = [events{header.events(k).epoch},header.events(k).latency];
        end
    end
    if length(event_code)>1
        eval(sprintf('%s',['[events_' char(event_code{Evevent_code}) '] = events;']));
    end
end
% Concatenate the events (case of multiple event_codes, hierarchy 0)
if length(event_code)==2 && hierarchy==0
    events=cell(epoch_num,1);
    for epoch_n=1:epoch_num
        eval(sprintf('%s',['events{epoch_n}=sort([events_' char(event_code{1}) '{epoch_n}, events_' char(event_code{2}) '{epoch_n}]);']));
    end
elseif length(event_code)>2
    display ('to be coded: concatenating n arrays');
end

%% eventually, determine f0. Could be done otherwise (maximum of likelyhood for R strength, as discussed during lab meeting)
if isempty(f0)
    diffs=[];
    for epoch_n=1:epoch_num
        diffs=sort([diffs diff(events{epoch_n})]);
    end
    figure;
    qqplot(diffs);
    p0=median(diffs);
else
    p0=1/f0;
end;
    
%% angular conversion and data visualization (part1)
events_rad=cell(epoch_num,1);
all_events_rad=[];% NaN(1,sum(cellfun('length',events))); for pre-allocation
figure;
for epoch_n=1:epoch_num
    % angular conversion
    events_rad{epoch_n} = 2*pi*(events{epoch_n}/p0); % convert the time values in angular values
    % data visualization (circular plots)
    subplot(4,epoch_num+1,epoch_n); % (1)before timewarping(angular)(2)before timewarping(time)(3)aftertimewarping(angular)(4)atertimewrapping (time)
    circ_plot(events_rad{epoch_n}','pretty','ro',true,'linewidth',2,'color','r');
    % stats
    all_events_rad=[all_events_rad events_rad{epoch_n}]; % for stats across the trials
    % all_events_rad(i:i+length(events_rad{epoch_num}))=events_rad{epoch_num};
    stats.R_signif(epoch_n)=circ_rtest(events_rad{epoch_n}); if stats.R_signif(epoch_n)>0.05; display(['non periodic data, epoch : ' num2str(epoch_n)]); end        % Rayleigh test (H0= circular uniformity) REM: should use a testwith no assumption of von Mises distribution!
    stats.R_theta(epoch_n)=circ_rad2ang(circ_mean(events_rad{epoch_n}'));% synchronization accuracy
    stats.R_strength(epoch_n)=circ_r(events_rad{epoch_n}');% synchronization consistency
end
subplot (4,epoch_num+1,epoch_n+1)
circ_plot(all_events_rad','hist',[],20,true,true,'linewidth',2,'color','r');
stats.All.R_signif=circ_rtest(all_events_rad');
stats.All.R_theta=circ_rad2ang(circ_mean(all_events_rad'));
stats.All.R_median=circ_rad2ang(circ_median(all_events_rad'));
stats.All.R_strength=circ_r(all_events_rad');
stats.All.R_std=circ_rad2ang(circ_std(all_events_rad'));
    
%% angular correction and data visualization (part2)
% targets determination (according to number of steps)
target = NaN(1,steps);
for s=1:steps
    target(1,s)=circ_mean(all_events_rad')+(s-1)*2*pi/steps;
end
subplot (4,epoch_num+1,2*(epoch_num+1));
circ_plot(target','pretty','ro',true,'linewidth',2,'color','r');
% prepare the outputs of the for epochs loop
events_rad_corrected=cell(epoch_num,1);
events_corrected=cell(epoch_num,1); %time (s)
all_events_rad_corrected=[];% NaN(size(all_events_rad)); for pre-allocation
stats.jitter_time=cell(epoch_num,1); % can be usefull for quantification of correction (even if redundant with R strength)
for epoch_n=1:epoch_num
    % jitter computation
    sins=sin(events_rad{epoch_n}); coss=cos(events_rad{epoch_n});
    rads=atan2(sins,coss); % four-quadrant inverse tangent to get angular value of each event independant of its n
    jitter_rad_steps = NaN(steps,length(rads));
    for s=1:steps
        jitter_rad_steps(s,:)=target(1,s)-rads;
    end
    [~,step_idx]=min(abs(jitter_rad_steps)); % raw index of step that is closest to event
    jitter_rad = NaN(1,length(rads));
    for s=1:steps
        [~,s_idx]=find(step_idx==s);
        jitter_rad(1,s_idx)=jitter_rad_steps(s,s_idx);
    end
    % data visualization (event's jitter)
    stats.jitter_time{epoch_n}=p0*jitter_rad/2/pi;
    subplot(4,epoch_num+1,epoch_n+epoch_num+1);
    plot(stats.jitter_time{epoch_n}); 
    axis([0 length(stats.jitter_time{epoch_n})+1 min(stats.jitter_time{epoch_n}) max(stats.jitter_time{epoch_n})]);
    % correction
    events_rad_corrected{epoch_n}=events_rad{epoch_n}+jitter_rad;
    
    
    events_corrected{epoch_n} = p0*events_rad_corrected{epoch_n}/2/pi; % transform angular values in time values
    % for stats
    all_events_rad_corrected=[all_events_rad_corrected events_rad_corrected{epoch_n}];
    % data visualization (corrected circular plots)
    subplot(4,epoch_num+1,epoch_n+2*epoch_num+2);
    circ_plot(events_rad_corrected{epoch_n}', 'pretty','ro',true,'linewidth',2,'color','r');
    % data visualization (corrected event's jitter)
    sinsc=sin(events_rad_corrected{epoch_n}); cossc=cos(events_rad_corrected{epoch_n}); radsc=atan2(sinsc,cossc); % four-quadrant inverse tangent to get angular value of each event independant of its n
    jitter_rad_corrected=target(1,1)-radsc;
    jitter_time_corrected=p0*jitter_rad_corrected/2/pi;
    subplot(4,epoch_num+1,3*(epoch_num+1)+epoch_n);
    plot(jitter_time_corrected); axis([0 length(jitter_time_corrected)+1 min(stats.jitter_time{epoch_n}) max(stats.jitter_time{epoch_n})]);
end
subplot(4,epoch_num+1,3*epoch_num+3);
circ_plot(all_events_rad_corrected','hist',[],20,true,true,'linewidth',2,'color','r');
% stats
stats.corr.R_signif=circ_rtest(all_events_rad_corrected');
stats.corr.R_theta=circ_rad2ang(circ_mean(all_events_rad_corrected'));
stats.corr.R_median=circ_rad2ang(circ_median(all_events_rad_corrected'));
stats.corr.R_strength=circ_r(all_events_rad_corrected');
stats.corr.R_std=circ_rad2ang(circ_std(all_events_rad_corrected'));


%% user input
a=questdlg('Apply time warp?','Save','Yes','No','Yes');
if strcmpi(a,'Yes');
    %% time wrapping
    events_wrap=header.events(1);
    events_wrap.code='wrapped';
    out_data=zeros(size(data));
    for epoch_n=1:epoch_num
        x=[t(1),events_corrected{epoch_n}(1:end),t(end)];
        if length(x)~=length(unique(x))
            warning('multiple events for at least one IOI in epoch')
            disp(epoch_n)
            warning('Try increasing the amount of "steps".')
            % it's true that there could be two events corresponding to one
            % direction. If this happens, the linear interpolation won't
            % work. Default suggestion: keep the warning, but erease one of
            % the duplicate event? Or rather, keep the warning and let the
            % error occur?
            continue
        end
        y=[t(1),events{epoch_n}(1:end),t(end)];
        events_wrap.epoch=epoch_n;
        for event_n=1:length(events{epoch_n})
            events_wrap.latency=events{epoch_n}(1)+p0/length(event_code)*(event_n-1);
            header.events(end+1)=events_wrap;
        end
        t1=interp1(x,y,t);
        out_data(epoch_n,:,:,:,:,:)=interp1(t,squeeze(data(epoch_n,:,:,:,:,:))',t1)';
    end
    
    out_header=header;
else
    out_header=[];
    out_data=[];
end;

    
