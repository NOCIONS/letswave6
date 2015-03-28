function recording = module_read_neurone(basePath, varargin)
%MODULE_READ_NEURONE   Read data from a Mega NeurOne device.
%
%  Input  : Path to directory containing NeurOne data files from one
%           measurement.
%  Variable input arguments:
%         : headerOnly <to be implemented>
%         : sessionPhaseNumber : specifies which session phase to be read,
%           if multiple sessions are present within the same
%
%  Output : A structure with all numerical data and all data from the
%           XML-files describing the experimental setup.
%
%  The function is capable of handling reading of files that have been
%  splitted due to large file size (0.bin, 1.bin, ... n.bin). The system
%  memory might not be sufficient to handle such large recordings.
%
%  Example: recording = module_read_neurone('/NeurOne/data_01/')
%
%  Dependencies: module_read_neurone_data, module_read_neurone_events,
%                module_read_neurone_xml, textprogressbar, catstruct
%
%  Module_read_neurone is part of NeurOne Tools for Matlab.
%
%  The NeurOne Tools for Matlab consists of the functions:
%       module_read_neurone.m, module_read_neurone_data.m,
%       module_read_neurone_events.m, module_read_neurone_xml.m
%
%  ========================================================================
%  COPYRIGHT NOTICE
%  ========================================================================
%  Copyright 2009 - 2012
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
%  Version 1.1.3.5 (2012-11-30)
%  See version_history.txt for details.

%% Define Constants
SESSIONFILE          = 'Session.xml';
PROTOCOLFILE         = 'Protocol.xml';

%% Parse input arguments
% Parse input arguments and replace default values if given as input
% inputParser was introduced in Matlab R2007a.
p = inputParser;
p.addRequired('basePath', @ischar);
p.addOptional('sessionPhaseNumber', 1 ,@isnumeric);
p.addOptional('headerOnly', false, @islogical);
p.addOptional('offset', 0, @isnumeric);
p.addOptional('dataLength', -1 ,@isnumeric);
p.addOptional('channel', {}, @iscellstr);

p.parse(basePath, varargin{:});
Arg = p.Results;

%% Make sure basePath is a folder ending with a directory separator
if ~isdir(basePath)
    basePath = fileparts(basePath);
end
if ~(strcmpi(basePath(end), filesep))
    basePath = [basePath filesep];
end

% Initialise empty recording structure
recording = {};

%% Read Session and Protocol files to determine measurement structure

% Read Session from XML-file, to get number of files in session etc
recording.Session =  module_read_neurone_xml([basePath SESSIONFILE]);
if (str2double(recording.Session.TableInfo.Revision) > 1)
    warning(strcat('Warning: This reader does not support the revision of Session.xml (Version ', ...
        num2str(recording.Session.TableInfo.Revision), ...
        '). Please contact mega@megaemg.com for an update.'))
end

% Read Protocol from XML-file, to get channel names etc
recording.Protocol = module_read_neurone_xml([basePath PROTOCOLFILE]);
if (str2double(recording.Protocol.TableInfo.Revision) > 4)
    warning(strcat('Warning: This reader does not support the revision of Protocol.xml (Version ', ...
        num2str(recording.Protocol.TableInfo.Revision), ...
        '). Please contact mega@megaemg.com for an update.'))
end

% Number of sessions in recording
nSessionPhases = numel(recording.Session.TableSessionPhase);
disp(['Number of sessions: ' num2str(nSessionPhases)])

%% For each session, binary data files are stored in separate folders inside
% the main recording folder for each phase during the session.
% I.e, if we have 3 session phases, there are three folders "1", "2" and "3", each
% with a number of bin-files and separate event information.
%
% As default, read only the first session phase, but if arguments are given,
% read the data associated with sessionNumber.
%
% Currently only support reading of first (or explicitly named) session
% (sessionPhase), otherwise we would need to return multiple recordings.

if Arg.sessionPhaseNumber > nSessionPhases
    disp 'Given sessionPhaseNumber exceeds total number of session phases.'
    disp 'Defaulting to first sessionPhase.'
    sessionPhaseNumber = 1;
else
    sessionPhaseNumber = Arg.sessionPhaseNumber;
end

sessionDataFiles = {};

% Get all bin-files in the directory associated with sessionPhaseNumber
sessionFiles = dir([basePath num2str(sessionPhaseNumber) filesep '*.bin']);

