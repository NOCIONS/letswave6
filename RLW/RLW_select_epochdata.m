function [out_header,out_data,message_string]=RLW_select_epochdata(header,data,varargin);
%RLW_select_epochdata
%
%Select epochdata
%
%varargin
%'fieldname'
%'logical' ('==')
%'comparison_value' (0)
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
logical='=='
comparison_value=0;

%parse varagin
if isempty(varargin);
else
    %fieldname
    a=find(strcmpi(varargin,'fieldname'));
    if isempty(a);
    else
        fieldname=varargin{a+1};
    end;
    %logical
    a=find(strcmpi(varargin,'logical'));
    if isempty(a);
    else
        logical=varargin{a+1};
    end;
    %comparison_value
    a=find(strcmpi(varargin,'comparison_value'));
    if isempty(a);
    else
        comparison_value=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='Select epoch data.';

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
                %test logical operation on epochs
                %with fieldname and non-empty numerical fieldvalues
                %values are in ok_values
                %logical operation string
                a=eval([num2str(tp) logical num2str(comparison_value)]);
                if a==1;
                    ok_idx(ok_i)=i;
                    ok_values(ok_i)=tp;
                    ok_i=ok_i+1;
                else
                    ko_idx(ko_i)=1;
                    ko_i=ko_i+1;
                end;
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

message_string{end+1}=['Found ' num2str(length(ok_idx)) ' epochs meeting criterion.'];

%data
out_data=data(ok_idx,:,:,:,:,:);

%adjust number of epochs
out_header.datasize(1)=length(ok_idx);

%adjust events
if isfield(out_header,'events');
    if isempty(out_header.events);
    else
        for i=1:length(out_header.events);
            event_epoch_idx(i)=out_header.events(i).epoch;
        end;
        new_events=[];
        for i=1:length(ok_idx);
            a=find(event_epoch_idx==ok_idx(i));
            if isempty(a);
            else
                tp=out_header.events(a);
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
out_header.epochdata=out_header.epochdata(ok_idx);

