% Step 9 mode gating tests (resolve_step9_deflection_path).
% Run from repo root (R2018a): matlab -nosplash -nodesktop -r "cd('<repo>'); run('Validations/model/Test_step9_mode_gating.m'); exit;"
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(fullfile(projectRoot, 'modules'));

cfgAuto = build_design_config(struct('load_direction_mode', 1));
cfgSingle = build_design_config(struct('load_direction_mode', 0, 'beta_wind', 10, 'beta_wave', 20));
cfgLegacy = build_design_config(struct('load_direction_mode', 2));
cfgDisabled = build_design_config(struct( ...
    'load_direction_mode', 1, ...
    'enable_directional_deflection', 0));

assert(strcmp(resolve_step9_deflection_path(cfgAuto), 'directional_envelope'), ...
    'auto_envelope with deflection enabled should use directional envelope');
assert(strcmp(resolve_step9_deflection_path(cfgSingle), 'directional_envelope'), ...
    'single_direction with deflection enabled should use directional envelope');
assert(strcmp(resolve_step9_deflection_path(cfgLegacy), 'legacy_step9'), ...
    'legacy_pesai must stay on legacy Step 9 path');
assert(strcmp(resolve_step9_deflection_path(cfgDisabled), 'legacy_step9'), ...
    'enable_directional_deflection=0 must use legacy Step 9 path');
fprintf('PASS: resolve_step9_deflection_path mode gating\n');

%% Step 5 vs Step 9 path independence check
assert(strcmp(resolve_step5_uls_path(cfgLegacy), 'legacy_pesai'), ...
    'legacy Step 5 path unchanged');
assert(strcmp(resolve_step9_deflection_path(cfgLegacy), 'legacy_step9'), ...
    'legacy Step 9 path isolated');
assert(strcmp(resolve_step5_uls_path(cfgAuto), 'directional_envelope'), ...
    'paper Step 5 remains directional');
assert(strcmp(resolve_step9_deflection_path(cfgAuto), 'directional_envelope'), ...
    'paper Step 9 uses directional envelope when enabled');
fprintf('PASS: Step 5 and Step 9 path dispatch consistency\n');

try
    resolve_step9_deflection_path(struct('load_direction_mode', 1));
    error('Expected error for cfg missing enable_directional_deflection.');
catch ME
    assert(strcmp(ME.identifier, 'resolve_step9_deflection_path:InvalidCfg'), ...
        'Unexpected error: %s', ME.message);
end
fprintf('PASS: resolve_step9_deflection_path validates cfg fields\n');

fprintf('All Step 9 mode gating tests passed.\n');
