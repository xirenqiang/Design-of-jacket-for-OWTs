% Smoke test for direction_scenarios (Step 2).
% Run from repo root (R2018a): matlab -nosplash -nodesktop -r "cd('<repo>'); run('Validations/model/Test_direction_scenarios.m'); exit;"
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(fullfile(projectRoot, 'modules'));

requiredFields = {'id', 'paper_case', 'description', 'beta_wind', 'beta_wave', 'is_legacy'};

cfgAuto = build_design_config(struct('load_direction_mode', 1));
scenariosAuto = direction_scenarios(cfgAuto);
assert(numel(scenariosAuto) == 4, 'auto_envelope must return 4 scenarios');
assert_scenario_fields(scenariosAuto, requiredFields);
assert(strcmp(scenariosAuto(1).id, 'D1') && scenariosAuto(1).beta_wind == 0 && scenariosAuto(1).beta_wave == 0);
assert(strcmp(scenariosAuto(2).id, 'D2') && scenariosAuto(2).beta_wind == 0 && scenariosAuto(2).beta_wave == 90);
assert(strcmp(scenariosAuto(3).id, 'D3') && scenariosAuto(3).beta_wind == 0 && scenariosAuto(3).beta_wave == 45);
assert(strcmp(scenariosAuto(4).id, 'D4') && scenariosAuto(4).beta_wind == 45 && scenariosAuto(4).beta_wave == 45);
assert(all(~[scenariosAuto.is_legacy]), 'auto_envelope scenarios must not be legacy');
fprintf('PASS: auto_envelope D1-D4\n');

cfgSingle = build_design_config(struct('load_direction_mode', 0, 'beta_wind', 10, 'beta_wave', 20));
scenariosSingle = direction_scenarios(cfgSingle);
assert(numel(scenariosSingle) == 1, 'single_direction must return 1 scenario');
assert_scenario_fields(scenariosSingle, requiredFields);
assert(strcmp(scenariosSingle(1).id, 'SINGLE'));
assert(scenariosSingle(1).beta_wind == 10 && scenariosSingle(1).beta_wave == 20);
assert(scenariosSingle(1).is_legacy == false);
fprintf('PASS: single_direction SINGLE\n');

cfgLegacy = build_design_config(struct('load_direction_mode', 2, 'pesai_legacy', 45));
scenariosLegacy = direction_scenarios(cfgLegacy);
assert(numel(scenariosLegacy) == 1, 'legacy_pesai must return 1 scenario');
assert_scenario_fields(scenariosLegacy, requiredFields);
assert(strcmp(scenariosLegacy(1).id, 'LEGACY'));
assert(scenariosLegacy(1).is_legacy == true);
assert(scenariosLegacy(1).beta_wind == 45 && scenariosLegacy(1).beta_wave == 45);
fprintf('PASS: legacy_pesai LEGACY\n');

try
    direction_scenarios(struct('load_direction_mode', 9, 'mode_name', 'bad', 'beta_wind', 0, 'beta_wave', 0));
    error('Expected error for invalid load_direction_mode');
catch ME
    assert(contains(ME.identifier, 'ModeNotSupported'), 'Wrong error id for mode 9');
    fprintf('PASS: invalid load_direction_mode rejected\n');
end

try
    direction_scenarios(struct('mode_name', 'auto_envelope'));
    error('Expected error for missing load_direction_mode');
catch ME
    assert(contains(ME.identifier, 'MissingCfgField'), 'Wrong error id for missing field');
    fprintf('PASS: missing cfg field rejected\n');
end

%% Step 9 cross-check: auto scenarios feed directional deflection envelope
cfgAutoStep9 = build_design_config(struct('load_direction_mode', 1));
scenariosStep9 = direction_scenarios(cfgAutoStep9);
assert(count_paper_direction_scenarios(scenariosStep9) == 4, ...
    'Step 9 auto_envelope must expose 4 paper scenarios');
assert(strcmp(resolve_step9_deflection_path(cfgAutoStep9), 'directional_envelope'), ...
    'Step 9 auto_envelope must use directional envelope path');
fprintf('PASS: Step 9 auto_envelope scenario/path cross-check\n');

cfgLegacyStep9 = build_design_config(struct('load_direction_mode', 2));
scenariosLegacyStep9 = direction_scenarios(cfgLegacyStep9);
assert(count_paper_direction_scenarios(scenariosLegacyStep9) == 0, ...
    'Step 9 legacy_pesai must expose 0 paper scenarios');
assert(strcmp(resolve_step9_deflection_path(cfgLegacyStep9), 'legacy_step9'), ...
    'Step 9 legacy_pesai must stay on legacy path');
fprintf('PASS: Step 9 legacy_pesai scenario/path cross-check\n');

fprintf('All direction_scenarios smoke tests passed.\n');

function assert_scenario_fields(scenarios, requiredFields)
for k = 1:numel(scenarios)
    for f = 1:numel(requiredFields)
        assert(isfield(scenarios(k), requiredFields{f}), ...
            'Scenario %d missing field %s', k, requiredFields{f});
    end
end
end
