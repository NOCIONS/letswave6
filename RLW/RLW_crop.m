function [out_header,out_data,message_string]=RLW_crop(header,data,varargin);
%RLW_crop
%
%Crop epochs
%
%varargin
%'x_crop' (0)
%'y_crop' (0)
%'z_crop' (0)
%'x_start' (0)
%'x_size' (0)
%'y_start' (0)
%'y_size' (0)
%'z_start' (0)
%'z_size' (0)
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

x_crop=0;
y_crop=0;
z_crop=0;
x_start=0;
y_start=0;
z_start=0;
x_size=0;
y_size=0;
z_size=0;

%parse varagin
if isempty(varargin);
else
    %x_crop
    a=find(strcmpi(varargin,'x_crop'));
    if isempty(a);
    else
        x_crop=varargin{a+1};
    end;
    %y_crop
    a=find(strcmpi(varargin,'y_crop'));
    if isempty(a);
    else
        y_crop=varargin{a+1};
    end;
    %z_crop
    a=find(strcmpi(varargin,'z_crop'));
    if isempty(a);
    else
        z_crop=varargin{a+1};
    end;
    %x_start
    a=find(strcmpi(varargin,'x_start'));
    if isempty(a);
    else
        x_start=varargin{a+1};
    end;
    %y_start
    a=find(strcmpi(varargin,'y_start'));
    if isempty(a);
    else
        y_start=varargin{a+1};
    end;
    %z_start
    a=find(strcmpi(varargin,'z_start'));
    if isempty(a);
    else
        z_start=varargin{a+1};
    end;
    %x_size
    a=find(strcmpi(varargin,'x_size'));
    if isempty(a);
    else
        x_size=varargin{a+1};
    end;
    %y_size
    a=find(strcmpi(varargin,'y_size'));
    if isempty(a);
    else
        y_size=varargin{a+1};
    end;
    %z_size
    a=find(strcmpi(varargin,'z_size'));
    if isempty(a);
    else
        z_size=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='Crop epochs';

%prepare out_header
out_header=header;

%adjust xsize,ysize,zsize / xstart,ystart,zstart / dxstart,dystart,dzstart
if x_crop==1;
    message_string{end+1}='Crop X dimension';
    dxstart=round(((x_start-header.xstart)/header.xstep))+1;
    dxend=(dxstart+x_size)-1;
    out_header.datasize(6)=x_size;
    out_header.xstart=x_start;
else
    dxstart=1;
    dxend=header.datasize(6);
end;
if y_crop==1;
    message_string{end+1}='Crop Y dimension';
    dystart=round(((y_start-header.ystart)/header.ystep))+1;
    dyend=(dystart+y_size)-1;
    out_header.datasize(5)=y_size;
    out_header.ystart=y_start;
else
    dystart=1;
    dyend=header.datasize(5);
end;
if z_crop==1;
    message_string{end+1}='Crop Z dimension';
    dzstart=round(((z_start-header.zstart)/header.zstep))+1;
    dzend=(dzstart+z_size)-1;
    out_header.datasize(4)=z_size;
    out_header.zstart=z_start;
else
    dzstart=1;
    dzend=header.datasize(4);
end;


%crop
out_data=data(:,:,:,dzstart:dzend,dystart:dyend,dxstart:dxend);



