function [mri_data,message_string]=RLW_dipfit_assign_mri(mri_filename);
%RLW_dipfit_assign_mri
%
%Assign MRI data for dipfit
%
%mri_filename
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
message_string{1}='DIPFIT : assign MRI data';

%load MRI file
load(mri_filename);

%process
if exist('mri');
    message_string{end+1}='Found MRI : storing.';
    mri_data=mri;
else
    message_string{end+1}='Error: no MRI in datafile. Exit.';
    mri_data=[];
end;


