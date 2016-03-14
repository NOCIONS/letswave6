function [out_header,out_data,message_string]=RLW_iFFT(header,data,varargin);
%RLW_iFFT
%
%Inverse FFT
%
%varargin
%'time_header' (header with time date)
%'force real' (1)
%
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

time_header=[];
force_real=1;

out_header=header;
out_data=[];

%parse varagin
if isempty(varargin);
else
    %force_real
    a=find(strcmpi(varargin,'force_real'));
    if isempty(a);
    else
        force_real=varargin{a+1};
    end;
    %time_header
    a=find(strcmpi(varargin,'time_header'));
    if isempty(a);
    else
        time_header=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='Inverse FFT transform.';

%warning
if strcmpi(header.filetype,'frequency_complex');
else
    message_string{end+1}='!!! WARNING : input data is not of format frequency_complex!';
end;

if isempty(time_header);
    %find time_header in history
    time_header=[];
    for i=1:length(header.history);
        if strcmpi(header.history(i).configuration.gui_info.function_name,'LW_FFT');
            time_header=header.history(i).configuration.parameters.time_header;
        end;
    end;
end;

%check time_header
if isempty(time_header);
    message_string{end+1}='!!! ERROR : could not find a time_header in HISTORY!';
    return;
end;

%update header with time information (from time_header)
out_header.xstart=time_header.xstart;
out_header.xstep=time_header.xstep;

%restore events from time_header
if isfield(time_header,'events');
    out_header.events=time_header.events;
end;
            
%change filetype
out_header.filetype='time_amplitude';
out_data=zeros(time_header.datasize);

%loop through all the data
if force_real==1;
    for epochpos=1:size(data,1);
        for channelpos=1:size(data,2);
            for indexpos=1:size(data,3);
                for dz=1:size(data,4);
                    for dy=1:size(data,5);
                        out_data(epochpos,channelpos,indexpos,dz,dy,:)=real(ifft(data(epochpos,channelpos,indexpos,dz,dy,:)));
                    end;
                end;
            end;
        end;
    end;
else
    for epochpos=1:size(data,1);
        for channelpos=1:size(data,2);
            for indexpos=1:size(data,3);
                for dz=1:size(data,4);
                    for dy=1:size(data,5);
                        out_data(epochpos,channelpos,indexpos,dz,dy,:)=ifft(data(epochpos,channelpos,indexpos,dz,dy,:));
                    end;
                end;
            end;
        end;
    end;
end;
message_string{end+1}='Finished computing iFFT.';


