function [out_header,out_data,message_string]=RLW_linear_CSD(header,data);
%RLW_linear_CSD
%
%Linear CSD
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
message_string{1}='Linear CSD';

%prepare out_header
out_header=header;

if header.datasize(2)<=3;
    message_string{end+1}='ERROR : Computing the CSD requires more than 3 channels!!!';
    return;
end;

%adjust datasize
%remove first and last channels
out_header.datasize(2)=header.datasize(2)-2;
out_header.chanlocs=header.chanlocs(2:end-1);

%prepare out_data
out_data=zeros(out_header.datasize);

%compute the CSD
for epochpos=1:header.datasize(1);
    for indexpos=1:header.datasize(3);
        for dz=1:header.datasize(4);
            for dy=1:header.datasize(5);
                for chanpos=2:header.datasize(2)-1;
                    out_data(epochpos,chanpos-1,indexpos,dz,dy,:)=-1.*data(epochpos,chanpos-1,indexpos,dz,dy,:)+-1.*data(epochpos,chanpos+1,indexpos,dz,dy,:)+2.*data(epochpos,chanpos,indexpos,dz,dy,:);
                end;
            end;
        end;
    end;
end;
