function [out_header,out_data,message_string]=RLW_reject_epochs(header,data,rejected_epochs);
%RLW_reject_epochs
%
%Reject epochs 
%
%rejected_epochs=[];
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
message_string{1}='reject epochs';

%prepare out_header
out_header=header;

%accepted_epochs
accepted_epochs=1:1:header.datasize(1);
accepted_epochs(rejected_epochs)=[];

%remove epochs
out_data=data(accepted_epochs,:,:,:,:,:);

%update header.datasize
out_header.datasize=size(out_data);

%fix events
if isfield(out_header,'events');
    if isempty(out_header.events);
    else
        j=1;
        delete_events=[];
        for i=1:length(out_header.events);
            a=find(accepted_epochs==out_header.events(i).epoch);
            out_header.events(i).epoch=a;
            if isempty(a);
                delete_events(j)=i;
                j=j+1;
            end;
        end;
        out_header.events(delete_events)=[];
    end;
end;

%fix epochdata
if isfield(out_header,'epochdata');
    if isempty(out_header.epochdata);
    else
        out_header.epochdata=header.epochdata(accepted_epochs);
    end;
end;



