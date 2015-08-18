function [out_header,out_data,message_string]=RLW_import_MEGA(input_folder,session_number);
%RLW_import_MEGA
%
%Import MEGA data
%filename : name of MEGA file 
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

message_string{1}=['Loading : ' input_folder];

%recording
recording=module_read_neurone(input_folder,session_number);

%prepare header
message_string{end+1}='Generating header.';
out_header.filetype='time_amplitude';
out_header.name=[input_folder,'_',session_number];
out_header.tags={};
out_header.history(1).configuration=[];
out_header.datasize=double([1 length(recording.signalTypes) 1 1 1 recording.properties.length*recording.properties.samplingRate]);
out_header.xstart=1/recording.properties.samplingRate;
out_header.ystart=0;
out_header.zstart=0;
out_header.xstep=1/recording.properties.samplingRate;
out_header.ystep=1;
out_header.zstep=1;

%dummy chanloc
chanloc.labels='';
chanloc.topo_enabled=0;
chanloc.SEEG_enabled=0;
%set chanlocs
message_string{end+1}=['Importing ',num2str(length(recording.signalTypes)),' channel labels'];
for chanpos=1:length(recording.signalTypes);
    chanloc.labels=recording.signalTypes{chanpos};
    out_header.chanlocs(chanpos)=chanloc;
end;
            
%set events
out_header.events=[];
if isempty(recording.markers.index);
else
    numevents=length(recording.markers.index);
    message_string{end+1}=['Importing ',num2str(numevents),' events'];
    for eventpos=1:numevents;
        event.code='unknown';
        if ~isempty(recording.markers.type(eventpos));
            event.code=recording.markers.type{eventpos};
        end;
        if isnumeric(event.code);
            event.code=num2str(event.code);
        end;
        event.latency=recording.markers.time(eventpos);
        event.epoch=1;
        events(eventpos)=event;
    end;
    out_header.events=events;
end;

%data
message_string{end+1}=['Importing data (',num2str(out_header.datasize(6)),' samples, ',num2str(out_header.datasize(1)),' epoch(s))'];
out_data=zeros(out_header.datasize);
for k=1:length(recording.signalTypes)
    eval(['out_data(1,k,1,1,:)=squeeze(recording.signal.',recording.signalTypes{k},'.data);']);
end
