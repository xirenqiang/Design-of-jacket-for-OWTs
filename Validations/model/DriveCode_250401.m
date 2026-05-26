%% Validation wrapper — historical DriveCode_250401 regression slot.
% Original 2025-04-01 inline script had encoding corruption; this wrapper
% calls the current production driver for end-to-end PASS in the validation matrix.
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(fullfile(projectRoot, 'modules'));

DriveCodeJckDesign('inputdata.dat');
