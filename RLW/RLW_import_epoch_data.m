function [out_header,message_string]=RLW_import_epoch_data(header,epoch_data);
%RLW_import_epoch_data
%
%Import epoch data
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


%init message_string
message_string={};
message_string{1}='Import epoch data';

%prepare out_header
out_header=header;

%add epochdata
out_header.epochdata=epoch_data;

