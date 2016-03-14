function [chanlocs,message_string]=RLW_dipfit_assign_chanlocs(chanloc_filename);
%RLW_dipfit_assign_chanlocs
%
%Assign channel locations for dipfit
%
%chanloc_filename=[];
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
message_string{1}='DIPFIT : assign channel locations';

%load locs
locs=readlocs(chanloc_filename);

%create chanlocs
for i=1:length(locs);
    chanlocs(i).labels=locs(i).labels;
    chanlocs(i).theta=locs(i).theta;
    chanlocs(i).radius=locs(i).radius;
    chanlocs(i).sph_theta=locs(i).sph_theta;
    chanlocs(i).sph_phi=locs(i).sph_phi;
    chanlocs(i).sph_theta_besa=locs(i).sph_theta_besa;
    chanlocs(i).sph_phi_besa=locs(i).sph_phi_besa;
    chanlocs(i).X=locs(i).X;
    chanlocs(i).Y=locs(i).Y;
    chanlocs(i).Z=locs(i).Z;
end;

message_string{end+1}=[num2str(length(locs)) ' channels found in chanloc filename'];
