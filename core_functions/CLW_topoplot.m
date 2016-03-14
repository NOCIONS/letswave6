function h=CLW_topoplot(header,data,epoch,index,dx,dy,dz,varargin)
%CLW_topoplot
%Scalpmap of data at epoch/index/x/y/z
%Dependebcies : topoplot (EEGLAB)
%draws the map in the current figure
%optional inputs: see topoplot optional arguments (EEGLAB)
%suggested usage : LW_topoplot(data,epoch,index,x,y,z,'maplimits',[-20 20],'shading','interp','whitebk','on');
%
% Author : 
% Andre Mouraux
% Institute of Neurosciences (IONS)
% Universite catholique de louvain (UCL)
% Belgium
% 
% Contact : andre.mouraux@uclouvain.be
% This function is part of Letswave 5
% See http://nocions.webnode.com/letswave for additional information


%fetch data to display
vector=squeeze(data(epoch,:,index,dz,dy,dx));
%fetch chanlocs
chanlocs=header.chanlocs;
%parse data and chanlocs according to topo_enabled
k=1;
for chanpos=1:size(chanlocs,2);
    if chanlocs(chanpos).topo_enabled==1
        vector2(k)=double(vector(chanpos));
        chanlocs2(k)=chanlocs(chanpos);
        k=k+1;
    end;
end;
h=topoplot(vector2,chanlocs2,varargin{:});
set(gcf,'color',[1 1 1]);