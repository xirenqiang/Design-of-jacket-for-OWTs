% Step 11 minimum validation manifest checks.
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(fullfile(projectRoot, 'modules'));

manifest = directional_validation_manifest();
assert(numel(manifest) == 6, 'Step 11 manifest must define 6 minimum requirements');

requiredIds = { ...
    'direction_scenario_table', ...
    'eq48_algebra', ...
    'four_leg_envelope', ...
    'beta0_hydro_regression', ...
    'mode_dispatch', ...
    'summary_metadata'};

for i = 1:numel(manifest)
    entry = manifest(i);
    assert(any(strcmp(entry.requirement_id, requiredIds)), ...
        'Unexpected requirement id: %s', entry.requirement_id);
    testPath = fullfile(thisFileDir, entry.test_script);
    assert(isfile(testPath), 'Missing test script for %s: %s', ...
        entry.requirement_id, entry.test_script);
    fprintf('PASS: manifest entry %s -> %s\n', entry.requirement_id, entry.test_script);
end

fprintf('All Step 11 validation manifest checks passed.\n');
