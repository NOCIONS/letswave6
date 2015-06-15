function [out_header,out_data,message_string]=RLW_downsample(header,data,varargin);
%RLW_downsample
%
%Downsample
%
%varargin
%'x_downsample_ratio' (1)
%'y_downsample_ratio' (1)
%'z_downsample_ratio' (1)
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

x_downsample_ratio=1;
y_downsample_ratio=1;
z_downsample_ratio=1;

%parse varagin
if isempty(varargin);
else
    %x_downsample_ratio
    a=find(strcmpi(varargin,'x_downsample_ratio'));
    if isempty(a);
    else
        x_downsample_ratio=varargin{a+1};
    end;
    %y_downsample_ratio
    a=find(strcmpi(varargin,'y_downsample_ratio'));
    if isempty(a);
    else
        y_downsample_ratio=varargin{a+1};
    end;
    %z_downsample_ratio
    a=find(strcmpi(varargin,'z_downsample_ratio'));
    if isempty(a);
    else
        z_downsample_ratio=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}=['X downsampling ratio : ' num2str(x_downsample_ratio)];
message_string{2}=['Y downsampling ratio : ' num2str(y_downsample_ratio)];
message_string{3}=['Z downsampling ratio : ' num2str(z_downsample_ratio)];

%prepare out_header
out_header=header;

%adjust xstep,ystep,zstep
out_header.xstep=header.xstep*x_downsample_ratio;
out_header.ystep=header.ystep*y_downsample_ratio;
out_header.zstep=header.zstep*z_downsample_ratio;

%set xvector,yvector,zvector
zvector=1:z_downsample_ratio:header.datasize(4);
yvector=1:y_downsample_ratio:header.datasize(5);
xvector=1:x_downsample_ratio:header.datasize(6);

%adjust out_header.datasize
out_header.datasize(4)=length(zvector);
out_header.datasize(5)=length(yvector);
out_header.datasize(6)=length(xvector);

%update data
out_data=data(:,:,:,zvector,yvector,xvector);



