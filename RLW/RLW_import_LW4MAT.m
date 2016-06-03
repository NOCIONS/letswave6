function [out_header,out_data,message_string]=RLW_import_LW4MAT(filename);
%RLW_import_LW4MAT
%
%Import LW4 MAT data
%filename : name of LW4 MAT file 
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

%load MAT file
tp=load(filename);
[p,n,e]=fileparts(filename);
ni=find(n==' ');
n(ni)='_';
eval(['dat=tp.' n]);

%set out_header
message_string{end+1}='Importing out_header';
out_header.filetype='time_amplitude';
out_header.name=n;
out_header.tags={};
out_header.history=[];
out_header.datasize=[dat.NumEpochs dat.NumChannels 1 1 dat.YSize dat.XSize];
out_header.xstart=dat.XStart;
out_header.ystart=dat.YStart;
out_header.zstart=0;
out_header.xstep=dat.XStep;
out_header.ystep=dat.YStep;
out_header.zstep=1;

%set chanlocs
message_string{end+1}='Importing channel labels';
%dummy chanloc
chanloc.labels='';
chanloc.topo_enabled=0;
chanloc.SEEG_enabled=0;
%set chanlocs
for chanpos=1:length(dat.Channels);
    if isfield(dat.Channels(chanpos),'label');
        chanloc.labels=dat.Channels(chanpos).label;
    else
        chanloc.labels=['C' num2str(chanpos)];
    end;
    out_header.chanlocs(chanpos)=chanloc;
end;

%events
out_header.events=[];

%import data
message_string{end+1}=['Importing data (',num2str(dat.XSize),' samples, ',num2str(dat.NumEpochs),' trial(s))'];
out_data=zeros(out_header.datasize);
if out_header.datasize(1)>1;
    for chanpos=1:out_header.datasize(2);
        for epochpos=1:out_header.datasize(1);
            for ypos=1:out_header.datasize(5);
                out_data(epochpos,chanpos,1,1,ypos,:)=squeeze(dat.RealData(:,ypos,chanpos,epochpos));
            end;
        end;
    end;
else
    for chanpos=1:out_header.datasize(2);
        for ypos=1:out_header.datasize(5);
            out_data(1,chanpos,1,1,ypos,:)=squeeze(dat.RealData(:,ypos,chanpos));
        end;
    end;
end;
i=1;


