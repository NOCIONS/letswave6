function [out_header,out_data,message_string]=RLW_butterworth_filter(header,data,varargin);
%RLW_butterworth_filter
%
%Baseline correction
%
%varargin
%'filter_type' : 'bandpass','lowpass','highpass','notch'
%'low_cutoff' : 0.5
%'high_cutoff' : 30
%'filter_order' : 4
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

filter_type='bandpass';
low_cutoff=0.5;
high_cutoff=30;
filter_order=4;

%parse varagin
if isempty(varargin);
else
    %filter_type
    a=find(strcmpi(varargin,'filter_type'));
    if isempty(a);
    else
        filter_type=varargin{a+1};
    end;
    %low_cutoff
    a=find(strcmpi(varargin,'low_cutoff'));
    if isempty(a);
    else
        low_cutoff=varargin{a+1};
    end;
    %high_cutoff
    a=find(strcmpi(varargin,'high_cutoff'));
    if isempty(a);
    else
        high_cutoff=varargin{a+1};
    end;
    %filter_order
    a=find(strcmpi(varargin,'filter_order'));
    if isempty(a);
    else
        filter_order=varargin{a+1};
    end
end

%init message_string
message_string={};
message_string{1}='Butterworth filter';

%prepare out_header
out_header=header;

%init out_data
out_data=zeros(size(data));

%sampling rate and half sampling rate
Fs=1/header.xstep;
fnyquist=Fs/2;

%filter order : filtOrder
filtOrder=filter_order;
bandpass_implem = 1 ; % implement the bandpass filter without doing a LP followed by a HP filter

%b,a
switch filter_type
    case 'lowpass'
        message_string{end+1}='Building lowpass filter.';
        [b,a]=butter(filtOrder,high_cutoff/fnyquist,'low');
    case 'highpass'
        message_string{end+1}='Building highpass filter.';
        [b,a]=butter(filtOrder,low_cutoff/fnyquist,'high');
    case 'bandpass'
        if mod(filter_order,2);
            message_string{end+1}='Warning : even number of filter order is needed.';
            message_string{end+1}=['Converting order from ' num2str(filtOrder) ' to ' num2str(filtOrder-1) '.'];
            filtOrder=filtOrder-1;
            filter_order=filtOrder;
        end
        filtOrder=filtOrder/2;
        message_string{end+1}='Building bandpass filter.';
        if bandpass_implem
            [b,a] = butter(filtOrder,[low_cutoff,high_cutoff]./fnyquist,'bandpass') ; 
        else        
            [bLow,aLow]=butter(filtOrder,high_cutoff/fnyquist,'low');
            [bHigh,aHigh]=butter(filtOrder,low_cutoff/fnyquist,'high');
            b=[bLow;bHigh];
            a=[aLow;aHigh];
        end
    case 'notch'
        message_string{end+1}='Building notch filter.';
        [b,a]=butter(filtOrder,[low_cutoff/fnyquist high_cutoff/fnyquist],'stop');
end

%loop through all the data
for epochpos=1:size(data,1);
    for chanpos = 1:size(data,2);
        for indexpos=1:size(data,3);
            for dz=1:size(data,4);
                for dy=1:size(data,5);
                    switch filter_type
                        case 'lowpass'
                            out_data(epochpos,chanpos,indexpos,dz,dy,:)=filtfilt(b,a,squeeze(data(epochpos,chanpos,indexpos,dz,dy,:)));
                        case 'highpass'
                            out_data(epochpos,chanpos,indexpos,dz,dy,:)=filtfilt(b,a,squeeze(data(epochpos,chanpos,indexpos,dz,dy,:)));
                        case 'bandpass'
                            if bandpass_implem
                                out_data(epochpos,chanpos,indexpos,dz,dy,:)=filtfilt(b,a,squeeze(data(epochpos,chanpos,indexpos,dz,dy,:)));
                            else
                                out_data(epochpos,chanpos,indexpos,dz,dy,:)=filtfilt(b(1,:),a(1,:),squeeze(data(epochpos,chanpos,indexpos,dz,dy,:)));
                                out_data(epochpos,chanpos,indexpos,dz,dy,:)=filtfilt(b(2,:),a(2,:),squeeze(out_data(epochpos,chanpos,indexpos,dz,dy,:)));
                            end
                        case 'notch'
                            out_data(epochpos,chanpos,indexpos,dz,dy,:)=filtfilt(b,a,squeeze(data(epochpos,chanpos,indexpos,dz,dy,:)));
                    end
                end
            end
        end
    end
end


