function [regressor_header,regressor_data,peak_estimates,message_string]=RLW_single_trial_MLR(header,data,varargin);
%RLW_single_trial_MLR_distortion
%
%Single trial analyasis MLR with distortion
%
%varargin
%'selected_channel'
%'x_start'
%'x_end'
%'peak_definitions'
%
%
% Author : 
% Andre Mouraux
% Institute of Neurosciences (IONS)
% Universite catholique de louvain (UCL)
% Belgium
% 
% Contact : andre.mouraux@uclouvain.be
% This function is part of Letswave 6
% See http://nocions.webnode.com/letswave for additional information
%

selected_channel='Cz';
x_start=0;
x_end=0.5,
peak_definitions=[];
peak_estimates=[];

%parse varagin
if isempty(varargin);
else
    %selected_channel
    a=find(strcmpi(varargin,'selected_channel'));
    if isempty(a);
    else
        selected_channel=varargin{a+1};
    end;
    %x_start
    a=find(strcmpi(varargin,'x_start'));
    if isempty(a);
    else
        x_start=varargin{a+1};
    end;
    %x_end
    a=find(strcmpi(varargin,'x_end'));
    if isempty(a);
    else
        x_end=varargin{a+1};
    end;
    %peak_definitions
    a=find(strcmpi(varargin,'peak_definitions'));
    if isempty(a);
    else
        peak_definitions=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='MLR with distortion';


%check that there are peak_definitions
if isempty(peak_definitions);
    message_string{end+1}='No peak definitions defined. Exit!';
    return;
end;

%time_interval : time interval to be analyzed, in seconds (e.g. [0 0.5])
time_interval=[x_start x_end];
message_string{end+1}=['Analysed time interval : ' num2str(time_interval(1)) ' - ' num2str(time_interval(2))];

%peak_interval : the time intervals of all peaks, in seconds (e.g. [0.15 0.25; 0.25 0.35])
%direction : positive or negative (e.g. {'negative','positive'})
for peak_pos=1:length(peak_definitions);
    peak_interval(peak_pos,1)=peak_definitions(peak_pos).x_start;
    peak_interval(peak_pos,2)=peak_definitions(peak_pos).x_end;
    direction{peak_pos}=peak_definitions(peak_pos).polarity;
end;
for peak_pos=1:length(peak_definitions);
    message_string{end+1}=['Peak ' num2str(peak_pos) ' : ' num2str(peak_interval(peak_pos,1)) ' - ' num2str(peak_interval(peak_pos,2)) ' ' direction{peak_pos}];
end;

%num_peak
num_peak=length(peak_definitions);

%ST
ST.interval=time_interval;
ST.peak_interval=peak_interval;

%data > epoch
epoch=1:1:header.datasize(6);
epoch=(((epoch-1)*header.xstep)+header.xstart);

%channel_idx
for i=1:length(header.chanlocs);
    st{i}=header.chanlocs(i).labels;
end;
a=find(strcmpi(selected_channel,st));
if isempty(a);
    message_string{end+1}='Selected channel not found in dataset. Exit.';
    return;
else
    channel_idx=a(1);
end;

%t_idx
t_idx=find(epoch>=ST.interval(1) & epoch<=ST.interval(2));

%signal
signal=squeeze(data(:,channel_idx,1,1,1,:));
avg=mean(signal,1);

[tmax tmin vmax vmin]=extreme_point(avg);
for i=1:num_peak
    if strcmp(direction{i},'positive')
        peak_time=epoch(tmax);
        peak_time_c=peak_time(find(peak_time>=peak_interval(i,1) & peak_time<=peak_interval(i,2)));
        if isempty(peak_time_c)
            message_string{end+1}='No positive peak in the pre-defined time interval. Exit.';
            return;
        else
            for j=1:length(peak_time_c)
                peak_time_idx(j)=find(epoch==peak_time_c(j));
            end
            Vmax=max(avg(peak_time_idx));
            Tmax=epoch(find(avg==Vmax));
        end
        ST.peak(i,:)=[Tmax Vmax];
    elseif strcmp(direction{i},'negative')
        peak_time=epoch(tmin);
        peak_time_c=peak_time(find(peak_time>=peak_interval(i,1) & peak_time<=peak_interval(i,2)));
        if isempty(peak_time_c)
            message_string{end+1}='No negative peak in the pre-defined time interval. Exit.';
            return;
        else
            for j=1:length(peak_time_c)
                peak_time_idx(j)=find(epoch==peak_time_c(j));
            end
            Vmin=min(avg(peak_time_idx));
            Tmin=epoch(find(avg==Vmin));
        end
        ST.peak(i,:)=[Tmin Vmin];
    end
end

%transfer all to ST
ST.epoch=epoch;
ST.t_idx=t_idx;
ST.channel_idx=channel_idx;

%MLR
[ST]=MLR_regressors(avg,ST);

%Fs
Fs=round(1/header.xstep);

%measure peaks
[ST] = peak_measure(signal,ST,Fs);

%tpx
tpx=1:1:header.datasize(6);
tpx=((tpx-1)*header.xstep)+header.xstart;

%regressor header
regressor_header=header;
regressor_header.datasize=[1 1 1+(length(ST.regressor)*2) 1 1 length(ST.t_idx)];
regressor_header.xstart=tpx(ST.t_idx(1));
regressor_header.xstep=tpx(ST.t_idx(2))-tpx(ST.t_idx(1));
regressor_header.chanlocs=regressor_header.chanlocs(ST.channel_idx);

%delete events
if isfield(regressor_header,'events');
    regressor_header.events=[];
end;

%delete epochdata
if isfield(regressor_header,'epochdata');
    regressor_header.epochdata=[];
end;

%index labels
regressor_header.indexlabels{1}='original';
for i=1:length(ST.regressor);
    regressor_header.indexlabels{2+((i-1)*2)}=['peak' num2str(i) '_1'];
    regressor_header.indexlabels{3+((i-1*2))}=['peak' num2str(i) '_2'];
end;

%regressor data
regressor_data=zeros(regressor_header.datasize);
regressor_data(1,1,1,1,1,:)=mean(data(:,ST.channel_idx,1,1,1,ST.t_idx),1);
for i=1:length(ST.regressor);
    regressor_data(1,1,2+((i-1)*2),1,1,:)=ST.regressor{i}(:,1);
    regressor_data(1,1,3+((i-1)*2)+1,1,1,:)=ST.regressor{i}(:,2);
end;

%add single-trial estimates to configuration
for i=1:length(ST.regressor);
    peak_estimates(i).latencies=ST.latency(:,i);
    peak_estimates(i).amplitudes=ST.amplitude(:,i);
end;

