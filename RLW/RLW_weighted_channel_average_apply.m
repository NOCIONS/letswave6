function [out_header,out_data,message_string]=RLW_weighted_channel_average_apply(header,data,varargin);
%RLW_channel_average_apply
%
%Channel average apply
%
%varargin
%'template_labels'
%'template_weights'
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

template_weights=[];
template_labels=[];

%parse varagin
if isempty(varargin);
else
    %template_labels
    a=find(strcmpi(varargin,'template_labels'));
    if isempty(a);
    else
        template_labels=varargin{a+1};
    end;
    %template_weights
    a=find(strcmpi(varargin,'template_weights'));
    if isempty(a);
    else
        template_weights=varargin{a+1};
    end;
end;

%out_header
out_header=header;
out_header.datasize(2)=1;
out_header.chanlocs=[];
out_header.chanlocs(1).labels='chanavg';
out_header.chanlocs(1).topo_enabled=0;
out_header.chanlocs(1).SEEG_enabled=0;

%out_data
out_data=zeros(out_header.datasize);

%init message_string
message_string={};
message_string{1}='Apply weighted channel average template';

%header channel labels
for i=1:length(header.chanlocs);
    st{i}=header.chanlocs(i).labels;
end;

%chan_idx
for i=1:length(template_labels);
    a=find(strcmpi(template_labels{i},st));
    if isempty(a);
    else
        chan_idx(i)=a(1);
    end;
end;

if length(chan_idx)==length(template_weights);
else
    message_string{end+1}='Not all channels were found. Cannot apply template';
    return;
end;

%loop
for epochpos=1:header.datasize(1);
    for indexpos=1:header.datasize(3);
        for dz=1:header.datasize(4);
            for dy=1:header.datasize(5);
                for dx=1:header.datasize(6);
                    out_data(epochpos,1,indexpos,dz,dy,dx)=sum(squeeze(data(epochpos,chan_idx,indexpos,dz,dy,dx)).*template_weights);
                end;
            end;
        end;
    end;
end;

%divide by sum of weights
out_data=out_data/sum(template_weights);
