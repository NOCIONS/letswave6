function [out_header,out_data,message_string]=RLW_findEKG(header,data)
% RLW_findEKG
% find the EKG peaks and add them as the events
%
% Author :
% Gan Huang
% Institute of Neurosciences (IONS)
% Universite catholique de louvain (UCL)
% Belgium
%
% Contact : andre.mouraux@uclouvain.be
% This function is part of Letswave 6
% See http://nocions.webnode.com/letswave for additional information

%init message_string
message_string={};
message_string{1}='EKG detection';

[header,data] = RLW_butterworth_filter(header, data,'filter_type','bandpass','low_cutoff',0.5,'high_cutoff',40,'filter_order',10);
f_value=zeros(header.datasize(2),2);
for ch=1:header.datasize(2)
    data_temp=double(squeeze(data(1,ch,1,1,1,:)));
    pks = findpeaks( data_temp);
    if length(pks)<10
        f_value(ch,1)=0;
    else
        clusterX = kmeans(pks,3);
        [~,tbl]  = anova1(pks,clusterX,'off');
        f_value(ch,1)=tbl{2,5};
    end
    pks= findpeaks(-data_temp);
    if length(pks)<10
        f_value(ch,1)=0;
    else
        clusterX = kmeans(pks,3);
        [~,tbl]  = anova1(pks,clusterX,'off');
        f_value(ch,2)=tbl{2,5};
    end
end
[M,I]=max(f_value);
if(M(1)>M(2))
    message_string{end+1}=['Channel ',header.chanlocs(I(1)).labels,'(ch',num2str(I(1)),') is selected to detect EKG'];
    data_temp=double(squeeze(data(1,I(1),1,1,1,:)));
else
    message_string{end+1}=['Channel ',header.chanlocs(I(2)).labels,'(ch',num2str(I(2)),') is selected to detect EKG'];
    data_temp=-double(squeeze(data(1,I(2),1,1,1,:)));
end
disp(message_string{end});

[pks,locs] = findpeaks(double(data_temp));
clusterX = kmeans(pks,3);
[~,b]=max(pks);
locs=locs(clusterX==clusterX(b));
locs=locs(2:end-1);

out_header=header;
out_data=data;
t=(0:header.datasize(6)-1)*header.xstep-header.xstart;
event=header.events(end);
event.code='EKG';
for k=1:length(locs)-1
    event.latency=t(locs(k));
    out_header.events(end+1)=event;
end
% header.name=['EKG ',header.name];
% CLW_save('',header,data);