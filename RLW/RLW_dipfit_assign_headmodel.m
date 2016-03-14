function [hdm_vol,message_string]=RLW_dipfit_assign_headmodel(hdm_filename);
%RLW_dipfit_assign_headmodel
%
%Assign head model volume for dipfit
%
%hdm_filename
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
message_string{1}='DIPFIT : assign headmodel';

%load headmodel file
load(hdm_filename);

%process
if exist('vol');
    message_string{end+1}='Found volume : storing.';
    hdm_vol=vol;
else
    message_string{end+1}='Error: no volume in datafile. Exit.';
    hdm_vol=[];
end;


