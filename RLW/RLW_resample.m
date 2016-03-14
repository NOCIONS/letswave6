function [out_header,out_data,message_string]=RLW_resample(header,data,varargin);
%RLW_resample
%
%Resample
%
%varargin
%
%'resample_x'=0;
%'resample_y'=0;
%'resample_z'=0;
%'x_sampling_rate'=1;
%'y_sampling_rate'=1;
%'z_sampling_rate'=1;
%'interpolation_method' 'nearest','linear','spline','pchip','cubic','v5cubic'
%
%
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

resample_x=0;
resample_y=0;
resample_z=0;
if header.datasize(6)>1;
    x_sampling_rate=1/header.xstep;
else
    x_sampling_rate=1;
end;
if header.datasize(5)>1;
    y_sampling_rate=1/header.ystep;
else
    y_sampling_rate=1;
end;
if header.datasize(4)>1;
    z_sampling_rate=1/header.zstep;
else
    z_sampling_rate=1;
end;
interpolation_method='spline';

%parse varagin
if isempty(varargin);
else
    %resample_x
    a=find(strcmpi(varargin,'resample_x'));
    if isempty(a);
    else
        resample_x=varargin{a+1};
    end;
    %resample_y
    a=find(strcmpi(varargin,'resample_y'));
    if isempty(a);
    else
        resample_y=varargin{a+1};
    end;
    %resample_z
    a=find(strcmpi(varargin,'resample_z'));
    if isempty(a);
    else
        resample_z=varargin{a+1};
    end;
    %x_sampling_rate
    a=find(strcmpi(varargin,'x_sampling_rate'));
    if isempty(a);
    else
        x_sampling_rate=varargin{a+1};
    end;
    %y_sampling_rate
    a=find(strcmpi(varargin,'y_sampling_rate'));
    if isempty(a);
    else
        y_sampling_rate=varargin{a+1};
    end;
    %z_sampling_rate
    a=find(strcmpi(varargin,'z_sampling_rate'));
    if isempty(a);
    else
        z_sampling_rate=varargin{a+1};
    end;
    %interpolation_method
    a=find(strcmpi(varargin,'interpolation_method'));
    if isempty(a);
    else
        interpolation_method=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='resample signals';

%prepare out_header
out_header=header;

%tpx,tpy,tpz (original srate)
tpx=1:1:header.datasize(6);
tpy=1:1:header.datasize(5);
tpz=1:1:header.datasize(4);
tpx=((tpx-1)*header.xstep)+header.xstart;
tpy=((tpy-1)*header.ystep)+header.ystart;
tpz=((tpz-1)*header.zstep)+header.zstart;

%ntpx,ntpy,ntpz (new srate)
%ntpx
ntpx=[];
if resample_x==1;
    xstart=header.xstart;
    xend=((header.datasize(6)-1)*header.xstep)+header.xstart;
    xstep=1/x_sampling_rate;
    ntpx=xstart:xstep:xend;
end;
%ntpy
ntpy=[];
if resample_y==1;
    ystart=header.ystart;
    yend=((header.datasize(5)-1)*header.ystep)+header.ystart;
    ystep=1/y_sampling_rate;
    ntpy=ystart:ystep:yend;
end;
%ntpz
ntpz=[];
if resample_z==1;
    zstart=header.zstart;
    zend=((header.datasize(4)-1)*header.zstep)+header.zstart;
    zstep=1/z_sampling_rate;
    ntpz=zstart:zstep:zend;
end;

%adjust xstep,ystep,zstep / xsize,ysize,zsize
if resample_x==1;
    out_header.xstep=1/x_sampling_rate;
    out_header.datasize(6)=length(ntpx);
end;
if resample_y==1;
    out_header.ystep=1/y_sampling_rate;
    out_header.datasize(5)=length(ntpy);
end;
if resample_z==1;
    out_header.zstep=1/z_sampling_rate;
    out_header.datasize(4)=length(ntpz);
end;

%prepare out_data
out_data=zeros(out_header.datasize);

%method
message_string{end+1}=['Interpolation method : ' interpolation_method];

