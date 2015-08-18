function markers = module_read_neurone_events(basePath, samplingRate)
%MODULE_READ_NEURONE_EVENTS   Read events from NeurOne file format.
%
%  Version 1.1.3.8 (2014-12-04)
%  See version_history.txt for details.
%
%  Inputs
%         basePath     : Path to directory containing NeurOne data files
%                        from one measurement.
%         samplingRate : Sampling frequency of the measurement to
%                        calculate occurence times of events.
%
%  Output
%         markers      : A structure containing event types, data indices
%                        and occurence times.
%
%  Dependencies: none
%
%  Module_read_neurone_events is part of NeurOne Tools for Matlab.
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

%% Events are stored in three files:
% (1) events.bin
% (2) eventData.bin
% (3) eventDescriptions.bin

% Define files
EVENTSFILE            = [basePath filesep 'events.bin'];
EVENTDATAFILE         = [basePath filesep 'eventData.bin'];

% The description file is not used.
EVENTDESCRIPTIONSFILE = [basePath filesep 'eventDescriptions.bin'];

%% Read events.bin
% Each event is stored in an 88-byte struct, so we read the data in
% chunks of 88 bytes.

% Get number of events
tmp = dir(EVENTSFILE);
nEvents = tmp.bytes / 88;

% Empty structure for event data
markers.type = cell(nEvents, 1);
markers.index = NaN(nEvents, 1);
markers.time = NaN(nEvents, 1);

% Read events.bin
% RFU (Reserved for Future Use) are not used in this version of the reader.
fileIdEvents = fopen(EVENTSFILE, 'rb');
for k = 1:nEvents
    % Read the whole event structure
    Revision = fread(fileIdEvents,1,'int32');
    RFU = fread(fileIdEvents,1,'int32');
    Type = fread(fileIdEvents,1,'int32');
    SourcePort = fread(fileIdEvents,1,'int32');
    
    % The channel number is not used
    ChannelNumber = fread(fileIdEvents,1,'int32');

    Code = fread(fileIdEvents,1,'int32');
    StartSampleIndex = fread(fileIdEvents,1,'uint64');
    
    % The following three are not used
    StopSampleIndex = fread(fileIdEvents,1,'uint64');
    DescriptionLength = fread(fileIdEvents,1,'uint64');
    DescriptionOffset = fread(fileIdEvents,1,'uint64');

    DataLength = fread(fileIdEvents,1,'uint64');
    DataOffset = fread(fileIdEvents,1,'uint64');
    TimeStamp = fread(fileIdEvents,1,'double');
    MainUnitIndex = fread(fileIdEvents,1,'int32');
    RFU = fread(fileIdEvents,1,'int32');
    
    responseEventIndex = [];
    
    % Check if the data format has changed
    if Revision > 4
        warning(strcat('This reader does not support the revision of events.bin (', ...
            num2str(Revision), '). Please contact mega@megaemg.com for an update.'))
    end
    
    % Determine the source port
    switch SourcePort
        case 0
            SourcePort = 'Unknown';
        case 1
            SourcePort = 'A';
        case 2
            SourcePort = 'B';
        case 3
            SourcePort = 'EightBit';
        case 4
            SourcePort = 'Syncbox Button';
        case 5
            SourcePort = 'SyncBox EXT';
        otherwise
            SourcePort = 'Unknown';
    end
    
    % Determine the type of the event
    switch Type
        case 0
            Type = [SourcePort ' - Unknown'];
        case 1
            Type = [SourcePort ' - Stimulation'];
        case 2
            Type = [SourcePort ' - Video'];
        case 3
            Type = [SourcePort ' - Mute'];
        case 4
            Type = num2str(Code);
        case 5
            Type = [SourcePort ' - Out' ];
        case 6
            % User-entered comments will be read from file eventData.bin
            fileIdEventData = fopen(EVENTDATAFILE,'rb');
            comments = fread(fileIdEventData,[1 DataOffset/2],'int16');
            comments = fread(fileIdEventData,[1 DataLength/2],'int16');
            Type = char(comments);
            fclose(fileIdEventData);
        otherwise
            Type = 'Unknown';
    end
    
    % Store the obtained data
    markers.type(k,1) = cellstr(Type);
    markers.index(k,1) = StartSampleIndex;
    markers.time(k,1) = StartSampleIndex/samplingRate;
    
end
fclose(fileIdEvents);

end