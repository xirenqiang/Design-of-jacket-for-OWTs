% Run Step 10 smoke/regression tests and capture output to test_step10_smoke_log.txt.
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(fullfile(projectRoot, 'modules'));

logFile = fullfile(thisFileDir, 'test_step10_smoke_log.txt');
fclose(fopen(logFile, 'w'));
diary(logFile);
diary on;
fprintf('Step 10 smoke test run started: %s\n', datestr(now));

tests = { ...
    'Test_build_directional_summary.m', ...
    'Test_write_directional_summary.m', ...
    'Test_directional_deflection_envelope.m', ...
    'Test_step9_mode_gating.m', ...
    'Test_direction_scenarios.m', ...
    'Test_direction_mode_selection.m'};

failed = false;
for i = 1:numel(tests)
    testName = tests{i};
    fprintf('\n--- Running %s ---\n', testName);
    try
        run(fullfile(thisFileDir, testName));
    catch ME
        failed = true;
        fprintf('FAIL: %s\n', testName);
        fprintf('  %s: %s\n', ME.identifier, ME.message);
    end
end

if failed
    fprintf('\nStep 10 smoke test run finished with failures.\n');
else
    fprintf('\nStep 10 smoke test run finished: all tests passed.\n');
end

diary off;
