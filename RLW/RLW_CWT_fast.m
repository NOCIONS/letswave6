function [out_header,out_data,message_string]=RLW_CWT_fast(header,data,varargin);
%RLW_CWT_fast
%
%Fast Continuous Wavelet Transform
%
%varargin
%
%'mother_name ('morlet') 'morlet' 'hanning'
%'mother_frequency (5)
%'mother_spread (0.15)
%'mother_size (8000)
%'low_frequency (1)
%'high_frequency (30)
%'num_frequency_lines (100)
%'segment_data (0)
%'event_name ([])
%'x_start (-0.5)
%'x_end (1)
%'output ('amplitude') 'amplitude','power','phase','real','imag'
%'average_epochs (1)
%'yaxis' 'linear' 'log10'
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

mother_name='morlet';
mother_frequency=5;
mother_spread=0.15;
mother_size=8000;
low_frequency=1;
high_frequency=30;
num_frequency_lines=100;
segment_data=0;
event_name=[];
x_start=-0.5;
x_end=1;
output='amplitude';
average_epochs=1;
yaxis='linear';


%parse varagin
if isempty(varargin);
else
    %mother_name
    a=find(strcmpi(varargin,'mother_name'));
    if isempty(a);
    else
        mother_name=varargin{a+1};
    end;
    %mother_frequency
    a=find(strcmpi(varargin,'mother_frequency'));
    if isempty(a);
    else
        mother_frequency=varargin{a+1};
    end;
    %mother_spread
    a=find(strcmpi(varargin,'mother_spread'));
    if isempty(a);
    else
        mother_spread=varargin{a+1};
    end;
    %mother_size
    a=find(strcmpi(varargin,'mother_size'));
    if isempty(a);
    else
        mother_size=varargin{a+1};
    end;
    %low_frequency
    a=find(strcmpi(varargin,'low_frequency'));
    if isempty(a);
    else
        low_frequency=varargin{a+1};
    end;
    %high_frequency
    a=find(strcmpi(varargin,'high_frequency'));
    if isempty(a);
    else
        high_frequency=varargin{a+1};
    end;
    %num_frequency_lines
    a=find(strcmpi(varargin,'num_frequency_lines'));
    if isempty(a);
    else
        num_frequency_lines=varargin{a+1};
    end;
    %segment_data
    a=find(strcmpi(varargin,'segment_data'));
    if isempty(a);
    else
        segment_data=varargin{a+1};
    end;
    %event_name
    a=find(strcmpi(varargin,'event_name'));
    if isempty(a);
    else
        event_name=varargin{a+1};
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
    %output
    a=find(strcmpi(varargin,'output'));
    if isempty(a);
    else
        output=varargin{a+1};
    end;
    %average_epochs
    a=find(strcmpi(varargin,'average_epochs'));
    if isempty(a);
    else
        average_epochs=varargin{a+1};
    end;
    %yaxis
    a=find(strcmpi(varargin,'yaxis'));
    if isempty(a);
    else
        yaxis=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='Fast CWT';

%prepare out_header
out_header=header;

%calculate mother wavelet : wav1, wav2
%adapted from LW5 : [wav1 wav2]=LW_fastwavelet_mother(type,periods,stdev,mothersize);
switch mother_name
    case 'morlet'
        message_string{end+1}='Using a Morlet mother wavelet.';
        idx=0:1:mother_size-1;
        idx=(idx-(mother_size/2))/(mother_size-1);
        tp1=sin(idx*2*pi*mother_frequency);
        tp2=cos(idx*2*pi*mother_frequency);
        tpp=-(idx.^2)/(2*mother_spread^2);
        tp3=exp(tpp);
        wav1=tp1.*tp3;
        wav2=tp2.*tp3;
    case 'hanning'
        message_string{end+1}='Using a Hanning mother wavelet.';
        id=0:1:mother_size-1;
        idx=(id-(mother_size/2))/(mother_size-1);
        tp1=sin(idx*2*pi*mother_frequency);
        tp2=cos(idx*2*pi*mother_frequency);
        tp3=0.5*(1-cos((2*pi*id)/mother_size));
        wav1=tp1.*tp3;
        wav2=tp2.*tp3;
        wav1 = single(wav1);
        wav2 = single(wav2);
end;

%parameters
srate=1/header.xstep;
xsize=header.datasize(6);
xstep=header.xstep;
xstart=header.xstart;

%ystep,ystart,ysize
ystep=(high_frequency-low_frequency)/num_frequency_lines;
ystart=low_frequency;
ysize=num_frequency_lines;

%initialize data (make sure that it is single)
data=single(data);
outarray1=zeros(ysize,xsize,'single');
outarray2=zeros(ysize,xsize,'single');

%update out_header
out_header=header;
out_header.datasize(5)=ysize;
out_header.ystart=ystart;
out_header.ystep=ystep;

%update filetype
switch output
    case 'amplitude'
        out_header.filetype='frequency_time_amplitude';
    case 'power'
        out_header.filetype='frequency_time_power';
    case 'phase'
        out_header.filetype='frequency_time_phase';
    case 'real'
        out_header.filetype='frequency_time_amplitude';
    case 'imag'
        out_header.filetype='frequency_time_amplitude';
end;

%prepare out_data
out_data=zeros(out_header.datasize,'single');

%initialize y,z
z=1;
y=1;

%initialize TSPEC
TSPEC1=cell(1,ysize);
TSPEC2=cell(1,ysize);

