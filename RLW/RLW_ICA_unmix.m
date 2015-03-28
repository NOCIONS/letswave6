function [out_header,out_data,message_string,original_chanlocs]=RLW_ICA_unmix(header,data,varargin);
%RLW_ICA_unmix
%
%ICA unmix
%
%varargin
%
%'ICA_um' : default is empty : search for unmixing matrix in header
%           if 'ICA_um' is not empty, it will use this matrix for unmixing
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

ICA_um=[];

%parse varagin
if isempty(varargin);
else
    %ICA_um
    a=find(strcmpi(varargin,'ICA_um'));
    if isempty(a);
    else
        ICA_um=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='ICA unmix';

%prepare out_header
out_header=header;

%unmixing matrix
if isempty(ICA_um);
    %search history for an unmixing matrix
    for i=1:length(header.history);
        switch header.history(i).configuration.gui_info.function_name
            case 'LW_ICA_compute';
                ICA_um=header.history(i).configuration.parameters.ICA_um;
            case 'LW_ICA_compute_merged';
                ICA_um=header.history(i).configuration.parameters.ICA_um;
            case 'LW_ICA_assign';
                ICA_um=header.history(i).configuration.parameters.ICA_um;
        end;
    end;
end;

%store old chanlocs
original_chanlocs=header.chanlocs;

%update chanlocs > ICs
out_header.chanlocs=[];
for i=1:size(ICA_um,1);
    out_header.chanlocs(i).labels=['IC',num2str(i)];
    out_header.chanlocs(i).topo_enabled=0;
end;

%header.datasize : update number of channels
out_header.datasize(2)=size(ICA_um,1);

%prepare outdata
out_data=zeros(out_header.datasize);

%activations = weights*sphere*(input_data);
for epochpos=1:header.datasize(1);
    out_data(epochpos,:,1,1,1,:)=ICA_um*(squeeze(data(epochpos,:,1,1,1,:)));
end;



