function [out_header,out_data,message_string]=RLW_ocular_remove(header,data,varargin)
%RLW_ocular_remove
%
%remove the ocular artifact by the tranditional method (Gratton, Coles, and Donchin, 1983)
%
%varargin
%channel : 0
%
% Author :
% Gan Huang
% Institute of Neurosciences (IONS)
% Universite catholique de louvain (UCL)
% Belgium
%
% Contact : andre.mouraux@uclouvain.be
% This function is part of Letswave 6
% See http://nocions.webnode.com/letswave for additional information
%


%parse varagin
if isempty(varargin);
else
    %constant
    a=find(strcmpi(varargin,'EOG'));
    if isempty(a);
    else
        channel=varargin{a+1};
    end;
end
%init message_string
message_string={};

%prepare out_header
out_header=header;
out_data=data;
if isempty(channel)
    return;
end
for k2=1:size(data,2)
    y=reshape(data(:,k2,:,:,:,:),1,[]);
    for ch_idx=1:length(channel)
        X(ch_idx,:)=reshape(data(:,channel(ch_idx),:,:,:,:),1,[]);
    end
    X(ch_idx+1,:)=1;
    b = regress(y',X');
    for ch_idx=1:length(channel)
        out_data(:,k2,:,:,:,:)=out_data(:,k2,:,:,:,:)-b(ch_idx)*data(:,channel(ch_idx),:,:,:,:);
    end
end


