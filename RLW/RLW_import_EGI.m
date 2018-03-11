function [out_header,out_data,message_string]=RLW_import_EGI(filename,varargin);
%RLW_import_EGI
%
%Import EGI data
%filename : name of EGI file 
%
%varargin
%'concatenate' 0/1
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

concatenate=0;
implementation=1;

%parse varagin
if isempty(varargin);
else
    %concatenate
    a=find(strcmpi(varargin,'concatenate'));
    if isempty(a);
    else
        concatenate=varargin{a+1};
    end;
    %implementation
    a=find(strcmpi(varargin,'implementation'));
    if isempty(a);
    else
        implementation=varargin{a+1};
    end;
end;


message_string={};
out_header=[];
out_data=[];

message_string{1}=['Loading : ' filename];
message_string{2}=['Implementation : ' num2str(implementation)];

%load the BDF file
%load header
switch implementation
    case 1      
        %use the default egi_mff_v1 implementation
        hdr=ft_read_header(filename);
        %load data
        dat=ft_read_data(filename);
        %load events
        trg=ft_read_event(filename);
    case 2
        %add path
        [p,n,e]=fileparts(which('letswave'));
        p=[p filesep 'external' filesep 'egi_mff' filesep 'java' filesep 'MFF-1.2.jar'];
        javaaddpath(p);
        %use the alternative egi_mff_v2 implementation
        hdr=ft_read_header(filename,'headerformat','egi_mff_v2');
        %load data
        dat=ft_read_data(filename,'headerformat','egi_mff_v2','dataformat','egi_mff_v2');
        %load events
        trg=ft_read_event(filename,'eventformat','egi_mff_v2');
end;


%set header
message_string{end+1}='Creating header';
out_header.filetype='time_amplitude';
out_header.name=filename;
out_header.tags='';
out_header.history=[];
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

%concatenate?
if concatenate==1;
    message_string{end+1}=['Concatenating epochs'];
    tp=out_data;
    epoch_size=out_header.datasize(6);
    num_epochs=out_header.datasize(1);
    out_header.datasize(6)=out_header.datasize(1)*out_header.datasize(6);
    out_header.datasize(1)=1;
    out_data=zeros(out_header.datasize);
    for epochpos=1:size(tp,1);
        dx1=1+((epochpos-1)*epoch_size);
        dx2=epoch_size+((epochpos-1)*epoch_size);
        out_data(1,:,:,:,:,dx1:dx2)=tp(epochpos,:,:,:,:,:);
    end;
end;

