function [out_header,out_data,message_string]=RLW_import_SET(filename);
%RLW_import_SET
%
%Import EEGLAB SET data
%filename : name of SET file 
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

message_string={};
out_header=[];
out_data=[];

message_string{1}=['Loading : ' filename];

%load the SET file
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
        if(out_header.datasize(1)==1) %if it is continous data or just a single epoch
            event.latency=(trg(eventpos).sample*out_header.xstep)+out_header.xstart;
            event.epoch=1;
        else %if it is an epoched dataset
            event.epoch = floor(trg(eventpos).sample/out_header.datasize(6))+1;
            event.latency=((trg(eventpos).sample*out_header.xstep)+out_header.xstart)-...
                            (event.epoch-1)*out_header.xstep*out_header.datasize(6);
        end
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


