function [out_header,out_data,message_string]=RLW_ICA_apply_filter(header,data,ICA_mm,ICA_um,IC_list);
%RLW_ICA_apply_filter
%
%Apply ICA filter
%
%header
%data
%ICA_mm : ICA mixing matrix
%ICA_um : ICA unmixing matrix
%IC_list : list of ICs to retain
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

%prepare out_header
out_header=header;

%init out_data
out_data=data;

%selected ICs?
if isempty(IC_list);
    message_string{1}='No ICs selected.';
else
    message_string{1}=['Selected ICs : ',num2str(IC_list)];
end;

%edit ICA_mm
removeICs=1:1:size(ICA_mm,2);
removeICs(IC_list)=[];
ICA_mm(:,removeICs)=0;

%loop through epochs
if isempty(IC_list);
    out_data=data*0;
else
    for epochpos=1:header.datasize(1);
        %unmix & remix
        out_data(epochpos,:,1,1,1,:)=ICA_mm*(ICA_um*(squeeze(data(epochpos,:,1,1,1,:))));
    end;
end;



