function [out_header,out_data,message_string]=RLW_sort_epochdata(header,data,varargin);
%RLW_sort_epochdata
%
%Sort epochdata
%
%varargin
%'fieldname'
%'sort' ('ascend')
%'discard_empty' (1)
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

fieldname='';
sort_direction='ascend'
discard_empty=1;

%parse varagin
if isempty(varargin);
else
    %fieldname
    a=find(strcmpi(varargin,'fieldname'));
    if isempty(a);
    else
        fieldname=varargin{a+1};
    end;
    %sort
    a=find(strcmpi(varargin,'sort'));
    if isempty(a);
    else
        sort_direction=varargin{a+1};
    end;
    %discard_empty
    a=find(strcmpi(varargin,'discard_empty'));
    if isempty(a);
    else
        discard_empty=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='Sort epoch data.';

%prepare out_header
out_header=header;

%epochdata?
if isfield(header,'epochdata');
else
    message_string{end+1}='No epoch data available. Exit.';
    return;
end;
if isempty(header.epochdata);
    message_string{end+1}='Epoch data does not contain any fields. Exit.';
    return;
end;
if isfield(header.epochdata(1),'data');
else
    message_string{end+1}='No data structure in epoch data. Exit.';
    return;
end;

%epochdata
epochdata=header.epochdata;

%find epochs with fieldname and non-empty numerical fieldvalues
ok_i=1;
ko_i=1;
ok_idx=[];
ok_values=[];
ko_idx=[];
for i=1:length(epochdata);
    if isfield(epochdata(i).data,fieldname);
        tp=getfield(epochdata(i).data,fieldname);
        if isempty(tp);
            ko_idx(ko_i)=i;
            ko_i=ko_i+1;
        else
            if isnumeric(tp);
                ok_idx(ok_i)=i;
                ok_values(ok_i)=tp;
                ok_i=ok_i+1;
            else
                ko_idx(ko_i)=1;
                ko_i=ko_i+1;
            end;
        end;
    else
        ko_idx(ko_i)=1;
        ko_i=ko_i+1;
    end;
end;

message_string{end+1}=['Found ' num2str(length(ok_idx)) ' epochs to sort.'];

%sort
if isempty(ok_values);
else
    [a,b]=sort(ok_values,2,sort_direction);
    ok_idx=ok_idx(b);
end;
message_string{end+1}=['Sort order : ' num2str(ok_idx)];

%append other (discarded) epochs?
if isempty(ko_idx);
else
    if discard_empty==0;
        %sort discarded epochs in ascending order
        %this is probably not needed.
        ko_idx=sort_direction(ko_idx);
        ok_idx=[ok_idx ko_idx];
        message_string{end+1}=['Appending discarded epochs : ' num2str(ko_idx)];
    end;
end;

%data
out_data=data(ok_idx,:,:,:,:,:);

%adjust number of epochs
out_header.datasize(1)=length(ok_idx);

%adjust events
if isfield(header,'events');
    if isempty(header.events);
    else
        for i=1:length(header.events);
            event_epoch_idx(i)=header.events(i).epoch;
        end;
        new_events=[];
        for i=1:length(ok_idx);
            a=find(event_epoch_idx==ok_idx(i));
            if isempty(a);
            else
                tp=header.events(a);
                for i=1:length(tp);
                    tp(i).epoch=i;
                end;
                new_events=[new_events tp];
            end;
        end;
        out_header.events=new_events;
    end;
end;

%adjust epoch_data
out_header.epochdata=header.epochdata(ok_idx);

