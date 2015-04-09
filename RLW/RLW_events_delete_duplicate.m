function [out_header,message_string]=RLW_events_delete_duplicate(header,varargin);
%RLW_events_delete_duplicate
%
%Delete duplicate events
%
%header
%
%varargin
%'exact_latencies' (1)
%'tolerance' (0.1)
%'verbose' (0)
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

exact_latencies=1;
tolerance=0.1;
verbose=0;

%parse varagin
if isempty(varargin);
else
    %exact_latencies
    a=find(strcmpi(varargin,'exact_latencies'));
    if isempty(a);
    else
        exact_latencies=varargin{a+1};
    end;
    %tolerance
    a=find(strcmpi(varargin,'tolerance'));
    if isempty(a);
    else
        tolerance=varargin{a+1};
    end;
    %verbose
    a=find(strcmpi(varargin,'verbose'));
    if isempty(a);
    else
        verbose=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='Delete duplicate events.';

if exact_latencies==1;
    message_string{1}='Finding events with identical latencies';
else
    message_string{1}='Finding events with similar latencies';
    message_string{1}=['Tolerance : ' num2str(configuration.parameters.tolerance)];
end;

%events
events=header.events;

%event_index
event_index=ones(length(events),1);

%out_header
out_header=header;

%loop through events
if length(events)>1;
    for eventpos=1:length(events);
        current_code=events(eventpos).code;
        current_latency=events(eventpos).latency;
        current_epoch=events(eventpos).epoch;
        event_list=1:length(events);
        event_list(eventpos)=[];
        for eventpos2=1:length(event_list);
            if strcmpi(events(event_list(eventpos2)).code,current_code);
                if events(event_list(eventpos2)).epoch==current_epoch;
                    if exact_latencies==1;
                        %exact latencies
                        if current_latency==events(event_list(eventpos2)).latency;
                            event_index(event_list(eventpos2))=0;
                            if verbose==1;
                                disp(['E ' num2str(eventpos) ' = E ' num2str(event_list(eventpos2))]);
                            end;
                        end;
                    else
                        %inexact latencies
                        if (abs(current_latency-events(event_list(eventpos2)).latency))<tolerance;
                            if current_latency>events(event_list(eventpos2)).latency
                                event_index(eventpos)=0;
                                if verbose==1;
                                    disp(['E ' num2str(eventpos) ' = E ' num2str(event_list(eventpos2))]);
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
    idx=find(event_index==0);
    if isempty(idx);
    else
        message_string{end+1}=['Found ' num2str(length(idx)) ' duplicate events.'];
        idx=find(event_index==1);
        out_header.events=events(idx);
    end;
end;


