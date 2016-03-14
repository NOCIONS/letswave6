function [out_header,out_data,message_string]=RLW_import_LW5(filename);
%RLW_import_LW5
%
%Import LW5 data
%filename : name of LW5 file 
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


%load header
[p n e]=fileparts(filename);
st=[p filesep n '.lw5']
load(st,'-MAT');

%set header
message_string{end+1}='Importing header';
out_header.filetype=header.filetype;
out_header.name=filename;
out_header.tags=header.tags;
out_header.datasize=header.datasize;
out_header.xstart=header.xstart;
out_header.ystart=header.ystart;
out_header.zstart=header.zstart;
out_header.xstep=header.xstep;
out_header.ystep=header.ystep;
out_header.zstep=header.zstep;

%set chanlocs
message_string{end+1}='Importing channel labels';
%dummy chanloc
chanloc.labels='';
chanloc.topo_enabled=0;
chanloc.SEEG_enabled=0;
%set chanlocs
for chanpos=1:length(header.chanlocs);
    chanloc.labels=header.chanlocs(chanpos).labels;
    out_header.chanlocs(chanpos)=chanloc;
end;

%events
if isfield(header,'events');
    out_header.events=header.events;
else
    out_header.events=[];
end;
            
%data
message_string{end+1}='Importing data';
[p,n,e]=fileparts(filename);
st=[p,filesep,n,'.mat'];
load(st);

%out_data
out_data=data;

