function [out_header,out_data,message_string]=RLW_math_constant(header,data,varargin);
%RLW_math_constant
%
%Mathematical operation using a constant
%
%varargin
%'operation' ('add') 'add' 'subtract' 'multiply' 'divide'
%'constant' (0)
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

operation='add';
constant=0;

%parse varagin
if isempty(varargin);
else
    %operation
    a=find(strcmpi(varargin,'operation'));
    if isempty(a);
    else
        operation=varargin{a+1};
    end;
    %constant
    a=find(strcmpi(varargin,'constant'));
    if isempty(a);
    else
        constant=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{end+1}='Math operation using a constant';

%prepare out_header
out_header=header;

%loop through all the data
switch operation;
    case 'add'
        out_data=data+constant;
    case 'subtract'
        out_data=data-constant;
    case 'multiply'
        out_data=data*constant;
    case 'divide'
        out_data=data/constant;
end;



