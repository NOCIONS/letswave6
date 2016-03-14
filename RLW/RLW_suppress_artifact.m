function [out_header,out_data,message_string]=RLW_suppress_artifact(header,data,varargin);
%RLW_suppress_artifact
%
%Suppress artifact
%
%varargin
%xstart (-0.005)
%xend (+0.005)
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

xstart=-0.005
xend=+0.005;

%parse varagin
if isempty(varargin);
else
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
message_string{1}='suppress artifact.';

%prepare out_header
out_header=header;

%init out_data
out_data=data;

message_string{end+1}=['X1 = ' num2str(xstart) ' X2 = ' num2str(xend)];

%dx1,dx2
dx1=fix(((xstart-header.xstart)/header.xstep)+1);
dx2=fix(((xend-header.xstart)/header.xstep)+1);
message_string{end+1}=['DX1 = ' num2str(dx1) ' DX2 = ' num2str(dx2)];

%xv
xv=[dx1 dx2];

%xi
xi=dx1:dx2;

%loop
for epochpos=1:header.datasize(1);
    for chanpos=1:header.datasize(2);
        for indexpos=1:header.datasize(3);
            for dz=1:header.datasize(4);
                for dy=1:header.datasize(5);
                    yv=squeeze(data(epochpos,chanpos,indexpos,dz,dy,[dx1 dx2]));
                    yi=interp1(xv,yv,xi);
                    out_data(epochpos,chanpos,indexpos,dz,dy,dx1:dx2)=yi;
                end;
            end;
        end;
    end;
end;

