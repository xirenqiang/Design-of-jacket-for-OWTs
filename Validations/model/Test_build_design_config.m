% Smoke test for build_design_config (Step 1).
% Run from repo root: matlab -batch "run('Validations/model/Test_build_design_config.m')"
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(fullfile(projectRoot, 'modules'));

inputFile = fullfile(thisFileDir, 'inputdata.dat');
dataStruct = readData(inputFile);
cfg = build_design_config(dataStruct);

assert(cfg.load_direction_mode == 1, 'Expected auto_envelope mode from inputdata.dat');
assert(strcmp(cfg.mode_name, 'auto_envelope'), 'Expected mode_name auto_envelope');
assert(cfg.psi_site == 0, 'Expected psi_site 0');
assert(cfg.beta_wave == 45, 'Expected beta_wave 45');
assert(cfg.delta_D_leg == 0.10, 'Expected delta_D_leg 0.10');
assert(cfg.enable_directional_deflection == true, 'Expected enable_directional_deflection true');
fprintf('PASS: inputdata.dat -> cfg\n');

cfgDefault = build_design_config(struct('load_direction_mode', 1));
assert(cfgDefault.beta_wind == 0, 'Default beta_wind should be 0');
assert(cfgDefault.pesai_legacy == 45, 'Default pesai_legacy should be 45');
fprintf('PASS: defaults for partial struct\n');

try
    build_design_config(struct('load_direction_mode', 9));
    error('Expected error for invalid load_direction_mode');
catch ME
    assert(contains(ME.identifier, 'LoadDirectionMode'), 'Wrong error id for mode 9');
    fprintf('PASS: invalid load_direction_mode rejected\n');
end

try
    build_design_config(struct('delta_D_leg', -1));
    error('Expected error for negative delta_D_leg');
catch ME
    assert(contains(ME.identifier, 'InvalidIncrement'), 'Wrong error id for delta_D_leg');
    fprintf('PASS: negative delta_D_leg rejected\n');
end

fprintf('All build_design_config smoke tests passed.\n');
