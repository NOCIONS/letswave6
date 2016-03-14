function CLW_makeversion
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

