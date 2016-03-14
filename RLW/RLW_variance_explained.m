function [out_header,out_data,message_string]=RLW_variance_explained(header,data,ref_header,ref_data);
%RLW_variance explained
%
%variance explained
%
%header,data
%ref_header, ref_data is reference dataset 
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
message_string{1}='Computing explained variance.';

%prepare out_header
out_header=header;

%set number of channels to 1
out_header.datasize(2)=1;

%prepare out_data
out_data=zeros(out_header.datasize);

%loop through epochs
for epochpos=1:size(out_data,1);
    %loop through index
    for indexpos=1:size(out_data,3);
        %loop through dz
        for dz=1:size(out_data,4);
            %loop through dy
            for dy=1:size(out_data,5);
                %loop through dx
                for dx=1:size(out_data,6);
                    a=squeeze(data(epochpos,:,indexpos,dz,dy,dx));
                    b=squeeze(ref_data(epochpos,:,indexpos,dz,dy,dx));
                    out_data(epochpos,1,indexpos,dz,dy,dx)=corr(a',b');
                end;
            end;
        end;
    end;
end;

%chanloc
out_header.chanlocs=[];
out_header.chanlocs(1).labels='EXPLVAR';
out_header.chanlocs(1).topo_enabled=0;
out_header.chanlocs(1).SEEG_enabled=0;


    