%interp3 (X/Y/Z)
if (resample_x==1)&(resample_y==1)&(resample_z==1);
    message_string{end+1}='3D interpolation (X/Y/Z)';
    %loop through epochs
    for epochpos=1:header.datasize(1);
        for chanpos=1:header.datasize(2);
            for indexpos=1:header.datasize(3);
                out_data(epochpos,chanpos,indexpos,:,:,:)=interp3(tpz,tpy,tpx,squeeze(data(epochpos,chanpos,indexpos,:,:,:)),ntpz,ntpy,ntpx,interpolation_method);
            end;
        end;
    end;
end;

%interp2 (X/Y)
if (resample_x==1)&(resample_y==1)&(resample_z==0);
    message_string{end+1}='2D interpolation (X/Y)';
    %loop through epochs
    for epochpos=1:header.datasize(1);
        for chanpos=1:header.datasize(2);
            for indexpos=1:header.datasize(3);
                for dz=1:header.datasize(4);
                    out_data(epochpos,chanpos,indexpos,dz,:,:)=interp2(tpy,tpx,squeeze(data(epochpos,chanpos,indexpos,dz,:,:)),ntpy,ntpx,interpolation_method);
                end;
            end;
        end;
    end;
end;

%interp2 (X/Z)
if (resample_x==1)&(resample_y==0)&(resample_z==1);
    message_string{end+1}='2D interpolation (X/Z)';
    %loop through epochs
    for epochpos=1:header.datasize(1);
        for chanpos=1:header.datasize(2);
            for indexpos=1:header.datasize(3);
                for dy=1:header.datasize(5);
                    out_data(epochpos,chanpos,indexpos,:,dy,:)=interp2(tpz,tpx,squeeze(data(epochpos,chanpos,indexpos,:,dy,:)),ntpz,ntpx,interpolation_method);
                end;
            end;
        end;
    end;
end;

%interp2 (Y/Z)
if (resample_x==0)&(resample_y==1)&(resample_z==1);
    message_string{end+1}='2D interpolation (Y/Z)';
    %loop through epochs
    for epochpos=1:header.datasize(1);
        for chanpos=1:header.datasize(2);
            for indexpos=1:header.datasize(3);
                for dx=1:header.datasize(6);
                    out_data(epochpos,chanpos,indexpos,:,:,dx)=interp2(tpz,tpy,squeeze(data(epochpos,chanpos,indexpos,:,:,dx)),ntpz,ntpy,interpolation_method);
                end;
            end;
        end;
    end;
end;

%interp1 (X)
if (resample_x==1)&(resample_y==0)&(resample_z==0);
    message_string{end+1}='1D interpolation (X)';
    %loop through epochs
    for epochpos=1:header.datasize(1);
        for chanpos=1:header.datasize(2);
            for indexpos=1:header.datasize(3);
                for dz=1:header.datasize(4);
                    for dy=1:header.datasize(5);
                        out_data(epochpos,chanpos,indexpos,dz,dy,:)=interp1(tpx,squeeze(data(epochpos,chanpos,indexpos,dz,dy,:)),ntpx,interpolation_method);
                    end;
                end;
            end;
        end;
    end;
end;

%interp1 (Y)
if (resample_x==0)&(resample_y==1)&(resample_z==0);
    message_string{end+1}='1D interpolation (Y)';
    %loop through epochs
    for epochpos=1:header.datasize(1);
        for chanpos=1:header.datasize(2);
            for indexpos=1:header.datasize(3);
                for dz=1:header.datasize(4);
                    for dx=1:header.datasize(6);
                        out_data(epochpos,chanpos,indexpos,dz,:,dx)=interp1(tpy,squeeze(data(epochpos,chanpos,indexpos,dz,:,dx)),ntpy,interpolation_method);
                    end;
                end;
            end;
        end;
    end;
end;

%interp1 (Z)
if (resample_x==0)&(resample_y==0)&(resample_z==1);
    message_string{end+1}='1D interpolation (Z)';
    %loop through epochs
    for epochpos=1:header.datasize(1);
        for chanpos=1:header.datasize(2);
            for indexpos=1:header.datasize(3);
                for dy=1:header.datasize(5);
                    for dx=1:header.datasize(6);
                        out_data(epochpos,chanpos,indexpos,:,dy,dx)=interp1(tpz,squeeze(data(epochpos,chanpos,indexpos,:,dy,dx)),ntpz,interpolation_method);
                    end;
                end;
            end;
        end;
    end;
end;


