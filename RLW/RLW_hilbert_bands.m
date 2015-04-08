function [out_header,out_data,message_string]=RLW_hilbert_bands(header,data,varargin);
%RLW_hilbert_bands
%
%Hilbert transform across multiple frequency bands
%
%varargin
%'freq_width'
%'freq_start'
%'freq_end'
%'freq_lines'
%'filter_order'
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

freq_width=5;
freq_start=50;
freq_end=300;
freq_lines=100;
filter_order=4;

%parse varagin
if isempty(varargin);
else
    %freq_width
    a=find(strcmpi(varargin,'freq_width'));
    if isempty(a);
    else
        freq_width=varargin{a+1};
    end;
    %freq_start
    a=find(strcmpi(varargin,'freq_start'));
    if isempty(a);
    else
        freq_start=varargin{a+1};
    end;
    %freq_end
    a=find(strcmpi(varargin,'freq_end'));
    if isempty(a);
    else
        freq_end=varargin{a+1};
    end;
    %freq_lines
    a=find(strcmpi(varargin,'freq_lines'));
    if isempty(a);
    else
        freq_lines=varargin{a+1};
    end;
    %filter_order
    a=find(strcmpi(varargin,'filter_order'));
    if isempty(a);
    else
        filter_order=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='Hilbert transform (multiple frequency bands)';
message_string{end+1}='This can take a while!!!';

%out_header
out_header=header;

%freq_vector
freq_vector=linspace(freq_start,freq_end,freq_lines);
freq_vector1=freq_vector-(freq_width/2);
freq_vector2=freq_vector+(freq_width/2);

%sampling rate and half sampling rate
Fs=1/header.xstep;
fnyquist=Fs/2;

%filter order : filtOrder
filtOrder=filter_order;
if mod(filter_order,2);
    message_string{end+1}='Warning : even number of filter order is needed.';
    message_string{end+1}=['Converting order from ' num2str(filtOrder) ' to ' num2str(filtOrder-1) '.'];
    filtOrder=filtOrder-1;
    filter_order=filtOrder;
end
filtOrder=filtOrder/2;

%adjust out_header.datasize
out_header.datasize(5)=length(freq_vector);

%adjust out_header.ystart .ystep
out_header.ystart=freq_start;
out_header.ystep=freq_vector(2)-freq_vector(1);

%prepare out_data
out_data=zeros(out_header.datasize);

%loop through all the data (bandpass filter)
dy=1;
disp('Bandpass filter');
for epochpos=1:size(data,1);
    disp(['E : ' num2str(epochpos)])
    for chanpos=1:size(data,2);
        for indexpos=1:size(data,3);
            for dz=1:size(data,4);
                tpy=double(squeeze(data(epochpos,chanpos,indexpos,dz,1,:)));
                for freq_pos=1:length(freq_vector);
                    %a,b
                    [bLow,aLow]=butter(filtOrder,freq_vector2(freq_pos)/fnyquist,'low');
                    [bHigh,aHigh]=butter(filtOrder,freq_vector1(freq_pos)/fnyquist,'high');
                    b=[bLow;bHigh];
                    a=[aLow;aHigh];
                    out_data(epochpos,chanpos,indexpos,dz,freq_pos,:)=filtfilt(bLow,aLow,tpy);
                    out_data(epochpos,chanpos,indexpos,dz,freq_pos,:)=filtfilt(bHigh,aHigh,squeeze(out_data(epochpos,chanpos,indexpos,dz,1,:)));
                    %hilbert
                    out_data(epochpos,chanpos,indexpos,indexpos,dz,freq_pos,:);
                end;
            end;
        end;
    end;
end;

%loop through all the data (Hilbert)
disp('Hilbert transform.');
for epochpos=1:size(data,1);
    disp(['E : ' num2str(epochpos)])
    for indexpos=1:size(data,3);
        for dz=1:size(data,4);
            for dy=1:size(data,5);
                %hilbert
                out_data(epochpos,:,indexpos,dz,dy,:)=abs(hilbert(squeeze(data(epochpos,:,indexpos,dz,dy,:))'))';
            end;
        end;
    end;
end

%FFT
%adjust header
%xstart
out_header.xstart=0;
%xsize=samplingrate
out_header.xstep=1/(out_header.xstep*size(out_data,6));
%filetype
out_header.filetype='time_frequency_amplitude';

%delete events
if isfield(out_header,'events');
    out_header=rmfield(out_header,'events');
end;

data=out_data;
out_data=zeros(size(data));

%loop through all the data
disp('FFT');
for epochpos=1:size(data,1);
    disp(['E : ' num2str(epochpos)])
    for channelpos=1:size(data,2);
        for indexpos=1:size(data,3);
            for dz=1:size(data,4);
                for dy=1:size(data,5);
                    out_data(epochpos,channelpos,indexpos,dz,dy,:)=abs(fft(data(epochpos,channelpos,indexpos,dz,dy,:)));
                end;
            end;
        end;
    end;
end;

out_data=out_data/size(out_data,6);

out_data=out_data(:,:,:,:,:,1:fix(size(out_data,6)/2));
out_header.datasize=size(out_data);



