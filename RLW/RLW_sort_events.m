function [out_header,out_data,message_string]=RLW_sort_events(header,data,varargin);
%RLW_sort_epochdata
%
%Sort epochdata
%
%varargin
%'event_code'
%'sort_direction' ('ascend')
%'discard_empty' (1)
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

event_code='';
sort_direction='ascend'
discard_empty=1;

%parse varagin
if isempty(varargin);
else
    %event_code
    a=find(strcmpi(varargin,'event_code'));
    if isempty(a);
    else
        event_code=varargin{a+1};
    end;
    %sort
    a=find(strcmpi(varargin,'sort'));
    if isempty(a);
    else
        sort_direction=varargin{a+1};
    end;
    %discard_empty
    a=find(strcmpi(varargin,'discard_empty'));
    if isempty(a);
    else
        discard_empty=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='Sort events.';

%prepare out_header
out_header=header;

%events?
if isfield(header,'events');
else
    message_string{end+1}='No events available. Exit.';
    return;
end;
if isempty(header.events);
    message_string{end+1}='No events available. Exit.';
    return;
end;

%convert events structure to vectors event_codes, event_epochs and event_latencies
events=header.events;
for i=1:length(header.events);
    event_codes{i}=header.events(i).code;
    event_epochs(i)=header.events(i).epoch;
    event_latencies(i)=header.events(i).latency;
end;

%within these events, find events with corresponding event_code
a=find(strcmpi(event_codes,event_code));
if isempty(a);
    message_string{end+1}='No events with corresponding event code. Exit.';
    return;
end;

event_codes=event_codes(a);
event_epochs=event_epochs(a);
event_latencies=event_latencies(a);

%initialize ok_idx and ko_idx
ok_i=1;
ko_i=1;
ok_idx=[];
ok_latency=[];
ko_idx=[];

%find epochs with corresponding event_code
for epochpos=1:header.datasize(1);
    %find events with corresponding epochpos
    a=find(event_epochs==epochpos);
    %ok or ko?
    if isempty(a);
        ko_idx(ko_i)=epochpos;
        ko_i=ko_i+1;
    else
        ok_idx(ok_i)=epochpos;
        ok_latency(ok_i)=event_latencies(a(1));
        ok_i=ok_i+1;
    end;
end;

%sort ok_idx according to ok_latency
if isempty(ok_latency);
else
    [a,b]=sort(ok_latency,2,sort_direction);
    ok_latency=ok_latency(b);
    ok_idx=ok_idx(b);
    message_string{end+1}=['Sort order : ' num2str(ok_idx)];
end;

%append other (discarded) epochs?
if isempty(ko_idx);
else
    if discard_empty==0;
        %sort discarded epochs in ascending order
        %this is probably not needed.
        ko_idx=sort_direction(ko_idx);
        ok_idx=[ok_idx ko_idx];
        message_string{end+1}=['Appending discarded epochs : ' num2str(ko_idx)];
    end;
end;

%data
out_data=data(ok_idx,:,:,:,:,:);

%adjust number of epochs
out_header.datasize(1)=length(ok_idx);

%adjust events
if isfield(header,'events');
    if isempty(header.events);
    else
        for i=1:length(header.events);
            event_epoch_idx(i)=header.events(i).epoch;
        end;
        new_events=[];
        for i=1:length(ok_idx);
            a=find(event_epoch_idx==ok_idx(i));
            if isempty(a);
            else
                tp=header.events(a);
                for i=1:length(tp);
                    tp(i).epoch=i;
                end;
                new_events=[new_events tp];
            end;
        end;
        out_header.events=new_events;
    end;
end;

%adjust epoch_data
if isfield(header,'epochdata');
    out_header.epochdata=header.epochdata(ok_idx);
end;







