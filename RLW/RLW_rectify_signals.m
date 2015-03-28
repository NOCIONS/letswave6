function [out_header,out_data,message_string]=RLW_rectify_signals(header,data,varargin);
%RLW_rectify signals
%
%Rectify signals
%
%varargin
%'operation' : 'rectify' 'square' 
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

operation='rectify';

%parse varagin
if isempty(varargin);
else
    %operation
    a=find(strcmpi(varargin,'operation'));
    if isempty(a);
    else
        operation=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='rectify or square signals';

%loop through all the data
switch operation;
    case 'rectify'
        out_data=abs(data);
    case 'square'
        out_data=data.^2;
end;

%out_header
out_header=header;
