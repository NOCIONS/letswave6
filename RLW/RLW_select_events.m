function [out_header,out_data,message_string]=RLW_select_events(header,data,varargin);
%RLW_select_events
%
%Select events
%
%varargin
%
%'event_code'
%'minimum_latency' (0)
%'maximum_latency' (1)
%'check_minimum_latency' (1);
%'check_maximum_latency' (1);
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
minimum_latency=0;
maximum_latency=1;
check_minimum_latency=1;
check_maximum_latency=1;


%parse varagin
if isempty(varargin);
else
    %event_code
    a=find(strcmpi(varargin,'event_code'));
    if isempty(a);
    else
        event_code=varargin{a+1};
    end;
    %minimum_latency
    a=find(strcmpi(varargin,'minimum_latency'));
    if isempty(a);
    else
        minimum_latency=varargin{a+1};
    end;
    %maximum_latency
    a=find(strcmpi(varargin,'maximum_latency'));
    if isempty(a);
    else
        maximum_latency=varargin{a+1};
    end;
    %check_minimum_latency
    a=find(strcmpi(varargin,'check_minimum_latency'));
    if isempty(a);
    else
        check_minimum_latency=varargin{a+1};
    end;
    %check_maximum_latency
    a=find(strcmpi(varargin,'check_maximum_latency'));
    if isempty(a);
    else
        check_maximum_latency=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='Select epoch based on events.';

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
        %event_code is present at epochpos
        %now, check the latency of this/these event(s)
        final_test_flag=0;
        for i=1:length(a);
            test_flag=1;
            if (check_minimum_latency==1);
                if (event_latencies(a(i))<minimum_latency);
                    test_flag=0;
                end;
            end;
            if (check_maximum_latency==1);
                if (event_latencies(a(i))>maximum_latency);
                    test_flag=0;
                end;
            end;
            if test_flag==1;
                final_test_flag=1;
            end;
        end;
        if final_test_flag==1;
            ok_idx(ok_i)=epochpos;
            ok_i=ok_i+1;
        else
            ko_idx(ko_i)=epochpos;
            ko_i=ko_i+1;
        end;
    end;
end;

message_string{end+1}=['Found ' num2str(length(ok_idx)) ' epochs meeting criterion.'];

%data
out_data=data(ok_idx,:,:,:,:,:);

%adjust number of epochs
out_header.datasize(1)=length(ok_idx);

%fix events
if isfield(out_header,'events');
    events_to_delete=[];
    events=out_header.events;
    for i=1:length(events);
        a=find(ok_idx==events(i).epoch);
        if isempty(a);
            events_to_delete(end+1)=i;
        else
            events(i).epoch=a(1);
        end;
    end;
    events(events_to_delete)=[];
    out_header.events=events;
end

%adjust epoch_data
if isfield(header,'epochdata');
    out_header.epochdata=header.epochdata(ok_idx);
end;


