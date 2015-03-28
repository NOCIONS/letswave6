function [out_header,out_data,message_string]=RLW_bootstrap_reference(header,data,varargin);
%RLW_bootstrap_reference
%
%Bootstrap test against a reference interval
%
%varargin
%'channel_labels' ({})
%'ref_start' (header.xstart)
%'ref_end' (0)
%'num_iterations' (1000)
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

channel_labels={};
ref_start=header.xstart;
ref_end=0;
num_iterations=1000;

%parse varagin
if isempty(varargin);
else
    %channel_labels
    a=find(strcmpi(varargin,'channel_labels'));
    if isempty(a);
    else
        channel_labels=varargin{a+1};
    end;
    %ref_start
    a=find(strcmpi(varargin,'ref_start'));
    if isempty(a);
    else
        ref_start=varargin{a+1};
    end;
    %ref_end
    a=find(strcmpi(varargin,'ref_end'));
    if isempty(a);
    else
        ref_end=varargin{a+1};
    end;
    %num_iterations
    a=find(strcmpi(varargin,'num_iterations'));
    if isempty(a);
    else
        num_iterations=varargin{a+1};
    end;
end;

%init message_string
message_string={};

%prepare out_header
out_header=header;

%init out_data
out_data=data;

%baseline_interval
baseline_interval(1)=ref_start;
baseline_interval(2)=ref_end;
message_string{1}=['Reference interval : ' num2str(baseline_interval(1)) ' - ' num2str(baseline_interval(2))];

%channel_idx
st={};
for i=1:length(header.chanlocs);
    st{i}=header.chanlocs(i).labels;
end;
channel_idx=[];
for i=1:length(channel_labels);
    a=find(strcmpi(channel_labels{i},st));
    channel_idx=[channel_idx a];
end;

%define the time vector of the original data
t=header.xstart:header.xstep:(header.xstart+(size(data,6)-1)*header.xstep);

% define the frequency vector of the original data
f=header.ystart:header.ystep:(header.ystart+(size(data,5)-1)*header.ystep);
            
% baseline index, unit: sec
t_base_idx=find((t>=baseline_interval(1)) & (t<=baseline_interval(2)));

%bootstrap
for i=1:length(channel_idx)
    for j=1:size(data,1)
        tp(:,:,j)=squeeze(data(j,channel_idx(i),1,1,:,:));% freq*time*epoch;
    end;
    if size(data,5)>1;
        data_to_test=tp;
    else
        data_to_test(1,:,:)=tp;
    end;
    [pvals_btstrp(i,:,:),pvals_btstrp_r(i,:,:),pvals_btstrp_l(i,:,:) ]=sub_tfd_bootstrp(data_to_test(:,t_base_idx,:),data_to_test,num_iterations);
end;
            
%pvals_btstrp(chan,freq,time)
%out_data
if size(data,5)>1;
    for chanpos=1:length(channel_idx);
        out_data(1,chanpos,1,1,:,:)=pvals_btstrp(chanpos,:,:);
    end;
else
    for chanpos=1:length(channel_idx);
        out_data(1,chanpos,1,1,1,:)=pvals_btstrp(chanpos,:);
    end;
end;

%adjust outheader.datasize
out_header.datasize=size(out_data);

%adjust out_header.chanlocs
out_header.chanlocs=out_header.chanlocs(channel_idx);

%adjust events
if isfield(out_header,'events');
    for event_pos=1:length(out_header.events);
        out_header.events(event_pos).epoch=1;
    end;
end;

%delete epochdata
if isfield(out_header,'epochdata');
    rmfield(out_header,'epochdata');
end;




