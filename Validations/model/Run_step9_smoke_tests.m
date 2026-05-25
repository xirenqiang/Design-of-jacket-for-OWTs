% Run Step 9 smoke/regression tests and capture output to test_step9_smoke_log.txt.
% Run from repo root (R2018a):
%   matlab -nosplash -nodesktop -r "cd('<repo>'); run('Validations/model/Run_step9_smoke_tests.m'); exit;"

thisFileDir = fileparts(mfilename('fullpath'));
logFile = fullfile(thisFileDir, 'test_step9_smoke_log.txt');
fclose(fopen(logFile, 'w'));
diary(logFile);
diary on;
fprintf('Step 9 smoke test run started: %s\n', datestr(now));

tests = { ...
    'Test_directional_deflection_envelope.m', ...
    'Test_step9_mode_gating.m', ...
    'Test_direction_scenarios.m', ...
    'Test_direction_mode_selection.m', ...
    'Test_step8_directional_envelope_integration.m'};

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
    fprintf('\nStep 9 smoke test run finished with failures.\n');
else
    fprintf('\nStep 9 smoke test run finished: all tests passed.\n');
end

diary off;
