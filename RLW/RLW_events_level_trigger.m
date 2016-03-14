function [out_header,message_string]=RLW_events_level_trigger(header,data,selected_channel,varargin);
%RLW_events_level_trigger
%
%Events level trigger
%
%header,data
%selected_channel : label of selected_channel
%
%varargin
%
%'threshold=1000;
%'min_isi=1;
%'direction' 'ascending' 'descending'
%'event_code' ('trig')
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

threshold=1000;
min_isi=1;
direction='ascending';
event_code='trig';

%parse varagin
if isempty(varargin);
else
    %threshold
    a=find(strcmpi(varargin,'threshold'));
    if isempty(a);
    else
        threshold=varargin{a+1};
    end;
    %min_isi
    a=find(strcmpi(varargin,'min_isi'));
    if isempty(a);
    else
        min_isi=varargin{a+1};
    end;
    %direction
    a=find(strcmpi(varargin,'direction'));
    if isempty(a);
    else
        direction=varargin{a+1};
    end;
    %event_code
    a=find(strcmpi(varargin,'event_code'));
    if isempty(a);
    else
        event_code=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='Events level trigger.';

%prepare out_header
out_header=header;

%channel_labels
channel_labels={};
for i=1:length(header.chanlocs);
    channel_labels{i}=header.chanlocs(i).labels;
end;
           
%chanpos
chanpos=find(strcmpi(selected_channel,channel_labels));
if isempty(chanpos);
    message_string{end+1}='Channel label not found.';
    return;
end;
message_string{end+1}=['Selected channel position : ' num2str(chanpos)];


%ltp
ltp=1:1:header.datasize(6);
ltp=((ltp-1)*header.xstep)+header.xstart;

%loop through epochs
for epochpos=1:header.datasize(1);
    tp=squeeze(data(epochpos,chanpos,1,1,1,:));
    switch direction
        case 'ascending'
            f=find(tp>threshold);
        case 'descending'
            f=find(tp<threshold);
    end;
    if isempty(f);
        message_string{end+1}='No triggers found : exit.';
        return;
    end;
    fltp=ltp(f);
    fltp_diff=zeros(size(fltp))+min_isi;
    for k=2:length(fltp);
        fltp_diff(k)=fltp(k)-fltp(k-1);
    end;
    fltp(find(fltp_diff<min_isi))=[];
    message_string{end+1}=['Number of triggers found : ' num2str(length(fltp))];
    for k=1:length(fltp);
        %eventpos
        if isempty(out_header.events);
            eventpos=1;
        else
            eventpos=length(out_header.events)+1;
        end;
        %add event
        out_header.events(eventpos).code=event_code;
        out_header.events(eventpos).latency=fltp(k);
        out_header.events(eventpos).epoch=epochpos;
    end;
end;


