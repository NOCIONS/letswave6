function [template_weights,template_labels,message_string]=RLW_weighted_channel_average_template(header,data,varargin);
%RLW_channel_average_template
%
%Channel average template
%
%varargin
%'selected_channels' []
%'num_channels' (6)
%'x' (0)
%'y' (0)
%'z' (0)
%'epoch' (1)
%'index' (1)
%'peakdir' ('max')
%'normalize' (1)
%
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

for i=1:length(header.chanlocs);
    selected_channels{i}=header.chanlocs(i).labels;
end;
num_channels=6;
x=0;
y=0;
z=0;
epoch=1;
index=1;
peakdir='max';
normalize=1;

template_weights=[];
template_labels=[];


%parse varagin
if isempty(varargin);
else
    %selected_channels
    a=find(strcmpi(varargin,'selected_channels'));
    if isempty(a);
    else
        selected_channels=varargin{a+1};
    end;
    %num_channels
    a=find(strcmpi(varargin,'num_channels'));
    if isempty(a);
    else
        num_channels=varargin{a+1};
    end;
    %x
    a=find(strcmpi(varargin,'x'));
    if isempty(a);
    else
        x=varargin{a+1};
    end;
    %y
    a=find(strcmpi(varargin,'y'));
    if isempty(a);
    else
        y=varargin{a+1};
    end;
    %z
    a=find(strcmpi(varargin,'z'));
    if isempty(a);
    else
        z=varargin{a+1};
    end;
    %epoch
    a=find(strcmpi(varargin,'epoch'));
    if isempty(a);
    else
        epoch=varargin{a+1};
    end;
    %index
    a=find(strcmpi(varargin,'index'));
    if isempty(a);
    else
        index=varargin{a+1};
    end;
    %peakdir
    a=find(strcmpi(varargin,'peakdir'));
    if isempty(a);
    else
        peakdir=varargin{a+1};
    end;
    %normalize
    a=find(strcmpi(varargin,'normalize'));
    if isempty(a);
    else
        normalize=varargin{a+1};
    end;
end;


%init message_string
message_string={};
message_string{1}='Create weighted channel average template';

message_string{end+1}=['Number of channels to include : ' num2str(num_channels)];

%adjust epoch_pos, index_pos
if header.datasize(1)==1;
    epoch=1;
end;
if header.datasize(3)==1;
    index=1;
end;

%chan_idx
st={};
for i=1:length(header.chanlocs);
    st{i}=header.chanlocs(i).labels;
end;
chan_idx=[];
for i=1:length(selected_channels);
    a=find(strcmpi(selected_channels{i},st));
    chan_idx=[chan_idx a];
end;
message_string{end+1}=[num2str(length(chan_idx)) ' channels with matching labels.'];

%fetch vector
dx=round(((x-header.xstart)/header.xstep))+1;
if header.datasize(4)==1;
    dz=1;
else
    dz=round(((z-header.zstart)/header.zstep))+1;
end;
if header.datasize(5)==1;
    dy=1;
else
    dy=round(((y-header.ystart)/header.ystep))+1;
end;
chan_vector=squeeze(data(epoch,chan_idx,index,dz,dy,dx));

%sort
switch peakdir
    case 'max'
        [Y,I]=sort(chan_vector,'descend');
        chan_idx=chan_idx(I(1:num_channels));
        chan_weights=Y(1:num_channels);
    case 'min'
        [Y,I]=sort(chan_vector,'ascend');
        chan_idx=chan_idx(I(1:num_channels));
        chan_weights=Y(1:num_channels);
    case 'absmax'
        chan_vector=abs(chan_vector);
        [Y,I]=sort(chan_vector,'descend');
        chan_idx=chan_idx(I(1:num_channels));
        chan_weights=Y(1:num_channels);
end;

%normalize
if normalize==1;
    chan_weights=chan_weights/sum(chan_weights);
end;

template_weights=chan_weights;
template_labels=st(chan_idx);
