function [out_header,out_data,message_string]=RLW_CWT(header,data,varargin);
%RLW_CWT
%
%Continuous Wavelet Transform
%
%varargin
%
%'wavelet_name ('cmor1-1.5') 'cmor1-1.5','cmor1-1','cmor1-0.5','cmor1-0.1','fbsp1-1-1.5','fbsp1-1-1','fbsp1-1-0.5','fbsp2-1-1','fbsp2-1-0.5','fbsp2-1-0.1','shan1-1.5','shan1-1','shan1-0.5','shan1-0.1','shan2-3','cgau1','cgau2','cgau3','cgau4','cgau5'
%'low_frequency (1)
%'high_frequency (30)
%'num_frequency_lines (100)
%'segment_data (0)
%'event_name ([])
%'x_start (-0.5)
%'x_end (1)
%'output ('amplitude') 'amplitude','power','phase','complex'
%'average_epochs (1)
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

wavelet_name='morlet';
low_frequency=1;
high_frequency=30;
num_frequency_lines=100;
segment_data=0;
event_name=[];
x_start=-0.5;
x_end=1;
output='amplitude';
average_epochs=1;


%parse varagin
if isempty(varargin);
else
    %wavelet_name
    a=find(strcmpi(varargin,'wavelet_name'));
    if isempty(a);
    else
        wavelet_name=varargin{a+1};
    end;
    %low_frequency
    a=find(strcmpi(varargin,'low_frequency'));
    if isempty(a);
    else
        low_frequency=varargin{a+1};
    end;
    %high_frequency
    a=find(strcmpi(varargin,'high_frequency'));
    if isempty(a);
    else
        high_frequency=varargin{a+1};
    end;
    %num_frequency_lines
    a=find(strcmpi(varargin,'num_frequency_lines'));
    if isempty(a);
    else
        num_frequency_lines=varargin{a+1};
    end;
    %segment_data
    a=find(strcmpi(varargin,'segment_data'));
    if isempty(a);
    else
        segment_data=varargin{a+1};
    end;
    %event_name
    a=find(strcmpi(varargin,'event_name'));
    if isempty(a);
    else
        event_name=varargin{a+1};
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
    %output
    a=find(strcmpi(varargin,'output'));
    if isempty(a);
    else
        output=varargin{a+1};
    end;
    %average_epochs
    a=find(strcmpi(varargin,'average_epochs'));
    if isempty(a);
    else
        average_epochs=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='CWT';

%prepare out_header
out_header=header;

%freq_step
freq_step=(high_frequency-low_frequency)/num_frequency_lines;

%update file type
%'amplitude','power','phase','complex'
switch output;
    case 'amplitude'
        out_header.filetype='frequency_time_amplitude';
    case 'power'
        out_header.filetype='frequency_time_power';
    case 'phase'
        out_header.filetype='frequency_time_phase';
    case 'complex'
        out_header.filetype='frequency_time_complex';
end;

%update header ysize
out_header.datasize(5)=num_frequency_lines;

%update header YStep and YStart
out_header.ystep=freq_step;
out_header.ystart=low_frequency;

%central frequency of chosen mother wavelet
central_freq=centfrq(wavelet_name);

%frequencies
frequencies=1:1:num_frequency_lines;
frequencies=low_frequency+((frequencies-1)*freq_step);

%scales
scales=(central_freq/header.xstep)./frequencies;

%prepare outdata
out_data=zeros(out_header.datasize);

%loop through all the data
dz=1;
dy=1;
for epochpos=1:header.datasize(1);
    for channelpos=1:header.datasize(2);
        for indexpos=1:header.datasize(3);
            disp(['E:',num2str(epochpos),' C:',num2str(channelpos),' I:',num2str(indexpos)]);
            switch output;
                case 'amplitude'
                    out_data(epochpos,channelpos,indexpos,dz,:,:)=abs(cwt(squeeze(data(epochpos,channelpos,indexpos,dz,dy,:)),scales,wavelet_name));
                case 'power'
                    out_data(epochpos,channelpos,indexpos,dz,:,:)=abs(cwt(squeeze(data(epochpos,channelpos,indexpos,dz,dy,:)),scales,wavelet_name)).^2;
                case 'phase'
                    out_data(epochpos,channelpos,indexpos,dz,:,:)=angle(cwt(squeeze(data(epochpos,channelpos,indexpos,dz,dy,:)),scales,wavelet_name));
                case 'complex'
                    out_data(epochpos,channelpos,indexpos,dz,:,:)=cwt(squeeze(data(epochpos,channelpos,indexpos,dz,dy,:)),scales,wavelet_name);
            end;
        end;
    end;
