function [out_header,out_data,message_string]=RLW_FFT_filter(header,data,varargin);
%RLW_FFT_filter
%
%FFT filter
%
%varargin
%'filter_type' ('bandpass')  'bandpass','lowpass','highpass','notch'
%'low_cutoff' (0.5)
%'high_cutoff' (30)
%'low_width (0.25)
%'high_width' (1)
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
low_width=0.25;
high_width=1;

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
    %low_width
    a=find(strcmpi(varargin,'low_width'));
    if isempty(a);
    else
        low_width=varargin{a+1};
    end;
    %high_width
    a=find(strcmpi(varargin,'high_width'));
    if isempty(a);
    else
        high_width=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='FFT filter';

%FFT
message_string{end+1}='Computing Forward FFT';
[FFT_header,FFT_data,message_string2,time_header]=RLW_FFT(header,data,'output','complex','half_spectrum',0,'normalize',0);
message_string=[message_string message_string2];

%setup filter vector
switch filter_type;
    case 'bandpass'
        message_string{end+1}='Bandpass filtering';
        vector=ILW_buildFFTbandpass(FFT_header,low_cutoff,high_cutoff,low_width,high_width);
    case 'lowpass'
        message_string{end+1}='Lowpass filtering';
        vector=ILW_buildFFTbandpass(FFT_header,0,high_cutoff,0,high_width);
    case 'highpass'
        message_string{end+1}='Highpass filtering';
        vector=ILW_buildFFTbandpass(FFT_header,low_cutoff,0,low_width,0);
    case 'notch'
        message_string{end+1}='Notch filtering';
        vector=ILW_buildFFTbandpass(FFT_header,low_cutoff,high_cutoff,low_width,high_width);
        vector=(vector-1)*-1;
end;

message_string{end+1}='Filtering FFT product';

%filter
%multiply vector
%loop through all the data
for epochpos=1:size(FFT_data,1);
    for channelpos=1:size(FFT_data,2);
        for indexpos=1:size(FFT_data,3);
            for dz=1:size(FFT_data,4);
                for dy=1:size(FFT_data,5);
                    FFT_data(epochpos,channelpos,indexpos,dz,dy,:)=squeeze(FFT_data(epochpos,channelpos,indexpos,dz,dy,:)).*vector;
                end;
            end;
        end;
    end;
end;

%iFFT
message_string{end+1}='Computing Inverse FFT';
[out_header,out_data,message_string2]=RLW_iFFT(FFT_header,FFT_data,'time_header',time_header,'force_real',1);
message_string=[message_string message_string2];



