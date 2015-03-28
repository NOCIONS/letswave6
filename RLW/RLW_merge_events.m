function [out_header,message_string]=RLW_merge_events(header,event1_code,event2_code,varargin);
%RLW_merge_events
%
%Merge events
%
%header
%event1_code
%event2_code
%
%varargin
%'event2_min_latency_diff' (-0.1);
%'event2_max_latency_diff' (+0.1);
%
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

event2_min_latency_diff=-0.1;
event2_max_latency_diff=+0.1;

%parse varagin
if isempty(varargin);
else
    %event2_min_latency_diff
    a=find(strcmpi(varargin,'event2_min_latency_diff'));
    if isempty(a);
    else
        event2_min_latency_diff=varargin{a+1};
    end;
    %event2_max_latency_diff
    a=find(strcmpi(varargin,'event2_max_latency_diff'));
    if isempty(a);
    else
        event2_max_latency_diff=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='Merge event codes/latencies.';

%find event1, event2
st={};
for i=1:length(header.events);
    st{i}=header.events(i).code;
end;
event1_idx=find(strcmpi(st,event1_code)==1);
event2_idx=find(strcmpi(st,event2_code)==1);

%event1 found?
if isempty(event1_idx);
    message_string{end+1}='No events corresponding to EVENT1 were found. Exit.';
    return;
end;

%event2 found?
if isempty(event2_idx);
    message_string{end+1}='No events corresponding to EVENT2 were found. Exit.';
    return;
end;

%initialize new_events
new_event=header.events(1);
new_events=new_event;
k=1;

%loop through event1
for i=1:length(event1_idx);
    
    %event1
    event1=header.events(event1_idx(i));
    
    %loop through event2 (and check if latency satisfied condition
    for j=1:length(event2_idx);
        
        %event2
        event2=header.events(event2_idx(j));
        
        %compare latencies : latency_diff
        latency_diff=event2.latency-event1.latency;
        
        %if event1.epoch==event2.epoch
        if event1.epoch==event2.epoch;
            
            %is latency_diff < max_latency_diff?
            if latency_diff<event2_max_latency_diff;
                
                %is latency_diff > min_latency_diff?
                if latency_diff>event2_min_latency_diff;
                    
                    %new_event
                    new_event.code=[event1.code '_' event2.code];
                    new_event.latency=event1.latency;
                    new_event.epoch=event1.epoch;
                    
                    %new_events
                    new_events(k)=new_event;
                    k=k+1;
                end;
            end;
        end;
    end;
end;

%out_header
out_header=header;

%are there new events?
if k>1;
    %merge header.events and new_events
    out_header.events=[header.events new_events];
end;