%hzi
if strcmpi(yaxis,'linear');
    hzi=linspace(low_frequency,high_frequency,num_frequency_lines);
else
    hzi=logspace(log10(low_frequency),log10(high_frequency),num_frequency_lines);
end;

%loop through dy
for dy=1:ysize;
    %compress wavelet
    specsize=round((srate*mother_frequency)/hzi(dy));
    %specsizediv2=floor(specsize/2);
    specinc=mother_size/specsize;
    tps=floor(0:specinc:(specinc*(specsize-1)))+1;
    tspec1=wav1(tps)';
    tspec2=wav2(tps)';
    wavScale=sqrt(hzi/mother_frequency);
    TSPEC1{dy}=tspec1*wavScale;
    TSPEC2{dy}=tspec2*wavScale;
end;

%!!! Compute the fast CWT !!!
%loop through epochs
for epoch=1:header.datasize(1);
    %loop through channels
    for channel=1:header.datasize(2);
        %loop through index
        for index=1:header.datasize(3);
            disp(['E:',num2str(epoch),' C:',num2str(channel),' I:',num2str(index)]);
            for dy=1:ysize;
                R=squeeze(data(epoch,channel,index,z,y,:))';
                outarray1(dy,:)=conv2(R,TSPEC1{dy}','same');
                outarray2(dy,:)=conv2(R,TSPEC2{dy}','same');
            end;
            %postprocess
            switch output
                case 'amplitude'
                    out_data(epoch,channel,index,z,:,:)=sqrt(outarray1.^2+outarray2.^2);
                case 'power'
                    out_data(epoch,channel,index,z,:,:)=outarray1.^2+outarray2.^2;
                case 'phase'
                    out_data(epoch,channel,index,z,:,:)=atan2(outarray2,outarray1);
                case 'real'
                    out_data(epoch,channel,index,z,:,:)=outarray1;
                case 'imag'
                    out_data(epoch,channel,index,z,:,:)=outarray2;
            end;
        end;
    end;
end;

%!!! End Compute Fast CWT !!!
%segment if checked
if segment_data==1;
    k=1;
    message_string{end+1}='Attempting to segment the data.';
    event_idx=[];
    if isfield(out_header,'events');
        if isempty(out_header.events);
            message_string{end+1}='Event field of dataset is empty! Skipping segmentation.';
        else
            %event_name
            event_name=event_name;
            message_string{end+1}='Segmenting continuous data into epochs.';
            message_string{end+1}=['Searching for event : ' event_name];
            %event_string, event_latency
            for i=1:length(out_header.events);
                event_string{i}=out_header.events(i).code;
            end;
            %find event_name in event_string
            a=find(strcmpi(event_name,event_string));
            if isempty(a);
                event_idx=[];
            else
                event_idx=a;
            end;
        end;
    else
        message_string{end+1}='No event field in the dataset! Skipping segmentation.';
    end;
    if isempty(event_idx);
        message_string{end+1}='No events found, saving continuous data.';
    else
        %corresponding events were found, so, we proceed
        message_string{end+1}=[num2str(length(event_idx)) ' corresponding events found in dataset.'];
        %adjust header
        %dxsize
        dxsize=fix((x_end-x_start)/out_header.xstep)+1;
        %set datasize
        out_header.datasize(1)=length(event_idx);
        out_header.datasize(6)=dxsize;
        %prepare out_data
        data=out_data;
        out_data=zeros(out_header.datasize);
        %initialize out_events
        k=1;
        out_events=header.events(1);
        %loop through events_latencies
        for i=1:length(event_idx);
            %dx1
            dx1=fix((((header.events(event_idx(i)).latency+x_start)-header.xstart)/header.xstep))+1;
            %dx2
            dx2=(dx1+dxsize)-1;
            %out_data > epoch(i)
            out_data(i,:,:,:,:,:)=data(header.events(event_idx(i)).epoch,:,:,:,:,dx1:dx2);
            %scan for events within epoch
            for j=1:length(header.events);
                %check epoch
                if header.events(j).epoch==header.events(event_idx(i)).epoch;
                    %new latency
                    new_latency=header.events(j).latency-header.events(event_idx(i)).latency;
                    %check if inside epoch limits
                    if new_latency>=x_start;
                        if new_latency<=(x_end);
                            %add event
                            out_events(k)=header.events(j);
                            out_events(k).latency=new_latency;
                            out_events(k).epoch=i;
                            k=k+1;
                        end;
                    end;
                end;
            end;
        end;
    end;
    %header.events
    if k==1;
        out_events=[];
    end;
    out_header.events=out_events;
    %delete epochdata
    if isfield(out_header,'epochdata');
        rmfield(out_header,'epochdata');
    end;
    %adjust xstart
    out_header.xstart=x_start;
end;

%average?
if average_epochs==1;
    message_string{end+1}='Averaging epochs';
    %change number of epochs to 1
    out_header.datasize(1)=1;
    %PLV?
    if strcmpi(output,'phase');
        %PLV
        message_string{end+1}='Average phase values selected.';
        message_string{end+1}='Will compute the Phase Locking Value (PLV).';
        %compute PLV
        x=sum(sin(out_data),1);
        y=sum(cos(out_data),1);
        out_data=sqrt(x.^2+y.^2);
        out_data=out_data/header.datasize(1);
    else
        %standard average
        out_data=mean(out_data,1);
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
end;
    


