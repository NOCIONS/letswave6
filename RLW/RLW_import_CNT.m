function [out_datasets,message_string]=RLW_import_CNT(filename,varargin);
%RLW_import_CNT
%
%Import CNT data
%filename : name of CNT file 
%
%varargin
%split_blocks (0)
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

split_blocks=0;

%parse varagin
if isempty(varargin);
else
    %split_blocks
    a=find(strcmpi(varargin,'split_blocks'));
    if isempty(a);
    else
        split_blocks=varargin{a+1};
    end;
end;


message_string={};
out_datasets=[];
out_header=[];
out_data=[];

message_string{1}=['Loading : ' filename];

%load the BDF file
%load data
dat=ft_read_data(filename);
%load header
hdr=ft_read_header(filename);
%load events
trg=ft_read_event(filename);

%set header
message_string{end+1}='Creating header';
out_header.filetype='time_amplitude';
out_header.name=filename;
out_header.tags='';
out_header.history(1).configuration=[];
out_header.datasize=[hdr.nTrials hdr.nChans 1 1 1 hdr.nSamples];
out_header.xstart=(hdr.nSamplesPre/hdr.Fs)*-1;
out_header.ystart=0;
out_header.zstart=0;
out_header.xstep=1/hdr.Fs;
out_header.ystep=1;
out_header.zstep=1;

%set chanlocs
message_string{end+1}=['Importing ',num2str(hdr.nChans),' channel labels'];
%dummy chanloc
chanloc.labels='';
chanloc.topo_enabled=0;
chanloc.SEEG_enabled=0;
%set chanlocs
for chanpos=1:hdr.nChans;
    chanloc.labels=hdr.label{chanpos};
    out_header.chanlocs(chanpos)=chanloc;
end;
           
%set events
numevents=size(trg,2);
message_string{end+1}=['Importing ',num2str(numevents),' events'];
%set events
if numevents==0;
    out_header.events=[];
else
    for eventpos=1:numevents;
        event.code='unknown';
        if isempty(trg(eventpos).value);
            event.code=trg(eventpos).type;
        else
            event.code=trg(eventpos).value;
        end;
        if isnumeric(event.code);
            event.code=num2str(event.code);
        end;
        event.latency=(trg(eventpos).sample*out_header.xstep)+out_header.xstart;
        event.epoch=1;
        out_header.events(eventpos)=event;
    end;
end;

%set data
message_string{end+1}=['Importing data (',num2str(hdr.nSamples),' samples, ',num2str(hdr.nTrials),' trial(s))'];
out_data=zeros(out_header.datasize);
for chanpos=1:out_header.datasize(2);
    for epochpos=1:out_header.datasize(1);
        out_data(epochpos,chanpos,1,1,1,:)=squeeze(dat(chanpos,:,epochpos));
    end;
end;

%split blocks into separate datafiles?
if split_blocks==1;
    [p,n,e]=fileparts(out_header.name);
    data_src=out_data;
    header_src=out_header;
    %adapted from Gan Huang
    formatSpec='%*19s%20f%[^\n\r]';
    fileID=fopen([filename(1:end-3),'seg'],'r');
    dataArray=textscan(fileID,formatSpec);
    fclose(fileID);
    num_segment=dataArray{1}(1);
    message_string{end+1}='Splitting the dataset into separate files, one for each block.';
    message_string{end+1}=['Number of blocks in the dataset : ' num2str(num_segment)];
    time_segment(1)=0;
    time_segment(num_segment+1)=size(data_src,6);
    temp=str2num(char(dataArray{2}(2:end)));
    for k=num_segment:-1:2
        time_segment(k)=time_segment(k+1)-temp(k-1);
    end
    data_split=cell(num_segment,1);
    header_split=cell(num_segment,1);
    for k1=1:num_segment
        data_split=data_src(:,:,:,:,:,time_segment(k1)+1:time_segment(k1+1));
        header_split=header_src;
        header_split.datasize=size(data_split);
        header_split=rmfield(header_split,'events');
        index=0;
        for k2=1:length(header_src.events)
            currentevent=header_src.events(k2);
            if currentevent.latency>=(time_segment(k1)+1)*header_split.xstep && currentevent.latency<time_segment(k1+1)*header_split.xstep
                index=index+1;
                currentevent.latency=currentevent.latency-(time_segment(k1))*header_split.xstep;
                header_split.events(index)=currentevent;
            end;
        end;
        out_datasets(k1).header=header_split;
        out_datasets(k1).header.name=['SEG' num2str(k1) '_' n e]
        out_datasets(k1).data=data_split;
    end;
else
    out_datasets.data=out_data;
    out_datasets.header=out_header;
end;
