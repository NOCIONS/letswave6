function [out_header,out_data,message_string]=RLW_hilbert(header,data);
%RLW_hilbert
%
%Hilbert transform
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


%init message_string
message_string={};
message_string{1}='Hilbert transform';

%out_header
out_header=header;

%out_data
out_data=zeros(size(data));

%loop through all the data
for epochpos=1:size(data,1);
    for indexpos=1:size(data,3);
        for dz=1:size(data,4);
            for dy=1:size(data,5);
                %hilbert
                out_data(epochpos,:,indexpos,dz,dy,:)=abs(hilbert(squeeze(data(epochpos,:,indexpos,dz,dy,:))'))';
            end;
        end;
    end;
end


