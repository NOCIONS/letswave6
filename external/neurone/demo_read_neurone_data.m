%DEMO_READ_NEURONE_DATA   Example script to use "NeurOne Tools for Matlab".

clc, clear

% Define path of the measurement.
dataPath = '/testdata/2014-12-04T160410/';

%% If you have only one measurement phase and want to read all inputs:

recording = module_read_neurone(dataPath);

%% If there are several phases and you want to select the inputs to read:

% Read NeurOne file header.
headerOnly = true;
header = module_read_neurone(dataPath, 1, headerOnly);

% Select measurement phases and inputs to read.
phasesToRead = 1:length(header.Session.TableSessionPhase); % Read all phases
% phasesToRead = [1 3];
inputsToRead = {'Cz', 'Fp1', 'Fp2'};

% Read the selected NeurOne data.
for i = 1:length(phasesToRead)
    recording(i) = module_read_neurone(dataPath, ...
        phasesToRead(i), false, 0, 0, inputsToRead);
end

clear header headerOnly i dataPath phasesToRead inputsToRead