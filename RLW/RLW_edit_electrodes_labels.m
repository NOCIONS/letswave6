function [out_header,message_string]=RLW_edit_electrodes_labels(header,chan_labels);
%RLW_edit_electrodes_labels
%
%Edit electrodes info
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
message_string{1}='Edit electrode labels.';

%prepare out_header
out_header=header;

%check whether there are electrode labels to change
if isempty(chan_labels);
    return;
end;

%channel_labels
channel_labels={};
for i=1:length(header.chanlocs);
    channel_labels{i}=header.chanlocs(i).labels;
end;

%change matching labels
for i=1:size(chan_labels,1);
    a=find(strcmpi(chan_labels{i,1},channel_labels)==1);
    if isempty(a)
    else
        for j=1:length(a);
            out_header.chanlocs(a(j)).labels=chan_labels{i,2};
        end;
    end;
end;



