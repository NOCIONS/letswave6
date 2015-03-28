function CLW_makezip
%
% Author : 
% Andre Mouraux
% Institute of Neurosciences (IONS)
% Université catholique de louvain (UCL)
% Belgium
% 
% Contact : andre.mouraux@uclouvain.be
% This function is part of Letswave 6
% See http://nocions.org/letswave for additional information
%

%local
disp('Locating local install');
tp=which('letswave.m');
[p,n,e]=fileparts(tp);
localtarget=[p];
disp(['Found at : ' localtarget]);

%create version mat
LW_version.date=date;
LW_version.now=now;
filename=[localtarget filesep 'LW_version.mat'];
save(filename,'LW_version');


%files
files{1}=[p filesep 'letswave.m'];
files{2}=[p filesep 'letswave.mat'];
files{3}=[p filesep 'letswave6.m'];
files{4}=[p filesep 'LW_version.mat'];
files{5}=[p filesep 'core_functions'];
files{6}=[p filesep 'example_data'];
files{7}=[p filesep 'external'];
files{8}=[p filesep 'GLW'];
files{9}=[p filesep 'internal'];
files{10}=[p filesep 'LW'];
files{11}=[p filesep 'override'];
files{12}=[p filesep 'plugins'];
files{13}=[p filesep 'resources'];
files{14}=[p filesep 'RLW'];



%make zip
zip('letswave6.zip',files);



