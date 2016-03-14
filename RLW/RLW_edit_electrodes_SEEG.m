function [out_header,message_string]=RLW_edit_electrodes_SEEG(header,list_labels,list_X,list_Y,list_Z);
%RLW_edit_electrodes_labels
%
%Edit electrodes info
%
%header
%list_labels
%list_X
%list_Y
%list_Z
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
message_string{1}='Edit electrode (SEEG).';

%prepare out_header
out_header=header;

%check whether there are electrode coordinates to change
if isempty(list_labels);
    return;
end;

%channel_labels
for i=1:length(header.chanlocs);
    channel_labels{i}=header.chanlocs(i).labels;
end;
    
%loop through channels to update
for i=1:length(list_labels);
    st=list_labels{i};
    a=find(strcmpi(st,channel_labels)==1);
    if isempty(a);
    else
        message_string{end+1}=['Setting SEEG electrode coordinate : ' st];
        chanpos=a(1);
        out_header.chanlocs(chanpos).X=list_X(i);
        out_header.chanlocs(chanpos).Y=list_Y(i);
        out_header.chanlocs(chanpos).Z=list_Z(i);
        out_header.chanlocs(chanpos).SEEG_enabled=1;
        out_header.chanlocs(chanpos).topo_enabled=0;
    end;
end;

