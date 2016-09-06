function [out_header,out_data,message_string]=RLW_average_epochs_sliding(header,data,varargin);
%RLW_average_erpimage
%
%Average ERPimage
%
%header
%data
%
%varargin
%
%'num_lines' (100)
%'x_start' (epoch start)
%'x_end' (epoch end)
%'smooth' (1)
%'smooth_width' (5)
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

num_lines=100;
x_start=header.xstart;
x_end=header.xstart+((header.datasize(6)-1)*header.xstep);
smooth=1;
smooth_width=5;

%parse varagin
if isempty(varargin);
else
    %num_lines
    a=find(strcmpi(varargin,'num_lines'));
    if isempty(a);
    else
        num_lines=varargin{a+1};
    end;
    %x_start
    a=find(strcmpi(varargin,'x_start'));
    if isempty(a);
    else
        x_start=varargin{a+1};
    end;
    %x_end
    a=find(strcmpi(varargin,'x_end'));
    if isempty(a);
    else
        x_end=varargin{a+1};
    end;
    %smooth
    a=find(strcmpi(varargin,'smooth'));
    if isempty(a);
    else
        smooth=varargin{a+1};
    end;
    %smooth_width
    a=find(strcmpi(varargin,'smooth_width'));
    if isempty(a);
    else
        smooth_width=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}=['Number of lines : ' num2str(num_lines)];
message_string{4}=['Smooth : ' num2str(smooth)];
message_string{5}=['Smooth width : ' num2str(smooth_width)];


%prepare out_header
out_header=header;

%check Ydim
if header.datasize(5)>1;
    message_string{end+1}='Warning : the ERPimage will be computed using only the first bin of the Y dimension';
    data(:,:,:,:,:,:)=data(:,:,:,:,1,:);
end;

%x_start,x_end > dx1,dx2
dx1=fix(((x_start-header.xstart)/header.xstep))+1;
dx2=fix(((x_end-header.xstart)/header.xstep))+1;
message_string{end+1}=['XStart : ' num2str(x_start) ' XEnd : ' num2str(x_end)];
message_string{end+1}=['DXStart : ' num2str(dx1) ' DXEnd : ' num2str(dx2)];
if dx1<1;
    dx1=1;
    message_string{end+1}='DXStart changed to 1. Else, it would be outside matrix range';
end;
if dx2>header.datasize(6);
    dx2=header.datasize(6);
    message_string{end+1}=['DXEnd changed to ' num2str(dx2) '. Else, it would be outside matrix range'];
end;

%hanning smoothing?
if smooth==1;
    if smooth_width>1;
        message_string{end1}='Hanning smoothing will be applied across trials.';
        hanningwidth=smooth_width;
        %hanning function
        tp=hanning(hanningwidth);
        for dx=1:size(data,6);
            han(:,dx)=tp;
        end;
        hanningwidth2=floor(hanningwidth/2);
        hanningwidth=(2*hanningwidth2)+1;
        message_string{end+1}=['Hanning window width : ' num2str(hanningwidth)];
    else
        message_string{end+1}='Hanning window width should be >1. No smoothing will be applied.';
        smooth=0;
    end;
end;

%change number of epochs
out_header.datasize(1)=1;
            
%figure out out_header.datasize
if num_lines==header.datasize(1)
    %the number of epochs corresponds to the number of lines
    message_string{end+1}='Number of epochs equals number of lines. No resampling is needed.';
    message_string{end+1}=['Number of lines : ' num2str(num_lines)];
    out_header.ystart=1;
    out_header.ystep=1;
    out_header.datasize(5)=header.datasize(1);
    out_header.datasize(6)=(dx2-dx1)+1;
else
    %the number of epochs does not correspond to the number of
    %lines : rescaling will be applied
    message_string{end+1}='Number of epochs does not equal number of lines. Resampling.';
    message_string{end+1}=['Number of lines : ' num2str(num_lines)];
    out_header.ystart=1;
    %yq
    yq=linspace(1,header.datasize(1),num_lines);
    out_header.ystep=yq(2)-yq(1);
    out_header.datasize(5)=num_lines;
    %xq
    xq=dx1:1:dx2;
    %y
    y=1:1:header.datasize(1);
    %x
    x=1:1:header.datasize(6);
    out_header.datasize(6)=(dx2-dx1)+1;
end;

message_string{end+1}=['YStep : ' num2str(out_header.ystep)];

%change filetype
tp=header.filetype;
a=find(tp=='_');
if isempty(a);
    filetype='time_epochs_value';
else
    unit=tp(a(end)+1:end);
    if length(a)==1;
        x_unit=tp(1:a(end)-1)
    else
        x_unit=tp(a(end-1)+1:a(end)-1);
    end;
end;
out_header.filetype=[x_unit '_epochs_' unit];
            
%prepare out_data
out_data=zeros(out_header.datasize);

%loop through channels
for chanpos=1:size(data,2);
    %loop through index
    for indexpos=1:size(data,3);
        %loop through Z
        for zpos=1:size(data,4);
            disp(['C:' num2str(chanpos) ' I:' num2str(indexpos) ' Z:' num2str(zpos)]);
            %fetch data
            or_data=squeeze(data(:,chanpos,indexpos,zpos,1,:));
            han_data=or_data;
            %check if hanning smoothing should be applied
            if smooth==1;
                %loop through epochs
                for epochpos=1:size(or_data,1);
                    dy1=epochpos-hanningwidth2;
                    dy2=epochpos+hanningwidth2;
                    if dy1<1;
                        dy1=1;
                    end;
                    if dy2>size(or_data,1);
                        dy2=size(or_data,1);
                    end;
                    hdy1=dy1-epochpos+(hanningwidth2+1);
                    hdy2=dy2-epochpos+(hanningwidth2+1);
                    han_data(epochpos,:)=squeeze(mean(or_data(dy1:dy2,:).*han(hdy1:hdy2,:),1));
                end;
            end;
            %rescale if needed; else crop
            if num_lines==header.datasize(1);
                rs_han_data=han_data(:,dx1:dx2);
            else
                rs_han_data=griddata(x,y',han_data,xq,yq','cubic');
            end;
            %out_data
            out_data(1,chanpos,indexpos,zpos,:,:)=rs_han_data;
        end;
    end;
end;

%adjust events
if isfield(out_header,'events');
    for event_pos=1:length(out_header.events);
        out_header.events(event_pos).epoch=1;
    end;
end;

%delete epochdata
if isfield(out_header,'epochdata');
    rmfield(out_header,'epochdata');
end;



