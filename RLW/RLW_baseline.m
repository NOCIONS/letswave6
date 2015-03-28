function [out_header,out_data,message_string]=RLW_baseline(header,data,varargin);
%RLW_baseline
%
%Baseline correction
%
%varargin
%'operation' : 'zscore' 'erpercent' 'divide' 'subtract'
%'xstart' : header.xstart
%'xend' : 0
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

operation='subtract';
xstart=header.xstart;
xend=0;

%parse varagin
if isempty(varargin);
else
    %operation
    a=find(strcmpi(varargin,'operation'));
    if isempty(a);
    else
        operation=varargin{a+1};
    end;
    %xstart
    a=find(strcmpi(varargin,'xstart'));
    if isempty(a);
    else
        xstart=varargin{a+1};
    end;
    %xend
    a=find(strcmpi(varargin,'xend'));
    if isempty(a);
    else
        xend=varargin{a+1};
    end;
end;

%init message_string
message_string={};

%prepare out_header
out_header=header;

%init out_data
out_data=data;

%determine dxstart and dxend
dxstart=round(((xstart-header.xstart)/header.xstep)+1);
dxend=round(((xend-header.xstart)/header.xstep)+1);

%check limits
if dxstart<1;
    dxstart=1;
end;
if dxend>header.datasize(6);
    dxend=header.datasize(6);
end;
message_string{1}=['xstart : ' num2str(xstart) ' bin : ' num2str(dxstart)];
message_string{2}=['xend : ' num2str(xend) ' bin : ' num2str(dxend)];
message_string{3}=['operation : ' operation];

%loop through all the data
for epochpos=1:size(data,1);
    for channelpos=1:size(data,2);
        for indexpos=1:size(data,3);
            for dz=1:size(data,4);
                for dy=1:size(data,5);
                    bl_mean=squeeze(mean(data(epochpos,channelpos,indexpos,dz,dy,dxstart:dxend),6));
                    switch operation
                        case 'zscore'
                            bl_sd=squeeze(std(data(epochpos,channelpos,indexpos,dz,dy,dxstart:dxend),0,6));
                            out_data(epochpos,channelpos,indexpos,dz,dy,:)=(data(epochpos,channelpos,indexpos,dz,dy,:)-bl_mean)/bl_sd;
                        case 'erpercent'
                            out_data(epochpos,channelpos,indexpos,dz,dy,:)=(data(epochpos,channelpos,indexpos,dz,dy,:)-bl_mean)/bl_mean;
                        case 'divide'
                            out_data(epochpos,channelpos,indexpos,dz,dy,:)=data(epochpos,channelpos,indexpos,dz,dy,:)/bl_mean;
                        case 'subtract'
                            out_data(epochpos,channelpos,indexpos,dz,dy,:)=data(epochpos,channelpos,indexpos,dz,dy,:)-bl_mean;
                    end;
                end;
            end;
        end;
    end;
end;




