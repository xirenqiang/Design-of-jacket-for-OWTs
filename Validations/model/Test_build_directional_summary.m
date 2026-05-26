% Step 10 build_directional_summary tests.
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(fullfile(projectRoot, 'modules'));

cfgAuto = build_design_config(struct('load_direction_mode', 1));
cfgLegacy = build_design_config(struct('load_direction_mode', 2, 'pesai_legacy', 45));

ulsRecords(1) = makeUlsRecord(1, 'D1', 'ETM+Hm2', 0, 0, 'leg', 1.1, 0.8, 1, 100, 120);
ulsRecords(2) = makeUlsRecord(2, 'D2', 'EOG+Hm2', 0, 90, 'brace', 0.9, 1.3, 5, 80, 70);
ulsRecords(3) = makeUlsRecord(3, 'D4', 'EWM_50+Hm50', 45, 45, 'leg', 1.0, 0.95, 3, 110, 100);

summary = build_directional_summary(cfgAuto, ulsRecords, []);
assert(strcmp(summary.mode, 'auto_envelope'), 'Expected auto_envelope mode');
assert(isempty(summary.legacy), 'Paper summary must not include legacy block');
assert(summary.uls.floor == 2, 'Floor 2 should govern by utilization');
assert(strcmp(summary.uls.direction_case, 'D2'), 'Expected D2 governing case');
assert(strcmp(summary.uls.member_type, 'brace'), 'Expected brace to control on floor 2');
assert(summary.uls.demand == 80 && summary.uls.capacity == 70, 'Brace demand/capacity mismatch');
assert(isempty(summary.deflection), 'Deflection block should be omitted when not provided');
fprintf('PASS: build_directional_summary selects governing ULS floor\n');

deflectionEnvelope = struct( ...
    'direction_case', 'D3', ...
    'beta_wind', 0, ...
    'beta_wave', 45, ...
    'environment_case', '1yr_NTM', ...
    'max_deflection', 0.42);
summaryWithDeflection = build_directional_summary(cfgAuto, ulsRecords, deflectionEnvelope);
assert(~isempty(summaryWithDeflection.deflection), 'Deflection block expected');
assert(summaryWithDeflection.deflection.max_deflection == 0.42, 'Deflection value mismatch');
assert(strcmp(summaryWithDeflection.deflection.member_type, 'deflection'), ...
    'Deflection member_type mismatch');
fprintf('PASS: build_directional_summary attaches deflection block\n');

summaryLegacy = build_directional_summary(cfgLegacy, [], []);
assert(~isempty(summaryLegacy.legacy), 'Legacy summary expected');
assert(summaryLegacy.legacy.pesai_legacy == 45, 'Legacy angle mismatch');
assert(strcmp(summaryLegacy.legacy.calculation, 'old scalar formulation'), ...
    'Legacy calculation label mismatch');
assert(isempty(summaryLegacy.uls), 'Legacy summary must not include ULS block');
fprintf('PASS: build_directional_summary legacy branch\n');

try
    build_directional_summary(cfgAuto, [], []);
    error('Expected error for empty ulsRecords in paper mode.');
catch ME
    assert(strcmp(ME.identifier, 'build_directional_summary:EmptyUlsRecords'), ...
        'Unexpected error: %s', ME.message);
end
fprintf('PASS: build_directional_summary rejects empty ulsRecords\n');

fprintf('All build_directional_summary tests passed.\n');

function record = makeUlsRecord(floorId, directionCase, envCase, betaWind, betaWave, ...
    controls, legRatio, braceRatio, memberId, demand, capacity)
record = struct( ...
    'floor_id', floorId, ...
    'direction_case', directionCase, ...
    'environment_case', envCase, ...
    'beta_wind', betaWind, ...
    'beta_wave', betaWave, ...
    'controls', controls, ...
    'leg_ratio', legRatio, ...
    'brace_ratio', braceRatio, ...
    'member_type', controls, ...
    'member_id', memberId, ...
    'demand', demand, ...
    'capacity', capacity);
end
