function [out_header,out_data,message_string]=RLW_wavelet_filter_apply(header,data,wfilt_header,wfilt_data,channel_name);
%RLW_wavelet_filter_apply
%
%Wavelet filter apply
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



%init message_string
message_string={};
message_string{1}='Apply wavelet filter';

%prepare out_header
out_header=header;

%channel_idx
st={};
for i=1:length(header.chanlocs);
    st{i}=header.chanlocs(i).labels;
end;
a=find(strcmpi(channel_name,st));
if isempty(a);
    message_string{end+1}='Selected channel not found. Exit!';
    return;
else
    channel_idx=a(1);
end;

%f, Fs
f=1:1:wfilt_header.datasize(5);
f=((f-1)*wfilt_header.ystep)+wfilt_header.ystart;
Fs=round(1/header.xstep);

%adjust header
out_header.datasize(2)=1;
out_header.datasize(3)=2;
out_header.indexlabels{1}='filtered';
out_header.indexlabels{2}='original';

%adjust channels
out_header.chanlocs=header.chanlocs(channel_idx);

%x_trials
x_trials=squeeze(data(:,channel_idx,1,1,1,:))';

%P_mask
P_mask=squeeze(wfilt_data(1,1,1,1,:,:));

% wavelet filtering
[f_trials]=tf_filtering(x_trials,f,Fs,P_mask);

%prepare data
out_data=zeros(out_header.datasize);

%update data
out_data(:,1,1,1,1,:)=f_trials';
out_data(:,1,2,1,1,:)=x_trials';