end;
            
%segment if checked
if segment_data==1;
    k=1;
    message_string{end+1}='Attempting to segment the data.';
    event_idx=[];
    if isfield(out_header,'events');
        if isempty(out_header.events);
            message_string{end+1}='Event field of dataset is empty! Skipping segmentation.';
        else
            %event_name
            event_name=event_name;
            message_string{end+1}='Segmenting continuous data into epochs.';
            message_string{end+1}=['Searching for event : ' event_name];
            %event_string, event_latency
            for i=1:length(out_header.events);
                event_string{i}=out_header.events(i).code;
            end;
            %find event_name in event_string
            a=find(strcmpi(event_name,event_string));
            if isempty(a);
                event_idx=[];
            else
                event_idx=a;
            end;
        end;
    else
        message_string{end+1}='No event field in the dataset! Skipping segmentation.';
    end;
    if isempty(event_idx);
        message_string{end+1}='No events found, saving continuous data.';
    else
        %corresponding events were found, so, we proceed
        message_string{end+1}=[num2str(length(event_idx)) ' corresponding events found in dataset.'];
        %adjust header
        %dxsize
        dxsize=fix((x_end-x_start)/out_header.xstep)+1;
        %set datasize
        out_header.datasize(1)=length(event_idx);
        out_header.datasize(6)=dxsize;
        %prepare out_data
        data=out_data;
        out_data=zeros(out_header.datasize);
        %initialize out_events
        k=1;
        out_events=out_header.events(1);
        %loop through events_latencies
        for i=1:length(event_idx);
            %dx1
            dx1=fix((((out_header.events(event_idx(i)).latency+x_start)-out_header.xstart)/out_header.xstep))+1;
            %dx2
            dx2=(dx1+dxsize)-1;
            %out_data > epoch(i)
            out_data(i,:,:,:,:,:)=data(out_header.events(event_idx(i)).epoch,:,:,:,:,dx1:dx2);
            %scan for events within epoch
            for j=1:length(out_header.events);
                %check epoch
                if out_header.events(j).epoch==out_header.events(event_idx(i)).epoch;
                    %new latency
                    new_latency=out_header.events(j).latency-out_header.events(event_idx(i)).latency;
                    %check if inside epoch limits
                    if new_latency>=x_start;
                        if new_latency<=(x_end);
                            %add event
                            out_events(k)=out_header.events(j);
                            out_events(k).latency=new_latency;
                            out_events(k).epoch=i;
                            k=k+1;
                        end;
                    end;
                end;
            end;
        end;
    end;
    %out_header.events
    if k==1;
        out_events=[];
    end;
    out_header.events=out_events;
    %delete epochdata
    if isfield(out_header,'epochdata');
        rmfield(out_header,'epochdata');
    end;
    %adjust header.xstart
    out_header.xstart=x_start;
end;
            
%average?
if average_epochs==1;
    message_string{end+1}='Averaging epochs';
    %change number of epochs to 1
    out_header.datasize(1)=1;
    %PLV?
    if strcmpi(output,'phase');
        %PLV
        message_string{end+1}='Average phase values selected.';
        message_string{end+1}='Will compute the Phase Locking Value (PLV).';
        %compute PLV
        x=sum(sin(out_data),1);
        y=sum(cos(out_data),1);
        out_data=sqrt(x.^2+y.^2);
        out_data=out_data/header.datasize(1);
    else
        %standard average
        out_data=mean(out_data,1);
    end;
    %adjust events
    if isfield(out_header,'events');
        for event_pos=1:length(out_header.events);
            out_header.events(event_pos).epoch=1;
        end;
    end;
    %delete epochdata
    if isfield(out_header,'epochdata');
        rmfield(out_header,'epochdata');
    end;
end;




