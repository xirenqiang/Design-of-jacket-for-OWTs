%% Validation wrapper — end-to-end regression via production driver.
% Legacy inline replica removed (encoding drift). Single source of truth:
% modules/DriveCodeJckDesign.m
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(fullfile(projectRoot, 'modules'));

DriveCodeJckDesign('inputdata.dat');
