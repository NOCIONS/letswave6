function [out_header,out_data,message_string]=RLW_rereference(header,data,varargin);
%RLW_rereference
%
%
%Rereference
%varargin
%'apply_list'
%'reference_list'
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

%apply_list
for i=1:length(header.chanlocs);
    apply_list{i}=header.chanlocs(i).labels;
end;

%reference_list
reference_list=apply_list;

%parse varagin
if isempty(varargin);
else
    %apply_list
    a=find(strcmpi(varargin,'apply_list'));
    if isempty(a);
    else
        apply_list=varargin{a+1};
    end;
    %reference_list
    a=find(strcmpi(varargin,'reference_list'));
    if isempty(a);
    else
        reference_list=varargin{a+1};
    end;
end;


%init message_string
message_string={};
message_string{1}='rereference';

%prepare out_header
out_header=header;

%channel_labels
for i=1:length(header.chanlocs);
    channel_labels{i}=header.chanlocs(i).labels;
end;

%reference_idx
k=[];
for i=1:length(reference_list);
    a=find(strcmpi(channel_labels,reference_list{i})==1);
    if isempty(a);
        message_string{end+1}='!!! Error : channel not found.';
        return;
    end;
    k(end+1)=a(1);
end;
if isempty(k);
    message_string{end+1}='!!! Error : no corresponding reference channels found.';
    return;
end;
reference_idx=k;

%apply_idx
k=[];
for i=1:length(apply_list);
    a=find(strcmpi(channel_labels,apply_list{i})==1);
    if isempty(a);
        message_string{end+1}='!!! Error : channel not found.';
        return;
    end;
    k(end+1)=a(1);
end;
if isempty(k);
    message_string{end+1}='!!! Error : no corresponding reference channels found.';
    return;
end;
apply_idx=k;

%compute new reference
refdata=data(:,reference_idx,:,:,:,:);
refdata=mean(refdata,2);

%out_data
out_data=data;

%apply new reference
for channelpos=1:length(apply_idx);
    out_data(:,apply_idx(channelpos),:,:,:,:)=data(:,apply_idx(channelpos),:,:,:,:)-refdata;
end;



