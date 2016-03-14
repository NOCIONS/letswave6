function [out_header,out_data,message_string]=RLW_merge_epochs(datasets,merge_idx)
%RLW_merge_epochs
%
%Merge epochs
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
message_string{end+1}='Merge epochs';

%check merge_idx
if isempty(merge_idx);
    message_string{end+1}='No files to merge. Exit.';
    return;
end;

%merge_idx(1) > out_data & out_header
out_data=datasets(merge_idx(1)).data;
out_header=datasets(merge_idx(1)).header;

%check whether epochdata should be processed
process_epoch_data=0;
if isfield(out_header,'epochdata');
    if isempty(out_header.epochdata);
    else
        if isfield(out_header.epochdata(1),'data');
            message_string{end+1}='Epoch data found in the dataset. Will merge epoch data across datasets.';
            process_epoch_data=1;
        end;
    end;
end;

%check events
if isfield(out_header,'events');
else
    out_header.events=[];
end;

%loop through merge_idx
if length(merge_idx)>1;
    for merge_pos=2:length(merge_idx);
        
        %check sizes
        if (out_header.datasize(2:6)==datasets(merge_idx(merge_pos)).header.datasize(2:6));
        else
            message_string{end+1}='Datasets cannot be merged as their sizes do not match. Exit.';
            return;
        end;
        
        %number of epochs
        num_epochs=size(out_data,1);
        
        %merge data
        out_data=cat(1,out_data,datasets(merge_idx(merge_pos)).data);
        
        %header
        header=datasets(merge_idx(merge_pos)).header;
        
        %events
        if isfield(header,'events');
            if isempty(header.events);
            else
                message_string{end+1}='Merging events.';
                events=header.events;
                %adjust epoch index of events
                for i=1:length(events);
                    events(i).epoch=events(i).epoch+num_epochs;
                end;
                out_header.events=[out_header.events events];
            end;
        end;
        
        %epochdata
        if process_epoch_data==1;
            %generate empty epochdata
            epochdata=[];
            for i=1:header.datasize(1);
                epochdata(i).data=[];
            end;
            if isfield(header,'epochdata');
                if isempty(header.epochdata);
                else
                    if isfield(header.epochdata(1),'data');
                        message_string{end+1}='Merging epoch data.';
                        epochdata=header.epochdata;
                    end;
                end;
            end;
            out_header.epochdata=[out_header.epochdata epochdata];
        end;
    end;
end;

%clear out_header.history
out_header.history=[];

%change number of epochs
out_header.datasize=size(out_data);

