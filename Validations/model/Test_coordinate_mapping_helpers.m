% Smoke test for Step 3 coordinate mapping helpers.
% Run from repo root (R2018a): matlab -nosplash -nodesktop -r "cd('<repo>'); run('Validations/model/Test_coordinate_mapping_helpers.m'); exit;"
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(fullfile(projectRoot, 'modules'));

A45 = paper_code_mapping.rotation_matrix_code_xz(45);
Alegacy = [cosd(45), sind(45); -sind(45), cosd(45)];
assert(max(abs(A45(:) - Alegacy(:))) < 1e-12, 'Rotation matrix must match coordinate_trans convention');
fprintf('PASS: rotation_matrix_code_xz matches legacy matrix\n');

testAngles = [0, 45, 90, 180, 315];
psiSite = 10;
for k = 1:numel(testAngles)
    betaPaper = testAngles(k);
    betaCode = paper_code_mapping.map_paper_plan_to_code(betaPaper, psiSite);
    betaRoundTrip = paper_code_mapping.map_code_to_paper_plan(betaCode, psiSite);
    assert(abs(betaRoundTrip - betaPaper) < 1e-9 || abs(betaRoundTrip - betaPaper - 360) < 1e-9 || abs(betaRoundTrip - betaPaper + 360) < 1e-9, ...
        'Round-trip failed for beta=%g', betaPaper);
end
fprintf('PASS: paper/code angle round-trip\n');

components = paper_code_mapping.paper_plan_components_to_code(100, 200);
assert(components.Fx == 100 && components.Fz == 200 && components.Fy == 0);
fprintf('PASS: paper_plan_components_to_code\n');

cfgAuto = build_design_config(struct('load_direction_mode', 1, 'psi_site', 0));
assert(resolve_structure_azimuth(cfgAuto) == 0);
fprintf('PASS: auto_envelope azimuth uses psi_site\n');

cfgSingle = build_design_config(struct('load_direction_mode', 0, 'psi_site', 15));
assert(resolve_structure_azimuth(cfgSingle) == 15);
fprintf('PASS: single_direction azimuth uses psi_site\n');

cfgLegacy = build_design_config(struct('load_direction_mode', 2, 'pesai_legacy', 45));
assert(resolve_structure_azimuth(cfgLegacy) == 45);
fprintf('PASS: legacy_pesai azimuth uses pesai_legacy\n');

inputFile = fullfile(thisFileDir, 'inputdata.dat');
dataStruct = readData(inputFile);
cfgInput = build_design_config(dataStruct);
assert(cfgInput.load_direction_mode == 1);
assert(resolve_structure_azimuth(cfgInput) == cfgInput.psi_site);
fprintf('PASS: default inputdata.dat azimuth from cfg\n');

try
    resolve_structure_azimuth(struct('load_direction_mode', 9, 'psi_site', 0, 'pesai_legacy', 45));
    error('Expected error for invalid load_direction_mode');
catch ME
    assert(contains(ME.identifier, 'ModeNotSupported'));
    fprintf('PASS: invalid load_direction_mode rejected\n');
end

fprintf('All coordinate mapping helper smoke tests passed.\n');
