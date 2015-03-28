function [dipole_data,message_string]=RLW_dipfit_fit_ICs(header,data,IC_list,ICA_mm,chanlocs,vol,mri,varargin);
%RLW_dipfit_fit_ICs
%
%DIPFIT : fit dipole(s) onto ICs
%
%header
%data
%IC_list
%elec
%vol
%mri
%
%varargin
%'dipole_model' ('single') 'single','pairX','pairY','pairZ','pair'
%'gridsearch_resolution' (10)
%'y'
%'z'
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

dipole_model='single';
gridsearch_resolution=10;
y=header.ystart;
z=header.zstart;

%parse varagin
if isempty(varargin);
else
    %dipole_model
    a=find(strcmpi(varargin,'dipole_model'));
    if isempty(a);
    else
        dipole_model=varargin{a+1};
    end;
    %gridsearch_resolution
    a=find(strcmpi(varargin,'gridsearch_resolution'));
    if isempty(a);
    else
        gridsearch_resolution=varargin{a+1};
    end;
    %y
    a=find(strcmpi(varargin,'y'));
    if isempty(a);
    else
        y=varargin{a+1};
    end;
    %z
    a=find(strcmpi(varargin,'z'));
    if isempty(a);
    else
        z=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='DIPFIT : fit ICs.';

%prepare out_header
out_header=header;

%init dipole_data
dipole_data.dipole_list=[];
dipole_data.topo_list=[];
dipole_data.topo_channel_labels=[];
dipole_data.elec=[];
dipole_data.vol=vol;
dipole_data.mri=mri;

%check presence of IC_list
if isempty(IC_list);
    message_string{end+1}='No ICs selected. Exit.';
    return;
end;

%chanlocs_labels : chanlocs(i).labels
chanlocs_labels={};
for i=1:length(chanlocs);
    chanloc_labels{i}=chanlocs(i).labels;
end;

%elec
tp=[];
j=1;
for i=1:length(header.chanlocs);
    a=find(strcmpi(header.chanlocs(i).labels,chanloc_labels));
    if isempty(a);
    else
        tp(j,1)=chanlocs(a(1)).X;
        tp(j,2)=chanlocs(a(1)).Y;
        tp(j,3)=chanlocs(a(1)).Z;
        chanlabels{j}=chanlocs(a(1)).labels;
        chanidx(j)=i;
        j=j+1;
    end;
end;

%check for corresponding labels
if isempty(tp);
    message_string{end+1}='No corresponding channel locations were found. Exit.';
    return;
end;
message_string{end+1}=[num2str(length(chanlabels)) ' corresponding channels were found.'];
chanlabels=chanlabels';
elec.pnt=tp;
elec.label=chanlabels;

%init dipole_list
dipole_list=[];
topo_list=[];

%loop through IC_list
for IC_pos=1:length(IC_list);
    message_string{end+1}=['Loading IC topography : ' num2str(IC_list(IC_pos))];
    
    %topo
    topo=squeeze(ICA_mm(:,IC_list(IC_pos)));
    topo=topo(chanidx);
    
    %topo_channel_labels
    st={};
    for i=1:length(header.chanlocs);
        st{i}=header.chanlocs(i).labels;
    end;
    topo_channel_labels=st(chanidx);
    
    %prepare ft_data
    ft_data=[];
    ft_data.avg(:,1)=topo;
    ft_data.time=1;
    ft_data.label=elec.label;
    ft_data.dimord='chan_time';
    ft_data.cfg=[];
    
    %cfg 'single','pairX','pairY','pairZ','pair'
    cfg=[];
    switch dipole_model;
        case 'single'
            numdipoles=1;
        case 'pairX'
            numdipoles=2;
            cfg.symmetry='x';
        case 'pairY'
            numdipoles='y';
        case 'pairZ'
            numdipoles='z';
        case 'pair'
            numdipoles=2;
    end;
    cfg.numdipoles=numdipoles;
    cfg.model      = 'moving';
    cfg.gridsearch = 'yes';
    cfg.nonlinear  = 'no';
    cfg.channel=chanlabels;
    cfg.vol=vol;
    cfg.elec=elec;
    cfg.latency=1;
    cfg.grid.resolution=gridsearch_resolution;
    cfg.feedback='textbar';
    
    %gridsearch
    message_string{end+1}=['Fitting dipole (gridsearch).'];
    source=ft_dipolefitting(cfg,ft_data);
    
    %dipole_fitting cfg (non linear)
    cfg.dip=source.dip;
    cfg.gridsearch='no';
    cfg.nonlinear='yes';
    cfg.feedback='textbar';
    message_string{end+1}=['Fitting dipole (fine).'];
    source=ft_dipolefitting(cfg,ft_data);
    
    %dipole
    dipole.dip=source.dip;
    dipole.posxyz=source.dip.pos;
    dipole.momxyz=reshape(source.dip.mom,3,length(source.dip.mom)/3)';
    dipole.diffmap=source.Vmodel - source.Vdata;
    dipole.sourcepot=source.Vmodel;
    dipole.datapot=source.Vdata;
    dipole.rv=NaN;
    if isfield(source.dip,'rv');
        dipole.rv=source.dip.rv;
    end;
    if numdipoles==2;
        dipole.posxyz(:,:)=dipole.posxyz(:,[2 1 3]);
        dipole.momxyz(:,:)=dipole.momxyz(:,[2 1 3]);
        dipole.posxyz(:,2)=-dipole.posxyz(:,2);
        dipole.momxyz(:,2)=-dipole.momxyz(:,2);
    else
        dipole.posxyz(:)=dipole.posxyz([2 1 3]);
        dipole.momxyz(:)=dipole.momxyz([2 1 3]);
        dipole.posxyz(2)=-dipole.posxyz(2);
        dipole.momxyz(2)=-dipole.momxyz(2);
    end;
    
    %additional dipole information
    dipole.epochpos=[];
    dipole.indexpos=[];
    dipole.dzpos=[];
    dipole.dypos=[];
    dipole.dxpos=[];
    dipole.label=['IC ' num2str(IC_list(IC_pos))];
    
    %update dipole_list
    if isempty(dipole_list);
        dipole_list(1).dipole=dipole;
    else
        dipole_list(end+1).dipole=dipole;
    end;
    
    %update topo_list
    if isempty(topo_list);
        topo_list(1).topo=topo;
    else
        topo_list(end+1).topo=topo;
    end;
                
    %report
    message_string{end+1}=['POS : ' num2str(source.dip.pos)];
    message_string{end+1}=['RV : ' num2str(source.dip.rv)];
end;

%dipole_data
dipole_data.dipole_list=dipole_list;
dipole_data.topo_list=topo_list;
dipole_data.topo_channel_labels=topo_channel_labels;
dipole_data.elec=elec;



