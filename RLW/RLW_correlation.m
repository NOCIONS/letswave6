function [out_header,out_data,message_string]=RLW_correlation(header,data,varargin);
%RLW_correlation
%
%correlation with epochdata
%
%varargin
%epochdata_field
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

epochdata_field='';

%parse varagin
if isempty(varargin);
else
    %constant
    a=find(strcmpi(varargin,'epochdata_field'));
    if isempty(a);
    else
        epochdata_field=varargin{a+1};
    end;
end;

%init message_string
message_string={};

%prepare out_header
out_header=header;

%prepare out_data
out_header.datasize(3)=2;
out_header.datasize(1)=1;
out_data=zeros(out_header.datasize);

%find epochdata
if isfield(header,'epochdata');
    st=fieldnames(header.epochdata(1).data);
    a=find(strcmpi(epochdata_field,st));
    if isempty(a);
        disp('Epoch data field not found in dataset!');
        return;
    else
        disp('Epoch data found!');
        for i=1:length(header.epochdata);
            edata=header.epochdata(i).data;
            st=['tp=edata.' epochdata_field ';'];
            eval(st);
            v(i)=tp;
        end;
        if length(v)==header.datasize(1);
        else
            disp('Number of epochdata values does not match the number of epochs!');
            return;
        end;
    end;
else
    disp('No epoch data in dataset!');
end;

v=v';

%correlation
message_string{1}='Performing the correlation... This may take a while!';

%loop through channels
for chanpos=1:header.datasize(2);
    %loop through dz
    for dz=1:header.datasize(4);
        %loop through dy
        for dy=1:header.datasize(5);
            %loop through dx
            for dx=1:header.datasize(6);
                [out_data(1,chanpos,1,dz,dy,dx),out_data(1,chanpos,2,dz,dy,dx)]=corr(squeeze(data(:,chanpos,1,dz,dy,dx)),v);
            end;
        end;
    end;
end;

%set index labels
out_header.index_labels{1}='r';
out_header.index_labels{2}='p';


    

    


