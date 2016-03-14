function [out_header,out_data,message_string]=RLW_derivate_signals(header,data,varargin);
%RLW_derivate_signals
%
%Derivate signals
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
message_string{1}='Derivate signals';

%prepare out_header
out_header=header;

%init out_data
out_data=data;

%dx(i)-dx(i-1)
for dx=2:header.datasize(6);
    out_data(:,:,:,:,:,dx)=data(:,:,:,:,:,dx)-data(:,:,:,:,:,dx-1);
end;
         


