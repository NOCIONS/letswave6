function data = module_read_neurone_data(binDataFiles, channelCount, ...
    samplingRate, memoryAvailable, varargin)
%MODULE_READ_NEURONE_DATA   Read NeurOne binary data
%
%  Version 1.1.3.8 (2014-12-04)
%  See version_history.txt for details.
%
%  Read NeurOne binary data and display progress bar.
%  Helper function to be used together with module_read_neurone.
%  Input argument binDataFiles is a cell containing file
%  names with full path to be read.
%
%  It is assumed that the data found in the files should be combined
%  into a large single file with data.
%
%  Inputs
%         binDataFiles    : cell array of string with full paths to files
%                           to be read
%         channelCount    : integer defining how many channels are present
%                           in the measurement.
%         samplingRate    : the sampling rate of the measurement.
%         memoryAvailable : amount of memory for matlab to use. Reading
%                           chunk size is optimized base on this.
%
%  Variable input arguments:
%         offset          : offset in bytes (if recording split into 
%                           multiple files).
%         channels        : indexes of channels to read data from (0-based)
%
%  Output : Matrix with all the data from the recordings, with each channel
%           in one column of the matrix.
%
%  Dependencies : textprogressbar
%
%  Module_read_neurone_data is part of NeurOne Tools for Matlab.
%
%  The NeurOne Tools for Matlab consists of the functions:
%       module_read_neurone.m, module_read_neurone_data.m,
%       module_read_neurone_events.m, module_read_neurone_xml.m
%
%  ========================================================================
%  COPYRIGHT NOTICE
%  ========================================================================
%  Copyright 2009 - 2014
%  Andreas Henelius (andreas.henelius@ttl.fi)
%  Finnish Institute of Occupational Health (http://www.ttl.fi/)
%  and
%  Mega Electronics Ltd (mega@megaemg.com, http://www.megaemg.com)
%  ========================================================================
%  This file is part of NeurOne Tools for Matlab.
% 
%  NeurOne Tools for Matlab is free software: you can redistribute it
%  and/or modify it under the terms of the GNU General Public License as
%  published by the Free Software Foundation, either version 3 of the
%  License, or (at your option) any later version.
%
%  NeurOne Tools for Matlab is distributed in the hope that it will be
%  useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with NeurOne Tools for Matlab.
%  If not, see <http://www.gnu.org/licenses/>.
%  ========================================================================

%% Parse input arguments and replace default values if given as input
p = inputParser;
p.addRequired('binDataFiles', @iscellstr);
p.addRequired('channelCount', @isnumeric);
p.addRequired('samplingRate', @isnumeric);
p.addRequired('memoryAvailable', @isnumeric);
p.addOptional('offset', 0, @isnumeric);
p.addOptional('channels', [], @isnumeric);

p.parse(binDataFiles, channelCount, samplingRate, memoryAvailable, ...
    varargin{:});
Arg = p.Results;

offsetBytes = Arg.offset .* Arg.samplingRate .* Arg.channelCount .* 4;
nbinDataFiles = numel(binDataFiles);

% =======================================================================
% Store all file sizes
% =======================================================================
fileSizes = [];
for n=1:nbinDataFiles
    tmp = dir(binDataFiles{n});
    fileSizes = [fileSizes ; tmp.bytes];
end
fileSizes = cumsum(fileSizes);

% =======================================================================
% Determine in which of the bin-files the starting point of the data is,
%  i.e. the offset in bytes.
% =======================================================================
if offsetBytes < fileSizes(1);
    startIndex = 1;
else
    startIndex = find((fileSizes <= offsetBytes),1,'last');
end

% =======================================================================
% Calculate offsetBytes with respect to the startIndex
% =======================================================================
if (startIndex ==1)
    % do nothing
elseif (startIndex > 1)
    offsetBytes = sum(fileSizes((1:(startIndex-1)))) - offsetBytes;
end

% =======================================================================
% Get max file size and adjust chunk size for fread()
% =======================================================================
fSize = fileSizes(1);
CHUNKFACTOR = 100;
chunkSize = floor(fSize / 4 / CHUNKFACTOR);

while (chunkSize > memoryAvailable)
    chunkSize = chunkSize - 1000;
end

% =======================================================================
% Vector to hold the data
% =======================================================================
y = [];

% =======================================================================
% Initialise progress bar
% =======================================================================
nBinFiles = numel(nbinDataFiles);
scaleFactor = 100 / (CHUNKFACTOR*nBinFiles+nBinFiles) / ...
    (fileSizes(end)/fileSizes(1));

% =======================================================================
% Read data from files
% =======================================================================
i = 1;

% Read all channels (faster)
if (isempty(Arg.channels))
    textprogressbar('Reading NeurOne data: ');
    
    for n=startIndex:nbinDataFiles
        f = fopen([binDataFiles{n}], 'rb');
        while ~feof(f)
            data = fread(f, chunkSize, 'int32');
            textprogressbar(i * scaleFactor);
            y = vertcat(y, data);
            i = i + 1 ;
        end
        fclose(f);
    end
    
    % Reformat data into data matrix, one channel per column
    data = zeros(numel(y) / channelCount, channelCount);
    for i=1:channelCount
        data(:,i) = y(i:channelCount:end);
    end
    
else
    
    chInd = Arg.channels;
    numChans = length(chInd);
    fprintf('Reading only channels: %s\n', mat2str(chInd));
    textprogressbar('Reading NeurOne data: ');
    
    % adjust chunksize so that it's a multiple of channel count * 4
    % this way we preserve channel alignment
    chunkSize = chunkSize + mod(chunkSize, (channelCount*4));
       
    % read each channel separately
    for c=1:numChans
        for n=startIndex:nbinDataFiles
            % open the file
            f = fopen([binDataFiles{n}], 'rb');
            % seek to 1st sample of the channel
            offset = 4*(chInd(c) - 1);
            fseek(f, offset, 'bof');
            % read samples of the channel
            while ~feof(f)
                % read a chunk of data and extract one channel
                dataOneChannel = fread(f, chunkSize, 'int32');                
                dataOneChannel = dataOneChannel(1:channelCount:end);

                y = vertcat(y, dataOneChannel);
                i = i + 1;
                progress = i * scaleFactor / numChans;
                textprogressbar(progress);
            end
            fclose(f);
        end
    end

    % adjust channelCount
    channelCount = numChans;
    numSamp = floor(length(y) / channelCount);
    % Reformat data into data matrix, one channel per column
    data = reshape(y, numSamp, channelCount);
end

textprogressbar(' Done.')

% =======================================================================
% Convert data to microvolts from nanovolts
% =======================================================================
data = data ./ 1000;