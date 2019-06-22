function import_XLS_data(filename)
sampling_rate=1000;
[~,~,dat]=xlsread(filename,'Sheet1');
channel_labels=dat(1,:);
tp=cell2mat(dat(2:end,:));

%build data
data=zeros(1,size(tp,2),1,1,1,size(tp,1));
data(1,:,1,1,1,:)=tp';

%build header
header.filetype='time_amplitude';
[p,n,e]=fileparts(filename);
header.name=n;
header.tags='';
header.datasize=size(data);
header.xstart=0;
header.ystart=0;
header.zstart=0;
header.xstep=1/sampling_rate;
header.ystep=1;
header.zstep=1;
%set chanlocs
%dummy chanloc
chanloc.labels='';
chanloc.topo_enabled=0;
chanloc.SEEG_enabled=0;
%set chanlocs
for chanpos=1:length(channel_labels);
    chanloc.labels=strtrim(channel_labels{chanpos});
    header.chanlocs(chanpos)=chanloc;
end;
header.events=[];

%save
%save header
save([n '.lw6'],'-MAT','header');
%save data
data=single(data);
save([n '.mat'],'-MAT','-v7.3','data');
end

