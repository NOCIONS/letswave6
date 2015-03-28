function [out_header,out_data,message_string]=RLW_segmentation_chunk(header,data,event_labels,varargin);
%RLW_segmentation_chunk
%
%segment data (chunk)
%
%%event_labels={$};
%
%varargin
%'chunk_onset' (0)          
%'chunk_duration' (1)
%'chunk_interval' (1)
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

chunk_onset=0;
chunk_duration=1;
chunk_interval=1;

%parse varagin
if isempty(varargin);
else
    %chunk_onset
    a=find(strcmpi(varargin,'chunk_onset'));
    if isempty(a);
    else
        chunk_onset=varargin{a+1};
    end;
    %chunk_duration
    a=find(strcmpi(varargin,'chunk_duration'));
    if isempty(a);
    else
        chunk_duration=varargin{a+1};
    end;
    %chunk_interval
    a=find(strcmpi(varargin,'chunk_interval'));
    if isempty(a);
    else
        chunk_interval=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='chunk epochs';

%init out_header
out_header=header;

%determine epoch limits
epoch_start=header.xstart;
epoch_end=header.xstart+((header.datasize(1)-1)*header.xstep);

%chunk_size_dx
chunk_size=chunk_duration;
chunk_size_dx=fix(chunk_duration/header.xstep);

%chunk_onsets (chunk_dxstart)
chunk_pos=1;
within_limits=1;
while within_limits==1;
    chunk_start=((chunk_pos-1)*chunk_interval)+chunk_onset;
    chunk_start_dx=fix((chunk_start-header.xstart)/header.xstep)+1;
    if (chunk_start_dx+chunk_size_dx)>header.datasize(6);
        %outside limits, end while
        within_limits=0;
    else
        %chunk_dxstart(chunk_pos)
        chunks_dxstart(chunk_pos)=chunk_start_dx;
        chunks_xstart(chunk_pos)=chunk_start;
        chunk_pos=chunk_pos+1;
    end;
end;

%num_chunks
num_chunks=length(chunks_dxstart);
message_string{end+1}=['Number of chunks per epoch : ' num2str(num_chunks)];

%prepare out_header
out_header.datasize(1)=out_header.datasize(1)*num_chunks;
out_header.datasize(6)=chunk_size_dx;
out_header.xstart=0;

%prepare out_data
out_data=zeros(out_header.datasize);

%now, we actually chunk the epochs
%loop through epochs
k=1;  %chunk counter
ke=1; %event counter

%initialize new_events (if there are events)
if isempty(header.events);
    new_events=[];
else
    new_events=header.events(1);
end;

for epoch_pos=1:size(data,1);
    %loop through chunks
    for chunk_pos=1:length(chunks_dxstart);
        out_data(k,:,:,:,:,:)=data(epoch_pos,:,:,:,:,chunks_dxstart(chunk_pos):chunks_dxstart(chunk_pos)+(chunk_size_dx-1));
        %and also fix all the events
        %x1,x2 : begin and end chunk latency
        x1=chunks_xstart(chunk_pos);
        x2=chunks_xstart(chunk_pos)+chunk_size;
        %only if there are events in the dataset
        if isfield(header,'events');
            if isempty(header.events);
            else
                %loop through events
                for event_pos=1:length(header.events);
                    %is this event in the corresponding epoch?
                    if header.events(event_pos).epoch==epoch_pos;
                        if header.events(event_pos).latency>=x1;
                            if header.events(event_pos).latency<=x2;
                                %latency of this event is inside chunk
                                new_events(ke)=header.events(event_pos);
                                %adjust epoch
                                new_events(ke).epoch=k;
                                %adjust latency
                                new_events(ke).latency=header.events(event_pos).latency-chunks_xstart(chunk_pos);
                                %inc ke
                                ke=ke+1;
                            end;
                        end;
                    end;
                end;
            end;
        end;
        k=k+1;
    end;
end;

%delete epochdata
if isfield(out_header,'epochdata');
    rmfield(out_header,'epochdata');
end;

%update new_events
out_header.events=new_events;


