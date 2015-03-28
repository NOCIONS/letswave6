function [out_header,message_string]=RLW_edit_electrodes_info(header,chanlocs);
%RLW_edit_electrodes_info
%
%Edit electrodes info
%
%header
%chanlocs
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
message_string{1}='Edit electrodes info.';

%prepare out_header
out_header=header;

%check whether there are electrode coordinates to change
if isempty(chanlocs);
    return;
end;

%channel_labels
channel_labels={};
for i=1:length(header.chanlocs);
    channel_labels{i}=header.chanlocs(i).labels;
end;

%loop through chanlocs
for i=1:length(chanlocs);
    a=find(strcmpi(chanlocs(i).labels,channel_labels));
    if isempty(a);
    else
        for j=1:length(a);
            out_header.chanlocs(j)=chanlocs(i);
        end;
    end;
end;




