function [out_header,out_data,message_string]=RLW_dc_removal(header,data,varargin);
%RLW_dc_removal
%
%Remove DC and linear detrend
%
%varargin
%'linear_detrend' (0)
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

linear_detrend=0;

%parse varagin
if isempty(varargin);
else
    %linear_detrend
    a=find(strcmpi(varargin,'linear_detrend'));
    if isempty(a);
    else
        linear_detrend=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='DC removal';

%prepare out_header
out_header=header;

%init out_data
out_data=data;

%linear detrend?
if linear_detrend==1;
    message_string{end+1}='Applying a linear detrend.';
end;

%loop through all the data
for epochpos=1:size(data,1);
    for channelpos=1:size(data,2);
        for indexpos=1:size(data,3);
            for dz=1:size(data,4);
                for dy=1:size(data,5);
                    %calculate DC
                    bl=squeeze(mean(data(epochpos,channelpos,indexpos,dz,dy,:),6));
                    %subtract baseline
                    if linear_detrend==1;
                        out_data(epochpos,channelpos,indexpos,dz,dy,:)=detrend(squeeze(data(epochpos,channelpos,indexpos,dz,dy,:)-bl),'linear');
                    else
                        out_data(epochpos,channelpos,indexpos,dz,dy,:)=data(epochpos,channelpos,indexpos,dz,dy,:)-bl;
                    end
                end;
            end;
        end;
    end;
end;



