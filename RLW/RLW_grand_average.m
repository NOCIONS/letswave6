function [out_header,out_data,message_string]=RLW_grand_average(datasets,varargin);
%RLW_grand_average
%
%Grand Average
%
%datasets : structured array of datasets(i).header and datasets(i).data
%
%varargin
%'dataset_weights' : array of weight vectors for each dataset (default 1)
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

for i=1:length(datasets);
    dataset_weights(i)=1;
end;

%parse varagin
if isempty(varargin);
else
    %operation
    a=find(strcmpi(varargin,'dataset_weights'));
    if isempty(a);
    else
        dataset_weights=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='Computing ...';

%prepare out_header
out_header=datasets(1).header;

%adjust datasize
out_header.datasize(1)=1;

%prepare out_data
out_data=zeros(out_header.datasize);

%loop through datasets
for setpos=1:length(datasets);
    message_string{end+1}=['Dataset : ' datasets(setpos).header.name ' - weight : ' num2str(dataset_weights(setpos))];
    %data, average if needed
    if datasets(setpos).header.datasize(1)>1;
        data=mean(datasets(setpos).data,1);
    else
        data=datasets(setpos).data;
    end;
    %add
    out_data=out_data+(data*dataset_weights(setpos));
end;

%divide by sum of weights
out_data=out_data/sum(dataset_weights);


