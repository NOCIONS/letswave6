function [out_header,out_data,message_string]=RLW_concatenate_epochs(header,data,epoch_idx);
%RLW_concatenate_epochs
%
%Concatenate epochs
%
%header
%data
%epoch_idx
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


%init message_string
message_string={};
message_string{1}='Concatenate epochs';
message_string{end+1}=['Number of epochs : ' num2str(length(epoch_idx))];

%prepare out_header
out_header=header;

%out_header.datasize
out_header.datasize(6)=header.datasize(6)*length(epoch_idx);
out_header.datasize(1)=1;

%first epoch
out_data=data(epoch_idx(1),:,:,:,:,:);

%concatenate remaining epochs
if length(epoch_idx)>1;
    for i=2:length(epoch_idx);
        out_data=cat(6,out_data,data(epoch_idx(i),:,:,:,:,:));
    end;
end;

%fix events
if isfield(out_header,'events');
    %delete events
    events_to_delete=[];
    events=out_header.events;
    for i=1:length(events);
        a=find(epoch_idx==events(i).epoch);
        if isempty(a);
            events_to_delete(end+1)=i;
        else
            events(i).epoch=a(1);
        end;
    end;
    events(events_to_delete)=[];
    %fix event latencies
    dur=header.datasize(6)*header.xstep;
    for i=1:length(events);
        events(i).latency=(events(i).latency)+(dur*(events(i).epoch-1));
        events(i).epoch=1;
    end;
    out_header.events=events;
end;





