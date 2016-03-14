function [out_header,out_data,message_string]=RLW_suppress_artifact_event(header,data,varargin);
%RLW_suppress_artifact_event
%
%Suppress artifact (event)
%
%varargin
%'xstart' (-0.005)
%'xend' (+0.005)
%'event_code'
%'interp_method' 'spline'
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

xstart=-0.005
xend=+0.005;
event_code='';
interp_method='spline';

%parse varagin
if isempty(varargin);
else
    %xstart
    a=find(strcmpi(varargin,'xstart'));
    if isempty(a);
    else
        xstart=varargin{a+1};
    end;
    %xend
    a=find(strcmpi(varargin,'xend'));
    if isempty(a);
    else
        xend=varargin{a+1};
    end;
    %event_code
    a=find(strcmpi(varargin,'event_code'));
    if isempty(a);
    else
        event_code=varargin{a+1};
    end;
    %interp_method
    a=find(strcmpi(varargin,'interp_method'));
    if isempty(a);
    else
        interp_method=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='suppress artifact (event).';

%prepare out_header
out_header=header;

%init out_data
out_data=data;

message_string{end+1}=['X1 = ' num2str(xstart) ' X2 = ' num2str(xend)];

%events
events=header.events;

%init xv, xi
for epochpos=1:header.datasize(1);
    idx(epochpos).xv=1:header.datasize(6);
    idx(epochpos).xi=[];
end;

%loop events
for eventpos=1:length(events);
    %event_code
    if isnumeric(events(eventpos).code);
        current_event_code=num2str(events(eventpos).code);
    else
        current_event_code=events(eventpos).code;
    end;
    %does event code match?
    if strcmpi(current_event_code,event_code);
        %epochpos
        epochpos=events(eventpos).epoch;
        %latency
        latency=events(eventpos).latency;
        %dx1,dx2
        dx1=fix((((latency+xstart)-header.xstart)/header.xstep)+1);
        dx2=fix((((latency+xend)-header.xstart)/header.xstep)+1);
        idx(epochpos).xi=[idx(epochpos).xi dx1:dx2];
    end;
end;

for epochpos=1:header.datasize(1);
    idx(epochpos).xv(idx(epochpos).xi)=[];
    for chanpos=1:header.datasize(2);
        for indexpos=1:header.datasize(3);
            for dz=1:header.datasize(4);
                for dy=1:header.datasize(5);                        
                    out_data(epochpos,chanpos,indexpos,dz,dy,:)=interp1(idx(epochpos).xv,squeeze(out_data(epochpos,chanpos,indexpos,dz,dy,idx(epochpos).xv)),1:header.datasize(6),interp_method);
                end;
            end;
        end;
    end;
end;



