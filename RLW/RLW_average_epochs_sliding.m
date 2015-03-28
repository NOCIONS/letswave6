function [out_header,out_data,message_string]=RLW_average_epochs_sliding(header,data,varargin);
%RLW_average_epochs_sliding
%
%Sliding average across epochs
%
%header
%data
%
%varargin
%
%'operation' ('average'); 'average' 'stdev' 'max' 'min' 'perc75' 'perc25' 'maxminmean'
%'dimension ('x'); 'x' 'y' 'z'
%'width' (0.2)
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
dimension='x';
width=0.2;

%parse varagin
if isempty(varargin);
else
    %operation
    a=find(strcmpi(varargin,'operation'));
    if isempty(a);
    else
        operation=varargin{a+1};
    end;
    %dimension
    a=find(strcmpi(varargin,'dimension'));
    if isempty(a);
    else
        dimension=varargin{a+1};
    end;
    %width
    a=find(strcmpi(varargin,'width'));
    if isempty(a);
    else
        width=varargin{a+1};
    end;
end;


%init message_string
message_string={};
message_string{1}=['Operation : ' operation];
message_string{2}=['Dimension : ' dimension];
message_string{3}=['Window width : ' num2str(width)];

%prepare out_header
out_header=header;

%prepare out_data
out_data=zeros(size(data));

%binwidth
switch dimension
    case 'x'
        binwidth=round(width/header.xstep);
        binwidth2=round(binwidth/2);
    case 'y'
        binwidth=round(width/header.ystep);
        binwidth2=round(binwidth/2);
    case 'z'
        binwidth=round(width/header.zstep);
        binwidth2=round(binwidth/2);
end;

%loop
switch dimension
    case 'x'
        for dx=1:header.datasize(6);
            dx1=dx-binwidth2;
            dx2=dx+binwidth2;
            if dx1<1;
                dx1=1;
            end;
            if dx2>header.datasize(6);
                dx2=header.datasize(6);
            end;
            switch operation
                case 'average'
                    out_data(:,:,:,:,:,dx)=mean(data(:,:,:,:,:,dx1:dx2),6);
                case 'stdev'
                    out_data(:,:,:,:,:,dx)=std(data(:,:,:,:,:,dx1:dx2),0,6);
                case 'max'
                    out_data(:,:,:,:,:,dx)=max(data(:,:,:,:,:,dx1:dx2),[],6);
                case 'min'
                    out_data(:,:,:,:,:,dx)=min(data(:,:,:,:,:,dx1:dx2),[],6);
                case 'perc75'
                    out_data(:,:,:,:,:,dx)=prctile(data(:,:,:,:,:,dx1:dx2),75,6);
                case 'perc25'
                    out_data(:,:,:,:,:,dx)=prctile(data(:,:,:,:,:,dx1:dx2),25,6);
                case 'maxminmean'
                    out_data(:,:,:,:,:,dx)=(max(data(:,:,:,:,:,dx1:dx2),[],6)-mean(data(:,:,:,:,:,dx1:dx2),6)).*(mean(data(:,:,:,:,:,dx1:dx2),6)-min(data(:,:,:,:,:,dx1:dx2),[],6));
            end;
        end;
    case 'y'
        for dy=1:header.datasize(5);
            dy1=dy-binwidth2;
            dy2=dy+binwidth2;
            if dy1<1;
                dy1=1;
            end;
            if dy2>header.datasize(5);
                dy2=header.datasize(5);
            end;
            switch configuration.parameters.operation
                case 'average'
                    out_data(:,:,:,:,dy,:)=mean(data(:,:,:,:,dy1:dy2,:),5);
                case 'stdev'
                    out_data(:,:,:,:,dy,:)=std(data(:,:,:,:,dy1:dy2,:),0,5);
                case 'max'
                    out_data(:,:,:,:,dy,:)=max(data(:,:,:,:,dy1:dy2,:),[],5);
                case 'min'
                    out_data(:,:,:,:,dy,:)=min(data(:,:,:,:,dy1:dy2,:),[],5);
                case 'perc75'
                    out_data(:,:,:,:,dy,:)=prctile(data(:,:,:,:,dy1:dy2,:),75,5);
                case 'perc25'
                    out_data(:,:,:,:,dy,:)=prctile(data(:,:,:,:,dy1:dy2,:),25,5);
                case 'maxminmean'
                    out_data(:,:,:,:,dy,:)=(max(data(:,:,:,:,dy1:dy2,:),[],5)-mean(data(:,:,:,:,dy1:dy2,:),5)).*(mean(data(:,:,:,:,dy1:dy2,:),5)-min(data(:,:,:,:,dy1:dy2,:),[],5));
            end;
        end;
    case 'z'
        for dz=1:header.datasize(4);
            dz1=dz-binwidth2;
            dz2=dz+binwidth2;
            if dz1<1;
                dz1=1;
            end;
            if dz2>header.datasize(4);
                dz2=header.datasize(4);
            end;
            switch configuration.parameters.operation
                case 'average'
                    out_data(:,:,:,dz,:,:)=mean(data(:,:,:,dz1:dz2,:,:),4);
                case 'stdev'
                    out_data(:,:,:,dz,:,:)=std(data(:,:,:,dz1:dz2,:,:),0,4);
                case 'max'
                    out_data(:,:,:,dz,:,:)=max(data(:,:,:,dz1:dz2,:,:),[],4);
                case 'min'
                    out_data(:,:,:,dz,:,:)=min(data(:,:,:,dz1:dz2,:,:),[],4);
                case 'perc75'
                    out_data(:,:,:,dz,:,:)=prctile(data(:,:,:,dz1:dz2,:,:),75,4);
                case 'perc25'
                    out_data(:,:,:,dz,:,:)=prctile(data(:,:,:,dz1:dz2,:,:),25,4);
                case 'maxminmean'
                    out_data(:,:,:,dz,:,:)=(max(data(:,:,:,dz1:dz2,:,:),[],4)-mean(data(:,:,:,dz1:dz2,:,:),4)).*(mean(data(:,:,:,dz1:dz2,:,:),4)-min(data(:,:,:,dz1:dz2,:,:),[],4));
            end;
        end;
end;


