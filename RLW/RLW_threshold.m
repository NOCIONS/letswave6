function [out_header,out_data,message_string]=RLW_threshold(header,data,varargin);
%RLW_threshold
%
%Threshold
%
%varargin
%'threshold_value' (0)
%'threshold_criterion' ('<') '<' '<=' '>' '>=' '=='
%'consecutivity_criterion' (1)
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

threshold_value=0;
threshold_criterion='<';
consecutivity_criterion=1;

%parse varagin
if isempty(varargin);
else
    %threshold_value
    a=find(strcmpi(varargin,'threshold_value'));
    if isempty(a);
    else
        threshold_value=varargin{a+1};
    end;
    %threshold_criterion
    a=find(strcmpi(varargin,'threshold_criterion'));
    if isempty(a);
    else
        threshold_criterion=varargin{a+1};
    end;
    %consecutivity_criterion
    a=find(strcmpi(varargin,'consecutivity_criterion'));
    if isempty(a);
    else
        consecutivity_criterion=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='threshold.';

%prepare out_header
out_header=header;

%init out_data
out_data=zeros(size(data));

%threshold
switch threshold_criterion;
    case '>'
        out_data(find(data>threshold_value))=1;
    case '<'
        out_data(find(data<threshold_value))=1;
    case '>='
        out_data(find(data>=threshold_value))=1;
    case '<='
        out_data(find(data<=threshold_value))=1;
    case '='
        out_data(find(data==threshold_value))=1;
end;

message_string{end+1}=['A total of ' num2str(length(find(out_data==1))) ' bins were found to satisfy threshold criterion.'];

%consecutivity?
if consecutivity_criterion>1;
    consecutivity=consecutivity_criterion;
    message_string{end/1}=['Consecutivity criterion >1. Applying the criterion. This may take a while.'];
    data=out_data;
    out_data=zeros(size(out_data));
    %loop through all the data
    for dx=1:size(data,6);
        dx1=dx-consecutivity_criterion;
        dx2=dx+consecutivity_criterion;
        if dx1>0;
            if dx2<size(data,6);
                for epochpos=1:size(data,1);
                    for channelpos=1:size(data,2);
                        for indexpos=1:size(data,3);
                            for dz=1:size(data,4);
                                for dy=1:size(data,5);
                                    if sum(squeeze(data(epochpos,channelpos,indexpos,dz,dy,dx1:dx2)))>=(consecutivity*2)+1;
                                        out_data(epochpos,channelpos,indexpos,dz,dy,dx)=1;
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
    message_string{end+1}=['After applying the consecutivity criterion, ' num2str(length(find(out_data==1))) ' bins remained.'];
end;




