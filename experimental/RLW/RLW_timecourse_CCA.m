function [out_header,out_data,message_string]=RLW_timecourse_CCA(header,data,varargin)
% LW_timecourse_CCA
% get the time course CCA response for certain frequency points
%
%varargin
%'fre'
%'harmonic'
%'windowsize'
%'windowstep'
%
% Author :
% Gan Huang
% Institute of Neurosciences (IONS)
% Université catholique de louvain (UCL)
% Belgium
%
% Contact : andre.mouraux@uclouvain.be
% This function is part of Letswave 6
% See http://nocions.webnode.com/letswave for additional information

%parse varagin
if isempty(varargin);
else
    %fre
    a=find(strcmpi(varargin,'fre'));
    if isempty(a);
    else
        fre=varargin{a+1};
    end;
    %harmonic
    a=find(strcmpi(varargin,'harmonic'));
    if isempty(a);
    else
        harmonic=varargin{a+1};
    end;
    %windowsize
    a=find(strcmpi(varargin,'windowsize'));
    if isempty(a);
    else
        windowsize=varargin{a+1};
    end;
    %windowstep
    a=find(strcmpi(varargin,'windowstep'));
    if isempty(a);
    else
        windowstep=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='timecourse_CCA';

%warning
if strcmpi(header.filetype,'time_amplitude');
else
    message_string{end+1}='!!! WARNING : input data is not of format time_amplitude!';
end;

%out_header
out_header=header;



Fs=1/header.xstep;
win_size=round(windowsize/header.xstep);
win_step=round(windowstep/header.xstep);

t=header.xstart:header.xstep:header.xstart+header.xstep*(header.datasize(6)-1);
win_start=0:win_step:length(t)-win_size;
t_new=t(win_start+1)+(win_size-1)*header.xstep/2;
out_header.xstep=win_step*header.xstep;
out_header.xstart=t_new(1);
out_data=zeros(size(data,1),1,header.datasize(3),header.datasize(4),size(data,5),length(t_new));
out_header.chanlocs=out_header.chanlocs(1);
for k=1:6
    out_header.datasize(k)=size(out_data,k);
end

wave=[];
for k=1:harmonic
    wave=[wave;sin(2*pi*fre*k*(1:win_size)/Fs);cos(2*pi*fre*k*(1:win_size)/Fs)];
end
for epochpos=1:size(data,1)
    for indexpos=1:header.datasize(3)
        for dz=1:header.datasize(4)
            for dy=1:size(data,5)
                for k=1:length(win_start)
                    data_temp=squeeze(data(epochpos,:,indexpos,dz,dy,win_start(k)+(1:win_size)));
                    [~,~,r,~,~] = canoncorr(data_temp',wave');
                    out_data(epochpos,1,indexpos,dz,dy,k)=r(1);
                end
            end
        end
    end
end