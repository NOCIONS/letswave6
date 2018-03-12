function [out_header,out_data,message_string]=RLW_pool_channels(header,data,channel_labels,varargin);
%RLW_pool_channels
%
%Pool channels
%
%channel_labels : cell array
%
%varargin
%channel_weights : 0
%mixed_channel_label : 'newchan'
%keep_original_channels : 1
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

channel_weights=0;
mixed_channel_label='newchan';
keep_original_channels=1;

%parse varagin
if isempty(varargin);
else
    %channel_weights
    a=find(strcmpi(varargin,'channel_weights'));
    if isempty(a);
    else
        channel_weights=varargin{a+1};
    end;
    %mixed_channel_label
    a=find(strcmpi(varargin,'mixed_channel_label'));
    if isempty(a);
    else
        mixed_channel_label=varargin{a+1};
    end;
    %keep_original_channels
    a=find(strcmpi(varargin,'keep_original_channels'));
    if isempty(a);
    else
        keep_original_channels=varargin{a+1};
    end;
end;

%init message_string
message_string={};

%prepare out_header
out_header=header;

%set weights=1 if channel_weights==0
if channel_weights==0;
    channel_weights=ones(1,length(channel_labels));
end;

%channel_labels
for i=1:length(header.chanlocs);
    st{i}=header.chanlocs(i).labels;
end;

message_string{1}='Searching for selected channels.';
message_string{2}=['Weights : ' num2str(channel_weights)];

%channels_idx
j=1;
selected_channels_idx=[];
selected_channels_weight=[];
for i=1:length(channel_labels);
    a=find(strcmpi(channel_labels{i},st)==1);
    if isempty(a);
    else
        selected_channels_idx(j)=a(1);
        selected_channels_weight(j)=channel_weights(i);
        j=j+1;
    end;
end;

%Check that selected channels were found
if isempty(selected_channels_idx);
    message_string{end+1}='Selected channels not found in the dataset';
    return;
end;

%prepare tp (new channel)
tp=header.datasize;
tp(2)=1;
tp=zeros(tp);

%weighted sum
for i=1:length(selected_channels_idx);
    tp(:,1,:,:,:,:)=tp+(data(:,selected_channels_idx(i),:,:,:,:)*selected_channels_weight(i));
end;

%divide by sum of weights
tp=tp/sum(selected_channels_weight);

%out_data
if keep_original_channels==1;
    out_data=data;
    out_data(:,end+1,:,:,:,:)=tp;
else
    out_data=tp;
end;

%adjust out_header.datasize
out_header.datasize=size(out_data);

%adjust chanlocs
out_header.chanlocs(out_header.datasize(2)).labels=mixed_channel_label;
out_header.chanlocs(out_header.datasize(2)).topo_enabled=0;
out_header.chanlocs(out_header.datasize(2)).SEEG_enabled=0;
if keep_original_channels==0;
    out_header.chanlocs=out_header.chanlocs(1);
end;

