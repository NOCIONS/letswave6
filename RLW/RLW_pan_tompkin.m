function [out_header,out_data,message_string]=RLW_pan_tompkin(header,data,varargin);
%RLW_pan_tompkin
%
%Pan Tompkin QRS extractor
%
%varargin
%'channel' : channel label
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

channel_label='EK1';

%parse varagin
if isempty(varargin);
else
    %operation
    a=find(strcmpi(varargin,'channel_label'));
    if isempty(a);
    else
        channel_label=varargin{a+1};
    end;
end;

%init message_string
message_string={};

%prepare out_header
out_header=header;

%should be only one epoch
if length(header.datasize(1))>1
    disp('Only continuous data is allowed');
    exit;
end;

%init out_data
out_data=data;

%find EKG channel
for i=1:length(header.chanlocs);
    channel_labels{i}=header.chanlocs(i).labels;
end;
[a,channel_idx]=find(strcmpi(channel_labels,channel_label));

ecg=double(squeeze(data(1,channel_idx,1,1,1,:)));
fs=1/header.xstep;
gr=1;

%pan_tompkin function
[qrs_amp_raw,qrs_i_raw,delay]=pan_tompkin(ecg,fs,gr);

%add events
qrs_latencies=((qrs_i_raw-1)*header.xstep)+header.xstart;
for i=1:length(qrs_latencies);
    out_header.events(end+1)=header.events(end);
    out_header.events(end).code='QRS';
    out_header.events(end).epoch=1;
    out_header.events(end).latency=qrs_latencies(i);
end;

%add channel with QRS ISI
QRS_ISI=zeros(size(ecg));
qrs_isi_raw=zeros(size(qrs_i_raw));
for i=2:length(qrs_i_raw);
    qrs_isi_raw(i)=qrs_latencies(i)-qrs_latencies(i-1);
end;
for i=1:length(QRS_ISI);
    [a,b]=min(abs(qrs_i_raw-i));
    QRS_ISI(i)=qrs_isi_raw(b);
end;
out_data(1,end+1,1,1,1,:)=QRS_ISI;

%update header
out_header.datasize=size(out_data);
out_header.chanlocs(out_header.datasize(2))=out_header.chanlocs(end);
out_header.chanlocs(out_header.datasize(2)).labels='HR';
out_header.chanlocs(out_header.datasize(2)).topo_enabled=0;
out_header.chanlocs(out_header.datasize(2)).SEEG_enabled=0;







