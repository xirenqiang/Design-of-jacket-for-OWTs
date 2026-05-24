% Smoke test for Step 5 mode dispatch helpers.
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(fullfile(projectRoot, 'modules'));

cfgAuto = build_design_config(struct('load_direction_mode', 1));
cfgSingle = build_design_config(struct('load_direction_mode', 0, 'beta_wind', 10, 'beta_wave', 20));
cfgLegacy = build_design_config(struct('load_direction_mode', 2));

assert(strcmp(cfgAuto.mode_name, 'auto_envelope'), 'auto mode_name mismatch');
assert(strcmp(cfgSingle.mode_name, 'single_direction'), 'single mode_name mismatch');
assert(strcmp(cfgLegacy.mode_name, 'legacy_pesai'), 'legacy mode_name mismatch');

scAuto = direction_scenarios(cfgAuto);
scSingle = direction_scenarios(cfgSingle);
scLegacy = direction_scenarios(cfgLegacy);

assert(numel(scAuto) == 4, 'auto_envelope should return 4 scenarios');
assert(strcmp(scSingle(1).id, 'SINGLE'), 'single_direction id mismatch');
assert(strcmp(scLegacy(1).id, 'LEGACY') && scLegacy(1).is_legacy, 'legacy scenario metadata mismatch');

useLegacy = (cfgLegacy.load_direction_mode == 2);
useDirectionalAuto = (cfgAuto.load_direction_mode ~= 2);
assert(useLegacy, 'legacy flag expected true');
assert(useDirectionalAuto, 'directional flag expected true for auto');

fprintf('PASS: mode_name dispatch\n');
fprintf('PASS: direction_scenarios counts\n');
fprintf('All direction mode selection smoke tests passed.\n');
