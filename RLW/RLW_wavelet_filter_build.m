function [out_header,out_data,message_string]=RLW_wavelet_filter_build(header,data,selected_channel,varargin);
%RLW_wavelet_filter_build
%
%Build wavelet filter
%
%varargin
%
%'start_frequency' (1)
%'end_frequency' (30)
%'frequency_step' (1)
%'threshold' (0.85)
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

start_frequency=1;
end_frequency=40;
frequency_step=1;
threshold=0.85;

%parse varagin
if isempty(varargin);
else
    %start_frequency
    a=find(strcmpi(varargin,'start_frequency'));
    if isempty(a);
    else
        start_frequency=varargin{a+1};
    end;
    %end_frequency
    a=find(strcmpi(varargin,'end_frequency'));
    if isempty(a);
    else
    end_frequency=varargin{a+1};
    end;
    %frequency_step
    a=find(strcmpi(varargin,'frequency_step'));
    if isempty(a);
    else
        frequency_step=varargin{a+1};
    end;
    %threshold
    a=find(strcmpi(varargin,'threshold'));
    if isempty(a);
    else
        threshold=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='Build wavelet filter.';

%prepare out_header
out_header=header;

%init out_data
out_data=data;

%channel_idx
st={};
for i=1:length(header.chanlocs);
    st{i}=header.chanlocs(i).labels;
end;
a=find(strcmpi(selected_channel,st));
if isempty(a);
    message_string{end+1}='Selected channel not found. Exit!';
    return;
else
    channel_idx=a(1);
end;

%sampling rate
Fs=round(1/header.xstep);

%f
f=start_frequency:frequency_step:end_frequency;

%epoch_end
epoch_end=1:1:header.datasize(6);
epoch_end=((epoch_end-1)*header.xstep)+header.xstart;

%x_trials
x_trials=squeeze(data(:,channel_idx,1,1,1,:))';

%P_mask
[P_mask]=model_generation(x_trials,f,Fs,epoch_end,threshold);

%filter_data
out_data=[];
out_data(1,1,1,1,:,:)=P_mask;

%adjust filter_header using LW5 format (AM)
out_header.datasize=size(out_data);
out_header.ystart=f(1);
out_header.ystep=f(2)-f(1);
out_header.filetype=['frequency_' header.filetype];

%adjust channels (AM)
out_header.chanlocs=header.chanlocs(channel_idx);



