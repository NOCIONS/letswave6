function [out_header,out_data,message_string]=RLW_flip_electrodes(header,data,chan_labels);
%RLW_flip_electrodes
%
%Flip electrodes
%
%header
%chan_labels %cell array : col1=old label; col2=new label
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
message_string{1}='Flip electrodes.';

%prepare out_header
out_header=header;

%check whether there are electrode labels to change
if isempty(chan_labels);
    return;
end;

%header_labels
for i=1:length(header.chanlocs);
    header_labels{i}=header.chanlocs(i).labels;
end;

%data_chan_idx
data_chan_idx=1:header.datasize(2);
data_chan_idx2=data_chan_idx;

for chan_idx=1:size(chan_labels,1);
    idx1=find(strcmpi(header_labels,chan_labels{chan_idx,1}));
    idx2=find(strcmpi(header_labels,chan_labels{chan_idx,2}));
    if isempty(idx1);
    else
        if isempty(idx2);
        else
            data_chan_idx2(idx1)=data_chan_idx(idx2);
        end;
    end;
end;

out_data=data(:,data_chan_idx2,:,:,:,:);
    



