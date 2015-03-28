function [out_header,out_data,message_string]=RLW_math(headerA,dataA,headerB,dataB,operation,varargin);
%RLW_math
%
%arithmetic operation between two datasets
%
%headerA,dataA
%headerB,dataB is reference dataset from which you can select a specific epoch/channel/label
%operation : 'A+B' 'A-B' 'B-A' 'A*B' 'A/B' 'B/A'
%varargin
%selected_epoch : 0 (all) or selected epoch
%selected_channel : 0 (all) or selected channel label
%selected_index : 0 (all) or selected  index
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

selected_epoch=0;
selected_channel=0;
selected_index=0;

%parse varagin
if isempty(varargin);
else
    %selected_epoch
    a=find(strcmpi(varargin,'selected_epoch'));
    if isempty(a);
    else
        selected_epoch=varargin{a+1};
    end;
    %selected_channel
    a=find(strcmpi(varargin,'selected_channel'));
    if isempty(a);
    else
        selected_channel=varargin{a+1};
    end;
    %selected_index
    a=find(strcmpi(varargin,'selected_index'));
    if isempty(a);
    else
        selected_index=varargin{a+1};
    end; 
end;

%init message_string
message_string={};

%prepare out_header
out_header=headerA;

%operation vectors
message_string{1}='preparing output data';
if selected_epoch==0;
    message_string{end+1}='process ALL epochs';
    selected_epoch_vector=1:out_header.datasize(1);
else
    message_string{end+1}=['process epoch : ' num2str(selected_epoch)];
    selected_epoch_vector=ones(out_header.datasize(1),1)*selected_epoch;
end;
if selected_channel==0;
    message_string{end+1}='process ALL channels';
    selected_channel_vector=1:out_header.datasize(2);
else
    message_string{end+1}=['process channel : ' selected_channel];
    for i=1:length(headerB.chanlocs);
        st{i}=headerB.chanlocs(i).labels;
    end;
    a=find(strcmpi(selected_channel,st));
    if isempty(a);
        message_string{end+1}='selected channel label not found';
        return;
    else
        selected_channel_vector=ones(out_header.datasize(2),1)*a(1);
    end;
end;
if selected_index==0;
    message_string{end+1}='process ALL indexes';
    selected_index_vector=1:out_header.datasize(3);
else
    message_string{end+1}=['process index : ' num2str(selected_index)];
    selected_index_vector=ones(out_header.datasize(3),1)*selected_index;
end;

%prepare out_data
out_data=zeros(out_header.datasize);

%loop through epochs
for epochpos=1:out_header.datasize(1);
    %loop through channels
    for chanpos=1:out_header.datasize(2);
        %loop through index
        for indexpos=1:out_header.datasize(3);
            switch operation
                case 'A+B'
                    out_data(epochpos,chanpos,indexpos,:,:,:)=dataA(epochpos,chanpos,indexpos,:,:,:)+dataB(selected_epoch_vector(epochpos),selected_channel_vector(chanpos),selected_index_vector(indexpos),:,:,:);
                case 'A-B'
                    out_data(epochpos,chanpos,indexpos,:,:,:)=dataA(epochpos,chanpos,indexpos,:,:,:)-dataB(selected_epoch_vector(epochpos),selected_channel_vector(chanpos),selected_index_vector(indexpos),:,:,:);
                case 'B-A'
                    out_data(epochpos,chanpos,indexpos,:,:,:)=dataB(selected_epoch_vector(epochpos),selected_channel_vector(chanpos),selected_index_vector(indexpos),:,:,:)-dataA(epochpos,chanpos,indexpos,:,:,:);
                case 'A*B'
                    out_data(epochpos,chanpos,indexpos,:,:,:)=dataA(epochpos,chanpos,indexpos,:,:,:).*dataB(selected_epoch_vector(epochpos),selected_channel_vector(chanpos),selected_index_vector(indexpos),:,:,:);
                case 'A/B'
                    out_data(epochpos,chanpos,indexpos,:,:,:)=dataA(epochpos,chanpos,indexpos,:,:,:)./dataB(selected_epoch_vector(epochpos),selected_channel_vector(chanpos),selected_index_vector(indexpos),:,:,:);
                case 'B/A'
                    out_data(epochpos,chanpos,indexpos,:,:,:)=dataB(selected_epoch_vector(epochpos),selected_channel_vector(chanpos),selected_index_vector(indexpos),:,:,:)./dataA(epochpos,chanpos,indexpos,:,:,:);
            end;
        end;
    end;
end;



    