jj = 1;
for j=1:numel(sessionFiles);
    [fpath, fname, ext] = fileparts(sessionFiles(j).name);
    if (~isempty(regexpi(fname,'[0-9]')))
        sessionDataFiles{jj,1} = [basePath num2str(sessionPhaseNumber) filesep sessionFiles(j).name];
        jj = jj + 1;
    end
end


%% Organise data into recording structure, using channel names etc
% Set a shorthand for protocol
protocol = recording.Protocol;

% For a NeurOne-device, the sampling rate is the same for all channels
samplingRate = str2double(protocol.TableProtocol.ActualSamplingFrequency);

% Get channel count (number of channels)
channelCount = numel(protocol.TableInput);

if ~(Arg.headerOnly)
    %% Read NeurOne binary data
    data = module_read_neurone_data(sessionDataFiles, channelCount, samplingRate);
    
    %% Organise input and channel data
    %  The fields in channelLayout are used to get the data in the correct
    %  order from the data structure. The data apppears multiplexed, but
    %  organised according to increasing inputNumber. The fields in
    %  channelLayout are organised with increasing inputNumber.
    
    [inputData, channelLayout] = organiseData(protocol.TableInput);
    channels = fieldnames(inputData);
    
    for n=1:channelCount
        channelName = channelLayout(n).name;

        % Gain and offset variables are deprecated.
        % gain        = inputData.(channelName).Gain;
        % offset      = inputData.(channelName).Offset;        
        % recording.signal.(channelName).data = data(:,n) .* gain + offset;

        % Calibrated values are calculated from calibration range.
        rawMinimum = inputData.(channelName).RangeMinimum;
        rawMaximum = inputData.(channelName).RangeMaximum;
        calibratedMinimum = inputData.(channelName).RangeAsCalibratedMinimum;
        calibratedMaximum = inputData.(channelName).RangeAsCalibratedMaximum;

        recording.signal.(channelName).data = calibratedMinimum + ...
            (data(:,n)-rawMinimum) / (rawMaximum-rawMinimum) * (calibratedMaximum-calibratedMinimum);

        % Insert data from XML-table
        recording.signal.(channelName) = catstruct(recording.signal.(channelName), inputData.(channelName));
        
        % Set sampling rate
        recording.signal.(channelName).samplingRate = samplingRate;
    end
    
    % Store signal length (in seconds)
    recording.properties.length = (numel(data) / channelCount) / samplingRate;
    
    % Create labels for easy viewing
    recording.signalTypes = fieldnames(recording.signal);
end

%% Read NeurOne events and create markers
recording.markers = module_read_neurone_events([basePath num2str(sessionPhaseNumber) filesep], samplingRate);

%% Device information and version
recording.device.type       = 'NeurOne';
recording.device.version    = protocol.TableInfo(1).NeurOneVersion;
recording.device.markerType = 'digital';

timeTmp = datenum(recording.Session.TableSession.StartDateTime(1:end-6),'yyyy-mm-ddTHH:MM:SS');

% Time information
recording.properties.start.time     = datestr(timeTmp,'yyyymmddTHHMMSS');
recording.properties.start.unixTime = (timeTmp - datenum(1970,1,1,0,0,0))*24*60*60;


% Store offset information
recording.properties.offset = Arg.offset;

% Store sampling rate
recording.properties.samplingRate = samplingRate;

% Set structure identifier (replace with your own)
recording.identifier = 'N/A';

    function [newData, channelLayout] = organiseData(table)
        % Placeholder for data
        newData = {};
        channelLayout = {};
        % First get channel names
        for n = 1:numel(table);
            channelName = table(n).Name;
            channelName = strrep(strrep(channelName, ' ',''),'-','_');
            channelName = strrep(channelName, 'ö','o');
            channelName = strrep(channelName, 'ä','a');
            channelName = strrep(channelName, 'å','a');
            channelName = genvarname(channelName);
            channelFieldNames = fieldnames(table);
            
            channelLayout(n).name       = channelName;
            channelLayout(n).inputNumber = str2double(table(n).InputNumber);
            
            for k=1:numel(channelFieldNames)
                fieldName  = channelFieldNames{k};
                fieldValue = table(n).(fieldName);
                val        = str2double(fieldValue);
                if ~isnan(val)
                    fieldValue = val;
                end
                newData.(channelName).(fieldName) = fieldValue;
            end
        end
        % Sort channels according to input Number number
        [tmp, order] = sort([channelLayout(:).inputNumber]);
        channelLayout = channelLayout(order);
    end

end % end of module_read_neurone.m