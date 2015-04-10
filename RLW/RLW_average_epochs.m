function [out_header,out_data,message_string]=RLW_average_epochs(header,data,varargin);
%RLW_average_epochs
%
%Average epochs
%
%varargin
%'operation' : 'average' 'std' 'median'
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

operation='average';

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

%prepare out_header
out_header=header;
%change number of epochs
out_header.datasize(1)=1;

%init out_data
out_data=zeros(out_header.datasize);

%perform the operation
switch operation
    case 'average'
        out_data(1,:,:,:,:,:)=mean(data,1);
    case 'stdev'
        out_data(1,:,:,:,:,:)=std(data,0,1);
    case 'median'
        out_data(1,:,:,:,:,:)=median(data,1);
end;

%adjust events
if isfield(out_header,'events');
    for event_pos=1:length(out_header.events);
        out_header.events(event_pos).epoch=1;
    end;
end;

%delete duplicate events
out_header=RLW_events_delete_duplicate(header);

%delete epochdata
if isfield(out_header,'epochdata');
    rmfield(out_header,'epochdata');
end;



