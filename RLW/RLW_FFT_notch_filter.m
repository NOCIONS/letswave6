function [out_header,out_data,message_string]=RLW_FFT_notch_filter(header,data,varargin);
%RLW_FFT_notchfilter
%
%FFT notch filter
%
%varargin
%'notch_frequency' ([8 16])
%'notch_width' (2)
%'notch_slope_width' (2)
%'invert_filter' (1)
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

notch_frequency=[8 16];
notch_width=2;
notch_slope_width=2;
invert_filter=1;

%parse varagin
if isempty(varargin);
else
    %notch_frequency
    a=find(strcmpi(varargin,'notch_frequency'));
    if isempty(a);
    else
        notch_frequency=varargin{a+1};
    end;
    %notch_width
    a=find(strcmpi(varargin,'notch_width'));
    if isempty(a);
    else
        notch_width=varargin{a+1};
    end;
    %notch_slope_width
    a=find(strcmpi(varargin,'notch_slope_width'));
    if isempty(a);
    else
        notch_slope_width=varargin{a+1};
    end;
    %invert_filter
    a=find(strcmpi(varargin,invert_filter'));
    if isempty(a);
    else
        invert_filter=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='FFT multinotch filter';

%FFT
message_string{end+1}='Computing Forward FFT';
[FFT_header,FFT_data,message_string2,time_header]=RLW_FFT(header,data,'output','complex','half_spectrum',0,'normalize',0);
message_string=[message_string message_string2];

%notch filter vector (1st frequency)
vector=ILW_buildFFTbandpass(FFT_header,notch_frequency(1)-(notch_width/2),notch_frequency(1)+(notch_width/2),notch_slope_width,notch_slope_width);
vector=(vector-1)*-1;

%loop through notch_frequencies if more than one frequency
if length(notch_frequency)>1;
    for i=2:length(notch_frequency);
    %notch filter vector
    vector2=ILW_buildFFTbandpass(FFT_header,notch_frequency(i)-(notch_width/2),notch_frequency(i)+(notch_width/2),notch_slope_width,notch_slope_width);
    vector2=(vector2-1)*-1;
    %multiply vectors
    vector=vector.*vector2;
    end;
end;
    
%invert?
if invert_filter==1;
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



