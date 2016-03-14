function [filename,message_string]=RLW_headmodel_compute(header);
%RLW_headmodel_compute
%
%Compute head model for 3D scalp maps
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
message_string{1}='Compute headmodel';

%filename
[p,n,e]=fileparts(header.name);
filename=[n,'.spl'];
message_string{end+1}=['SPL filename : ' filename];

%chanlocs
chanlocs=header.chanlocs;

%parse chanlocs according to topo_enabled
for i=1:length(chanlocs);
    topo_enabled(i)=chanlocs(i).topo_enabled;
end;
chanlocs=chanlocs(find(topo_enabled==1));

%spline
headplot('setup',chanlocs,filename);
            

