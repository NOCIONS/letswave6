function [out_header,message_string]=RLW_edit_electrodes_SEEG(header,chanlocs);
%RLW_edit_electrodes
%
%Edit electrodes
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
message_string{1}='Edit electrode coordinates.';

%prepare out_header
out_header=header;

%check whether there are electrode coordinates to change
if isempty(chanlocs);
    return;
end;

%channel_labels
for i=1:length(header.chanlocs);
    channel_labels{i}=header.chanlocs(i).labels;
end;

%chanloc_labels
for i=1:length(chanlocs);
    chanloc_labels{i}=chanlocs(i).labels;
end;

%loop through channel labels to see if they can be updated
header_chanlocs=header.chanlocs;
for chanpos=1:length(channel_labels);
    a=find(strcmpi(channel_labels{chanpos},chanloc_labels)==1);
    %check if label is in chanlocs
    if isempty(a);
    else
        header_chanlocs(chanpos).theta=chanlocs(a).theta;
        header_chanlocs(chanpos).radius=chanlocs(a).radius;
        header_chanlocs(chanpos).sph_theta=chanlocs(a).sph_theta;
        header_chanlocs(chanpos).sph_phi=chanlocs(a).sph_phi;
        header_chanlocs(chanpos).sph_theta_besa=chanlocs(a).sph_theta_besa;
        header_chanlocs(chanpos).sph_phi_besa=chanlocs(a).sph_phi_besa;
        header_chanlocs(chanpos).X=chanlocs(a).X;
        header_chanlocs(chanpos).Y=chanlocs(a).Y;
        header_chanlocs(chanpos).Z=chanlocs(a).Z;
        header_chanlocs(chanpos).topo_enabled=1;
        header_chanlocs(chanpos).SEEG_enabled=0;
    end;
end;

out_header.chanlocs=header_chanlocs;

