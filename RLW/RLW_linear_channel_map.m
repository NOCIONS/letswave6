function [out_header,out_data,message_string]=RLW_linear_channel_map(header,data,varargin);
%RLW_linear_channel_map
%
%Linear channel map
%
%varargin
%'num_lines' (100)
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

num_lines=100;

%parse varagin
if isempty(varargin);
else
    %num_lines
    a=find(strcmpi(varargin,'num_lines'));
    if isempty(a);
    else
        num_lines=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='Linear channel map';

%prepare out_header
out_header=header;

%dy
dy=1;

%dz
dz=1;

%check datasize
if header.datasize(4)>1;
    message_string{end+1}='Z dimension greater than 1, first bin will be used to compute the channel map';
end;
if header.datasize(5)>1;
    message_string{end+1}='Y dimension greater than 1, first bin will be used to compute the channel map';
end;

%out_header.chanlocs
out_header.chanlocs=[];
out_header.chanlocs(1).labels='CSD';
out_header.chanlocs(1).topo_enabled=0;
out_header.chanlocs(1).SEEG_enabled=0;

%meshgrid xi,yi
xi=1:1:header.datasize(6);
xi=((xi-1)*header.xstep)+header.xstart;
yi=linspace(1,header.datasize(2),num_lines);

%out_header ystart, ystep
out_header.ystart=yi(1);
out_header.ystep=yi(2)-yi(1);

%meshgrid
[xi,yi]=meshgrid(xi,yi);
%meshgrid x,y
x=1:1:header.datasize(6);
x=((x-1)*header.xstep)+header.xstart;
y=1:1:header.datasize(2);
[x,y]=meshgrid(x,y);

%adjust datasize
out_header.datasize(2)=1; %one single channel
out_header.datasize(4)=1;
out_header.datasize(5)=num_lines;

%prepare out_data
out_data=zeros(out_header.datasize);

%csd_maker
for epochpos=1:header.datasize(1);
    for indexpos=1:header.datasize(3);
        %interp
        tp=squeeze(data(epochpos,:,indexpos,dz,dy,:));
        out_data(epochpos,1,indexpos,1,:,:)=interp2(x,y,tp,xi,yi,'cubic');
    end;
end;



