function letswave;
%letswave

%platform-specific configuration
if ispc==1;
    disp('This is a Windows PC.');
end;
if ismac==1;
    disp('This is a Mac.');
end;
if and(isunix==1,ismac==0);
    disp('This is a Unix system.');
end;
%set path
[p,n,e]=fileparts(mfilename('fullpath'));
addpath([p]);
addpath([p filesep 'core_functions']);
addpath([p filesep 'LW']);
addpath([p filesep 'GLW']);
addpath([p filesep 'RLW']);
addpath([p filesep 'internal']);
addpath([p filesep 'external']);
addpath([p filesep 'external' filesep 'fieldtrip']);
addpath([p filesep 'external' filesep 'eeglab']);
addpath([p filesep 'external' filesep 'anteepimport1.09']);
addpath([p filesep 'external' filesep 'singletrial toolbox']);
addpath([p filesep 'external' filesep 'CSD toolbox']);
addpath([p filesep 'external' filesep 'pica']);
addpath([p filesep 'external' filesep 'visualisationmodule']);
addpath([p filesep 'external' filesep 'csd_maker']);
addpath([p filesep 'external' filesep 'neurone']);
addpath([p filesep 'plugins' filesep 'LW']);
addpath([p filesep 'plugins' filesep 'GLW']);
addpath([p filesep 'override' filesep 'LW']);
addpath([p filesep 'override' filesep 'GLW']);
%letswave
letswave_gui;
end

