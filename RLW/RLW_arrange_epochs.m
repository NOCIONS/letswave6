function [out_header,out_data,message_string]=RLW_arrange_epochs(header,data,epoch_idx);
%RLW_arrange_epochs
%
%Arrange or delete epochs
%
%header
%data
%epoch_idx
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
message_string{1}='Arrange or delete epochs';
message_string{end+1}=['Number of epochs : ' num2str(length(epoch_idx))];

%prepare out_header
out_header=header;

%data
out_data=data(epoch_idx,:,:,:,:,:);

%change number of channels
out_header.datasize=size(out_data);




