function [out_header,out_data,message_string]=RLW_scalp_CSD(header,data);
%RLW_scalp_CSD
%
%Scalp CSD
%
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
message_string{1}='scalp CSD';

%prepare out_header
out_header=header;

%check topo_enabled
chan_ok=0;
for chanpos=1:length(header.chanlocs);
    if header.chanlocs(chanpos).topo_enabled==1;
        chan_ok=1;
    end;
end;
if chan_ok==0;
    message_string{end+1}='No channel coordinates. Exit!';
    return;
end;

%compute G and H
disp('Computing G and H...');
message_string{end+1}='Computing G and H...';

%get list of channels with electrode coordinates
idx=[];
chanpos2=1;
for chanpos=1:header.datasize(2);
    if header.chanlocs(chanpos).topo_enabled==1;
        scd_labels{chanpos2}=header.chanlocs(chanpos).labels;
        idx(chanpos2)=chanpos;
        chanpos2=chanpos2+1;
    end;
end;

%montage
mtg=ExtractMontage('10-5-System_Mastoids_EGI129.csd',scd_labels');

%derive G and H
[G,H]=GetGH(mtg);

%apply G and H
message_string{end+1}='Computing the CSD transform...';

%header > out_header
out_header=header;

%adjust out_header.chanlocs
out_header.chanlocs=header.chanlocs(idx);

%adjust out_header.datasize
out_header.datasize(2)=length(idx);

%get usable data
scd_data=data(:,idx,:,:,:,:);

%prepare out_data
out_data=zeros(out_header.datasize);

%loop through dataset
for epochpos=1:header.datasize(1);
    for indexpos=1:header.datasize(3);
        disp(['E:' num2str(epochpos) ' I:' num2str(indexpos)]);
        for dz=1:header.datasize(4);
            for dy=1:header.datasize(5);
                eeg=single(squeeze(scd_data(epochpos,:,indexpos,dz,dy,:)));
                res=CSD(eeg,G,H);
                out_data(epochpos,:,indexpos,dz,dy,:)=res(:,:);
            end;
        end;
    end;
end;


