function [header,data,message_string]=RLW_import_ASCII(filename,epoch_size,sampling_rate,xstart,varargin);
%RLW_import_ASCII
%
%Import ASCII data
%filename : name of ASCII file name
%epoch_size (1000)
%sampling_rate (1000)
%xstart (-0.5)
%
%varargin
%'header_lines' (0)
%'import_channel_labels' (0)
%'channel_label_line' (0)
%'discard_characters_channel_labels' ('")
%'column_delimiters' (' ')
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


header_lines=0;
import_channel_labels=0;
channel_label_line=0;
discard_characters_channel_labels='''"';
column_delimiters=' ';


%parse varagin
if isempty(varargin);
else
    %header_lines
    a=find(strcmpi(varargin,'header_lines'));
    if isempty(a);
    else
        header_lines=varargin{a+1};
    end;
    %import_channel_labels
    a=find(strcmpi(varargin,'import_channel_labels'));
    if isempty(a);
    else
        import_channel_labels=varargin{a+1};
    end;
    %channel_label_line
    a=find(strcmpi(varargin,'channel_label_line'));
    if isempty(a);
    else
        channel_label_line=varargin{a+1};
    end;
    %channel_label_line
    a=find(strcmpi(varargin,'discard_characters_channel_labels'));
    if isempty(a);
    else
        discard_characters_channel_labels=varargin{a+1};
    end;
    %channel_label_line
    a=find(strcmpi(varargin,'column_delimiters'));
    if isempty(a);
    else
        column_delimiters=varargin{a+1};
    end;
end;

%init message_string
message_string={};

%open file
[f,message]=fopen(filename);
if isempty(message);
else
    message_string=message;
end;
%skip header lines if header_lines>0
if header_lines>0;
    for i=1:header_lines;
        st=fgetl(f);
        %if import_channel_labels==1
        if import_channel_labels==1;
            if channel_label_line==i;
                channel_string=st;
            end;
        end;
    end;
end;
%set channel labels
%if import_channel_labels==0
if import_channel_labels==0;
    %get current position in file
    currentpos=ftell(f);
    st=fgetl(f);
    tp=textscan(st,'%s','Delimiter',column_delimiters,'MultipleDelimsAsOne',1);
    numchannels=length(tp{1});
    for i=1:numchannels;
        channel_labels{i}=['C' num2str(i)];
    end;
    fseek(f,0,'bof');
else
    tp=textscan(channel_string,'%s','Delimiter',column_delimiters,'MultipleDelimsAsOne',1);
    channel_labels=tp{1};
    numchannels=length(channel_labels);
end;
message_string{end+1}=['Number of channels : ',num2str(numchannels)];
message_string{end+1}=['Epoch size : ',num2str(epoch_size)];
%read epochs
epoch_pos=1;
while not(feof(f));
    [tp,position]=textscan(f,'%n',epoch_size*numchannels,'Delimiter',column_delimiters,'MultipleDelimsAsOne',1);
    if length(tp{1})==epoch_size*numchannels;
        data(epoch_pos,:,1,1,1,:)=reshape(tp{1},numchannels,epoch_size);
        epoch_pos=epoch_pos+1;
    else
        fread(f,1);
    end;
end;
%build header
header.filetype='time_amplitude';
[p,n,e]=fileparts(filename);
header.name=n;
header.tags='';
header.datasize=size(data);
header.xstart=xstart;
header.ystart=0;
header.zstart=0;
header.xstep=1/sampling_rate;
header.ystep=1;
header.zstep=1;
message_string{end+1}=['Number of epochs found : ' num2str(header.datasize(1))],1,0)];
%set chanlocs
%dummy chanloc
chanloc.labels='';
chanloc.topo_enabled=0;
chanloc.SEEG_enabled=0;
%set chanlocs
for chanpos=1:numchannels;
    chanloc.labels=strtrim(channel_labels{chanpos});
    header.chanlocs(chanpos)=chanloc;
end;
%delete characters from channel labels if needed
stdel=discard_characters_channel_labels;
if isempty(stdel);
else
    for i=1:length(header.chanlocs);
        st=header.chanlocs(i).labels;
        for j=1:length(stdel);
            st(find(st==stdel(j)))=[];
        end;
        header.chanlocs(i).labels=st;
    end;
end;
header.events=[];
