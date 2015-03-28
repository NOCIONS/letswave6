function [out_header,out_data,message_string]=RLW_segmentation(header,data,event_labels,varargin);
%RLW_segmentation
%
%segment data
%
%%event_labels={$};
%
%varargin
%x_start=0;
%x_duration=1;
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

x_start=0;
x_duration=1;

%parse varagin
if isempty(varargin);
else
    %x_start
    a=find(strcmpi(varargin,'x_start'));
    if isempty(a);
    else
        x_start=varargin{a+1};
    end;
    %x_end
    a=find(strcmpi(varargin,'x_duration'));
    if isempty(a);
    else
        x_duration=varargin{a+1};
    end;
end;

%init message_string
message_string={};

%init out_header
out_header=header;

%init out_data
out_data=[];

%check that event_labels is not empty
if isempty(event_labels);
    message_string{1}='No event codes selected! Exit.';
    return;
end;

message_string{1}='Searching for matching events.';

%check for presence of events
if isfield(header,'events');
    if isempty(header.events);
        message_string{end+1}='No events in dataset.';
        return;
    end;
else
    message_string{end+1}='No events field in the dataset.';
    return;
end;

%init out_events
out_events=[];
event_idx=[];

%loop through header.events
for event_pos=1:size(header.events,2);
    %loop through event_labels
    for event_labels_pos=1:length(event_labels);
        %event_code
        event_code=event_labels{event_labels_pos};
        %find events matching event_code > event_idx
        if strcmpi(header.events(event_pos).code,event_code);
            event_idx=[event_idx,event_pos];
        end;
    end;
end;

%check if event_idx is empty
if isempty(event_idx);
    message_string{end+1}=[event_code ' : event code not found in dataset.'];
else
    %corresponding event_codes were found, so we proceed
    message_string{end+1}=[event_code ' : event code found in dataset.'];
    message_string{end+1}=[num2str(length(event_idx)) ' corresponding events found in dataset.'];
    %dxsize
    dxsize=fix((x_duration)/header.xstep);
    %adjust header
    %set datasize (number of epochs and xsize)
    out_header.datasize(1)=length(event_idx);
    out_header.datasize(6)=dxsize;
    %prepare out_data
    out_data=zeros(out_header.datasize);
    %initialize out_events
    k=1;
    out_events=out_header.events(1);
    %loop through events_idx
    for i=1:length(event_idx);
        %dx1
        dx1=fix((((header.events(event_idx(i)).latency+x_start)-header.xstart)/header.xstep))+1;
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
    
    %header.events
    out_header.events=out_events;
    
    %delete epochdata
    if isfield(out_header,'epochdata');
        rmfield(out_header,'epochdata');
    end;
    
    %adjust header.xstart
    out_header.xstart=x_start;
    
end;
    
    
   


    
    


