function [out_datasets,message_string]=RLW_equalize_epochs(datasets,varargin);
%RLW_equalize_epochs
%
%Equalize number of epochs across datasets
%
%varargin
%'num_epochs' (0) if 0, will select the maximum number of epochs
%'random_selection' (0)
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

num_epochs=0;
random_selection=0;

%parse varagin
if isempty(varargin);
else
    %num_epochs
    a=find(strcmpi(varargin,'num_epochs'));
    if isempty(a);
    else
        num_epochs=varargin{a+1};
    end;
    %random_selection
    a=find(strcmpi(varargin,'random_selection'));
    if isempty(a);
    else
        random_selection=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='Equalize epochs.';

%find smallest number of epochs across datasets
if num_epochs==0;
    tpi=[];
    for setpos=1:length(datasets);
        tpi(setpos)=datasets(setpos).header.datasize(1);
    end;
    num_epochs=min(tpi);
end;

%datasets
for setpos=1:length(datasets);
    
    %epoch_idx
    if random_selection==0;
        %sequential
        epoch_idx=1:1:num_epochs;
    else
        %random
        rnd_idx=rand(datasets(setpos).header.datasize(1),1);
        [a b]=sort(rnd_idx);
        epoch_idx=b(1:num_epochs);
    end;
    
    %data
    out_datasets(setpos).data=datasets(setpos).data(epoch_idx,:,:,:,:,:);
    
    %header
    out_datasets(setpos).header=datasets(setpos).header;
    
    %change number of epochs
    out_datasets(setpos).header.datasize(1)=length(epoch_idx);
    
    %adjust events
    if isfield(out_datasets(setpos).header,'events');
        if isempty(out_datasets(setpos).header.events);
        else
            for i=1:length(out_datasets(setpos).header.events);
                event_epoch_idx(i)=out_datasets(setpos).header.events(i).epoch;
            end;
            new_events=[];
            for i=1:length(epoch_idx);
                a=find(event_epoch_idx==epoch_idx(i));
                if isempty(a);
                else
                    tp=out_datasets(setpos).header.events(a);
                    for i=1:length(tp);
                        tp(i).epoch=i;
                    end;
                    new_events=[new_events tp];
                end;
            end;
            out_datasets(setpos).header.events=new_events;
        end;
    end;
    
    %adjust epochdata
    if isfield(out_datasets(setpos).header,'epochdata');
        out_datasets(setpos).header.epochdata=out_datasets(setpos).header.epochdata(epoch_idx);
    end;
end;
    

