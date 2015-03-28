function [out_header,out_data,message_string]=RLW_rereference_advanced(header,data,active_channel_labels,reference_channel_labels);
%RLW_rereference_advanced
%
%Rereference (custom montage)
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



%init message_string
message_string={};
message_string{1}='rereference (custom montage)';

%prepare out_header
out_header=header;

%channel_labels
for i=1:length(header.chanlocs);
    channel_labels{i}=header.chanlocs(i).labels;
end;

%active_idx,reference_idx
active_idx=[];
reference_idx=[];
for i=1:length(active_channel_labels);
    a=find(strcmpi(active_channel_labels{i},channel_labels));
    if isempty(a);
        message_string{end+1}='Error : channel label not found.';
        return;
    end;
    active_idx=[active_idx a];
    a=find(strcmpi(reference_channel_labels{i},channel_labels));
    if isempty(a);
        message_string{end+1}='Error : channel label not found.';
        return;
    end;
    reference_idx=[reference_idx a];
end;

%change header.datasize
out_header.datasize(2)=length(active_idx);

%change chanlocs
out_header.chanlocs=[];
for i=1:length(active_channel_labels);
    out_header.chanlocs(i).labels=[active_channel_labels{i} '-' reference_channel_labels{i}];
    out_header.chanlocs(i).topo_enabled=0;
    out_header.chanlocs(i).SEEG_enabled=0;
end;

%init out_data
out_data=zeros(out_header.datasize);

%loop through new channels
for chanpos=1:length(active_idx);
    out_data(:,chanpos,:,:,:,:)=data(:,active_idx(chanpos),:,:,:,:)-data(:,reference_idx(chanpos),:,:,:,:);
end;



