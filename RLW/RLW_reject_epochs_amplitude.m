function [out_header,out_data,message_string]=RLW_reject_epochs_amplitude(header,data,varargin);
%RLW_reject_epochs_amplitude
%
%Reject epochs (amplitude criterion)
%
%varargin
%
%'x_limits' 0
%'y_limits' 0
%'z_limits' 0
%'x_start' 0
%'x_end' 0
%'y_start' 0
%'y_end' 0
%'z_start' 0
%'z_end' 0
%'criterion' 100
%'select_channels' 0
%'selected_channel_labels' {}
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

x_limits=0;
y_limits=0;
z_limits=0;
x_start=header.xstart;
x_end=header.xstart+((header.datasize(6)-1)*header.xstep);
y_start=header.ystart;
y_end=header.ystart+((header.datasize(5)-1)*header.ystep);
z_start=header.zstart;
z_end=header.zstart+((header.datasize(4)-1)*header.zstep);
criterion=100;
select_channels=0;
for i=1:length(header.chanlocs);
    selected_channel_labels=header.chanlocs(i).labels;
end;

%parse varagin
if isempty(varargin);
else
    %x_limits
    a=find(strcmpi(varargin,'x_limits'));
    if isempty(a);
    else
        x_limits=varargin{a+1};
    end;
    %y_limits
    a=find(strcmpi(varargin,'y_limits'));
    if isempty(a);
    else
        y_limits=varargin{a+1};
    end;
    %z_limits
    a=find(strcmpi(varargin,'z_limits'));
    if isempty(a);
    else
        z_limits=varargin{a+1};
    end;
    %x_start
    a=find(strcmpi(varargin,'x_start'));
    if isempty(a);
    else
        x_start=varargin{a+1};
    end;
    %y_start
    a=find(strcmpi(varargin,'y_start'));
    if isempty(a);
    else
        y_start=varargin{a+1};
    end;
    %z_start
    a=find(strcmpi(varargin,'z_start'));
    if isempty(a);
    else
        z_start=varargin{a+1};
    end;
    %x_end
    a=find(strcmpi(varargin,'x_end'));
    if isempty(a);
    else
        x_end=varargin{a+1};
    end;
    %y_end
    a=find(strcmpi(varargin,'y_end'));
    if isempty(a);
    else
        y_end=varargin{a+1};
    end;
    %z_end
    a=find(strcmpi(varargin,'z_end'));
    if isempty(a);
    else
        z_end=varargin{a+1};
    end;
    %criterion
    a=find(strcmpi(varargin,'criterion'));
    if isempty(a);
    else
        criterion=varargin{a+1};
    end;
    %select_channels
    a=find(strcmpi(varargin,'select_channels'));
    if isempty(a);
    else
        select_channels=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='reject epochs (amplitude criterion)';

%prepare out_header
out_header=header;

%first step is to identify accepted epochs based on criterion
%dx1,dx2
if x_limits==1;
    %limits : find dx1 and dx2
    dx1=round(((x_start-header.xstart)/header.xstep)+1);
    dx2=round(((x_end-header.xstart)/header.xstep)+1);
    if dx1<1;
        dx1=1;
    end;
    if dx2>header.datasize(6);
        dx2=header.datasize(6);
    end;
else
    %no limits : select all epoch range
    dx1=1;
    dx2=header.datasize(6);
end;

%dy1,dy2
if y_limits==1;
    %limits : find dy1 and dy2
    dy1=round(((y_start-header.ystart)/header.ystep)+1);
    dy2=round(((y_end-header.ystart)/header.ystep)+1);
    if dy1<1;
        dy1=1;
    end;
    if dy2>header.datasize(5);
        dy2=header.datasize(5);
    end;
else
    %no limits : select all epoch range
    dy1=1;
    dy2=header.datasize(5);
end;

%dz1,dz2
if z_limits==1;
    %limits : find dz1 and dz2
    dz1=round(((z_start-header.zstart)/header.zstep)+1);
    dz2=round(((z_end-header.zstart)/header.zstep)+1);
    if dz1<1;
        dz1=1;
    end;
    if dz2>header.datasize(4);
        dz2=header.datasize(4);
    end;
else
    %no limits : select all epoch range
    dz1=1;
    dz2=header.datasize(4);
end;

message_string{end+1}=['DX1 : ' num2str(dx1) ' DX2 : ' num2str(dx2)];
message_string{end+1}=['DY1 : ' num2str(dy1) ' DY2 : ' num2str(dy2)];
message_string{end+1}=['DZ1 : ' num2str(dz1) ' DZ2 : ' num2str(dz2)];

%channels_idx
if select_channels==1;
    %st
    for i=1:length(header.chanlocs);
        st{i}=header.chanlocs(i).labels;
    end;
    j=1;
    channels_idx=[];
    for i=1:length(selected_channel_labels);
        a=find(strcmpi(selected_channel_labels{i},st)==1);
        if isempty(a);
        else
            channels_idx(j)=a(1);
            j=j+1;
        end;
    end;
else
    channels_idx=1:1:header.datasize(2);
end;
message_string{end+1}=['CHANIDX : ' num2str(channels_idx)];

%check criterion
j=1;
accepted_epochs=[];
for epochpos=1:header.datasize(1);
    tp=data(epochpos,channels_idx,1,dz1:dz2,dy1:dy2,dx1:dx2);
    if max(abs(tp(:)))>criterion;
    else
        accepted_epochs(j)=epochpos;
        j=j+1;
    end;
end;
message_string{end+1}=['Selected epochs : ' num2str(accepted_epochs)];

%remove epochs
out_data=data(accepted_epochs,:,:,:,:,:);

%update header.datasize
out_header.datasize=size(out_data);

%fix events
if isfield(out_header,'events');
    if isempty(out_header.events);
    else
        j=1;
        delete_events=[];
        for i=1:length(out_header.events);
            a=find(accepted_epochs==out_header.events(i).epoch);
            out_header.events(i).epoch=a;
            if isempty(a);
                delete_events(j)=i;
                j=j+1;
            end;
        end;
        out_header.events(delete_events)=[];
    end;
end;

%fix epochdata
if isfield(out_header,'epochdata');
    if isempty(out_header.epochdata);
    else
        out_header.epochdata=out_header.epochdata(accepted_epochs);
    end;
end;


