function [out_header,out_data,message_string]=RLW_timecourse_FT(header,data,varargin)
% LW_timecourse_FT
% get the time course Fourier transformed response for certain frequency points
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
message_string{1}='timecourse_FT';

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
hann_win =hann(win_size);

t=header.xstart:header.xstep:header.xstart+header.xstep*(header.datasize(6)-1);
win_start=0:win_step:length(t)-win_size;
t_new=t(win_start+1)+(win_size-1)*header.xstep/2;
out_header.xstep=win_step*header.xstep;
out_header.xstart=t_new(1);
out_data=zeros(size(data,1),size(data,2),header.datasize(3),header.datasize(4),size(data,5),length(t_new));
for k=1:6
out_header.datasize(k)=size(out_data,k);
end

wave=[];
for k=1:harmonic
    wave=[wave;sin(2*pi*fre*k*(1:win_size)/Fs);cos(2*pi*fre*k*(1:win_size)/Fs)];
end
for epochpos=1:size(data,1)
    for chanpos=1:header.datasize(2)
        for indexpos=1:header.datasize(3)
            for dz=1:header.datasize(4)
                for dy=1:size(data,5)
                    for k=1:length(win_start)
                        data_temp=squeeze(data(epochpos,chanpos,indexpos,dz,dy,win_start(k)+(1:win_size))).*hann_win;
                        out_data(epochpos,chanpos,indexpos,dz,dy,k)=norm(wave*data_temp)/(win_size)/mean(hann_win);
                    end
                end
            end
        end
    end
end
