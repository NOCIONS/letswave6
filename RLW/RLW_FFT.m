function [out_header,out_data,message_string,time_header]=RLW_FFT(header,data,varargin);
%RLW_FFT
%
%FFT
%
%varargin
%'output' ('amplitude') %'power','amplitude','complex','phase','real','imag','special'
%'half_spectrum' (1)
%'normalize' (1 or 2 - divide by N or N/2)
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

output='amplitude';
half_spectrum=1;
normalize=1;

time_header=[];

%parse varagin
if isempty(varargin);
else
    %output
    a=find(strcmpi(varargin,'output'));
    if isempty(a);
    else
        output=varargin{a+1};
    end;
    %half_spectrum
    a=find(strcmpi(varargin,'half_spectrum'));
    if isempty(a);
    else
        half_spectrum=varargin{a+1};
    end;
    %normalize
    a=find(strcmpi(varargin,'normalize'));
    if isempty(a);
    else
        normalize=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='FFT transform.';

%warning
if strcmpi(header.filetype,'time_amplitude');
else
    message_string{end+1}='!!! WARNING : input data is not of format time_amplitude!';
end;

%out_header
out_header=header;

%adjust header
%xstart
out_header.xstart=0;
%xsize=samplingrate
out_header.xstep=1/(out_header.xstep*size(data,6));
%filetype
switch output;
    case 'power';
        out_header.filetype='frequency_power';
    case 'amplitude';
        out_header.filetype='frequency_amplitude';
    case 'phase'
        out_header.filetype='frequency_phase';
    case 'complex'
        out_header.filetype='frequency_complex';
end;

%delete events
if isfield(out_header,'events');
    out_header=rmfield(out_header,'events');
end;

message_string{end+1}=['Output : ' output];

out_data=zeros(size(data));

%loop through all the data
for epochpos=1:size(data,1);
    for channelpos=1:size(data,2);
        for indexpos=1:size(data,3);
            for dz=1:size(data,4);
                for dy=1:size(data,5);
                    switch output;
                        case 'complex'
                            out_data(epochpos,channelpos,indexpos,dz,dy,:)=fft(data(epochpos,channelpos,indexpos,dz,dy,:));
                        case 'amplitude'
                            out_data(epochpos,channelpos,indexpos,dz,dy,:)=abs(fft(data(epochpos,channelpos,indexpos,dz,dy,:)));
                        case 'power'
                            out_data(epochpos,channelpos,indexpos,dz,dy,:)=abs(fft(data(epochpos,channelpos,indexpos,dz,dy,:)));
                            %will be squared later on in process
                        case 'phase'
                            out_data(epochpos,channelpos,indexpos,dz,dy,:)=angle(fft(data(epochpos,channelpos,indexpos,dz,dy,:)));
                        case 'real'
                            out_data(epochpos,channelpos,indexpos,dz,dy,:)=real(fft(data(epochpos,channelpos,indexpos,dz,dy,:)));
                        case 'imag'
                            out_data(epochpos,channelpos,indexpos,dz,dy,:)=imag(fft(data(epochpos,channelpos,indexpos,dz,dy,:)));
                        case 'special'
                    end;
                end;
            end;
        end;
    end;
end;

%normalize?
if normalize>0;
    if or(strcmpi(output,'power'),strcmpi(output,'amplitude'));      
        if normalize==1;
            message_string{end+1}='Normalizing spectrum (divide by N)';
            out_data=out_data/size(out_data,6);
        end
        if normalize==2;
            message_string{end+1}='Normalizing spectrum (divide by N/2)';
            out_data=out_data/(size(out_data,6)/2);
        end
    else
        message_string{end+1}='Normalize was chosen, but will not be applied.';
        message_string{end+1}='Normalize is only valid for amplitude and power.';
    end;
end;

%square? (power)
if strcmpi(output,'power');
    out_data=out_data.^2;
end;

%half spectrum?
if half_spectrum==1;
    message_string{end+1}='Keeping only first half of spectrum';
    out_data=out_data(:,:,:,:,:,1:fix(size(out_data,6)/2));
    out_header.datasize=size(out_data);
end;

%time_header?
%only if complex
if strcmpi(output,'complex');
    time_header=header;
end;


