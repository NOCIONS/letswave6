function [out_header,out_data,message_string]=RLW_segmentation_SSEP(header,data,event_labels,varargin);
%RLW_segmentation_SSEP
%
%segment data (SS-EPs)
%
%
%event_labels={$};
%
%varargin
%
%'cycle_skip' (0)
%'cycle_total' (1)
%'cycle_frequency' (1)
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

cycle_skip=0;
cycle_total=1;
cycle_frequency=1;

%parse varagin
if isempty(varargin);
else
    %cycle_skip
    a=find(strcmpi(varargin,'cycle_skip'));
    if isempty(a);
    else
        cycle_skip=varargin{a+1};
    end;
    %cycle_total
    a=find(strcmpi(varargin,'cycle_total'));
    if isempty(a);
    else
        cycle_total=varargin{a+1};
    end;
    %cycle_frequency
    a=find(strcmpi(varargin,'cycle_frequency'));
    if isempty(a);
    else
        cycle_frequency=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='segmentation (SS-EPs)';

%init out_header
out_header=header;

%x_start
x_start=cycle_skip/cycle_frequency;

%x_duration
x_duration=(cycle_total-cycle_skip)/cycle_frequency

%return if no event_labels
if isempty(event_labels);
    message_string{end+1}='No event labels. Exit.';
    return;
end;

%check presence of events
out_events=[];
if isfield(header,'events');
else
    message_string{end+1}='No events. Exit.';
    return;
end;
if isempty(header.events);
    message_string{end+1}='No events. Exit.';
    return;
end;
    
%init out_events
%loop through event_labels > event_idx
for event_labels_pos=1:length(event_labels);
    event_code=event_labels{event_labels_pos};
    message_string{end+1}=['Searching for event : ' event_code];
    %find events matching event_code > event_idx
    event_idx=[];
    for event_pos=1:size(header.events,2);
        if strcmpi(header.events(event_pos).code,event_code);
            event_idx=[event_idx,event_pos];
        end;
    end;
end;

if isempty(event_idx);
    message_string{end+1}='Event code not found in dataset.';
else
    %corresponding event_codes were found, so we proceed
    message_string{end+1}=[num2str(length(event_idx)) ' corresponding events found in dataset.'];
    %adjust header
    %dxsize
    dxsize=round(((cycle_total-cycle_skip)/cycle_frequency)/header.xstep);
    %set datasize
    out_header.datasize(1)=length(event_idx);
    out_header.datasize(6)=dxsize;
    %prepare out_data
    out_data=zeros(out_header.datasize);
    %initialize out_events
    k=1;
    out_events=header.events(1);
    %loop through events_idx
    for i=1:length(event_idx);
        %dx1
        dx1=round((((header.events(event_idx(i)).latency+(cycle_skip/cycle_frequency))-header.xstart)/header.xstep))+1;
        %dx2
        dx2=(dx1+dxsize)-1;
        %out_data > epoch(i)
        out_data(i,:,:,:,:,:)=data(header.events(event_idx(i)).epoch,:,:,:,:,dx1:dx2);
        %scan for events within epoch
        for j=1:length(header.events);
            %check epoch
            if header.events(j).epoch==header.events(event_idx(i)).epoch;
                %new latency
                new_latency=header.events(j).latency-header.events(event_idx(i)).latency;
                %check if inside epoch limits
                if new_latency>=x_start;
                    if new_latency<=(x_start+x_duration);
                        %add event
                        out_events(k)=header.events(j);
                        out_events(k).latency=new_latency;
                        out_events(k).epoch=i;
                        k=k+1;
                    end;
                end;
            end;
        end;
    end;
end;

%header.events
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

    
    


