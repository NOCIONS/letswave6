function [out_header,out_data,message_string]=RLW_import_DELTAMED(filename);
%RLW_import_DELTAMED
%
%Import DELTAMED data
%filename : name of DELTAMED file 
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

%filename_txt
[p n e]=fileparts(filename);
filename_txt=[p filesep n '.txt'];
message_string{end+1}=['Loading TXT header : ' filename_txt];

%open text header
txtfile=fopen(filename_txt);
tp=fgetl(txtfile);
while ischar(tp);
    if length(tp)>=8
        if strcmpi(tp(1:8),'Sampling');
            sampling_rate=str2num(tp(10:length(tp)));
            message_string{end+1}=['Sampling rate : ' num2str(sampling_rate)];
        end;
        if strcmpi(tp(1:8),'Channels');
            st=tp(10:length(tp));
        end;
        if strcmpi(tp(1:8),'Gainx100');
            st2=tp(11:length(tp));
        end;
    end;
    if length(tp)>=7
        if strcmpi(tp(1:7),'[EVENT]');
            break
        end;
    end;
    tp=fgetl(txtfile);
end;
index=1;
while ischar(tp);
    tp=fgetl(txtfile);
    if ischar(tp);
        if length(tp)>1;
            %rl=textscan(tp,'%d%s','delimiter',',');
            idx=find(tp==',');
            event_pos(index)=str2num(tp(1:idx-1));
            %event_pos(index)=rl{1};
            event_code{index}=tp(idx+1:end);
            %event_code{index}=rl{2};
            index=index+1;
        end;
    end;
end;

channel_labels=textscan(st,'%s','delimiter',',');
channel_labels=channel_labels{1};
channel_gain=textscan(st2,'%f','delimiter',',');
channel_gain=channel_gain{1};
xstart=0;
xstep=1/sampling_rate;
event_lat=(double(event_pos)-1).*xstep;

%generate header
out_header=[];
out_header.filetype='time_amplitude';
out_header.name=filename_txt;
out_header.tags='';
            
%header.history
out_header.history(1).configuration=[];

%initialize header.datasize (will be updated later)
out_header.datasize=[0 0 0 0 0 0];
out_header.xstart=0;
out_header.ystart=0;
out_header.zstart=0;
out_header.xstep=xstep;
out_header.ystep=1;
out_header.zstep=1;

%chanlocs
for i=1:length(channel_labels);
    out_header.chanlocs(i).labels=channel_labels{i};
    out_header.chanlocs(i).topo_enabled=0;
end;

%header.events
for i=1:length(event_code);
    %out_header.events(i).code=cell2mat(event_code{i});
    out_header.events(i).code=event_code{i};
    out_header.events(i).latency=event_lat(i);
    out_header.events(i).epoch=1;
end;
message_string{end+1}=['Number of channels : ' num2str(length(out_header.chanlocs))];

%filename_bin
filename_bin=[p filesep n '.bin'];
%load BIN data if it exists, else will try to load ASC data
%note that Deltamed software can export as either BIN or ASCII
if exist(filename_bin);
    fileID=fopen(filename_bin);
    tp1=fread(fileID,'int16');
    EpochSize=size(tp1,1)/length(out_header.chanlocs);
    message_string{end+1}=['Epoch size : ' num2str(EpochSize)];
    tp2=reshape(tp1,length(out_header.chanlocs),EpochSize);
    out_data=zeros(1,size(tp2,1),1,1,1,size(tp2,2));
    for chanpos=1:size(tp2,1);
        out_data(1,chanpos,1,1,1,:)=(tp2(chanpos,:)*channel_gain(chanpos))/1000;
    end;
else
    %filename_asc
    filename_asc=[p filesep n '.asc'];
    %load ASC data it it exists
    if exist(filename_asc);
        message_string{end+1}='Loading the ASCII data. *** This can take a while ***';
        message_string{end+1}='For faster operations, try to export data as BIN';
        tp=load(filename_asc,'ascii');
        for i=1:size(tp,2);
            out_data(1,i,1,1,1,:)=(tp(:,i)*channel_gain(i))/1000;
        end;
    else
        message_string{end+1}='Error : no data file found!';
        return;
    end;
end;

%update header.datasize
out_header.datasize=size(out_data);
message_string{end+1}=['Number of epochs : ' num2str(out_header.datasize(1))];

%close all
fclose('all');

