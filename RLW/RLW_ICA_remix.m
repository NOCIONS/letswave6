function [out_header,out_data,message_string]=RLW_ICA_remix(header,data,varargin);
%RLW_ICA_remix
%
%ICA remix
%
%varargin
%
%'ICA_mm' : default is empty : search for unmixing matrix in header
%           if 'ICA_um' is not empty, it will use this matrix for unmixing
%'IC_list' : list of ICs to keep in the remix. 
%            if IC_list is empty, will keep all ICs
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

ICA_mm=[];
IC_list=[];

%parse varagin
if isempty(varargin);
else
    %ICA_mm
    a=find(strcmpi(varargin,'ICA_mm'));
    if isempty(a);
    else
        ICA_mm=varargin{a+1};
    end;
    %IC_list
    a=find(strcmpi(varargin,'IC_list'));
    if isempty(a);
    else
        IC_list=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='ICA remix';

%init out_header
out_header=header;

%mixing matrix
if isempty(ICA_mm);
    %search history for a mixing matrix
    for i=1:length(header.history);
        switch header.history(i).configuration.gui_info.function_name
            case 'LW_ICA_compute';
                ICA_mm=header.history(i).configuration.parameters.ICA_mm;
            case 'LW_ICA_compute_merged';
                ICA_mm=header.history(i).configuration.parameters.ICA_mm;
            case 'LW_ICA_assign_matrix';
                ICA_mm=header.history(i).configuration.parameters.ICA_mm;
        end;
    end;
end;

%selected ICs?
if isempty(IC_list);
    %if empty, use *all* ICs
else
    %not empty
    %edit mixing matrix
    message_string{end+1}=['Selected ICs : ',num2str(IC_list)];
    %mask
    remove_ICs=1:1:size(ICA_mm,2);
    remove_ICs(IC_list)=[];
    ICA_mm(:,remove_ICs)=0;
end;

%update header.datasize : update number of channels
out_header.datasize(2)=size(ICA_mm,1);

%search history for old chanlocs
k=0;
for i=1:length(header.history);
    switch header.history(i).configuration.gui_info.function_name
        case 'LW_ICA_unmix';
            message_string{end+1}='Found original channel information!';
            out_header.chanlocs=header.history(i).configuration.parameters.old_chanlocs;
            k=1;
    end;
end;

%no chanlocs found, generating dummy labels
if k==0;
    message_string{end+1}='Did not find the original channel information!';
    message_string{end+1}='Computing dummy channel labels.';
    for i=1:out_header.datasize(2);
        out_header.chanlocs(i).labels=['C',num2str(i)];
        out_header.chanlocs(i).topo_enabled=0;
        out_header.chanlocs(i).SEEG_enabled=0;
    end;
end;

%prepare outdata
out_data=zeros(out_header.datasize);

%mixed signals = mm*(input_data);
for epochpos=1:header.datasize(1);
    tp=squeeze(data(epochpos,:,1,1,1,:));
    out_data(epochpos,:,1,1,1,:)=ICA_mm*tp;
end;



