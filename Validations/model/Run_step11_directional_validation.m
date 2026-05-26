% Run Step 11 directional validation suite and capture test_step11_smoke_log.txt.
% Also refreshes Validations/directional_validation_pass_fail_matrix.csv.
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(fullfile(projectRoot, 'modules'));

logFile = fullfile(thisFileDir, 'test_step11_smoke_log.txt');
matrixFile = fullfile(projectRoot, 'Validations', 'directional_validation_pass_fail_matrix.csv');
fclose(fopen(logFile, 'w'));
diary(logFile);
diary on;
fprintf('Step 11 directional validation run started: %s\n', datestr(now));

manifest = directional_validation_manifest();
results = repmat(struct('script', '', 'status', '', 'requirement', '', 'error', ''), ...
    numel(manifest), 1);

failed = false;
fprintf('\n--- Running Step 11 minimum validation manifest ---\n');
try
    run(fullfile(thisFileDir, 'Test_step11_validation_manifest.m'));
catch ME
    failed = true;
    fprintf('FAIL: Test_step11_validation_manifest.m\n');
    fprintf('  %s: %s\n', ME.identifier, ME.message);
end

for i = 1:numel(manifest)
    testName = manifest(i).test_script;
    requirementId = manifest(i).requirement_id;
    fprintf('\n--- Running %s (%s) ---\n', testName, requirementId);
    results(i).script = testName;
    results(i).requirement = requirementId;
    try
        run(fullfile(thisFileDir, testName));
        results(i).status = 'PASS';
        results(i).error = '';
        fprintf('PASS: %s\n', testName);
    catch ME
        failed = true;
        results(i).status = 'FAIL';
        results(i).error = sprintf('%s: %s', ME.identifier, ME.message);
        fprintf('FAIL: %s\n', testName);
        fprintf('  %s\n', results(i).error);
    end
end

extendedTests = { ...
    'Test_build_design_config.m', ...
    'Test_coordinate_mapping_helpers.m', ...
    'Test_get_floor_leg_positions.m', ...
    'Test_step6_bottom_floor_tension_selection.m', ...
    'Test_step7_brace_demand.m', ...
    'Test_step8_directional_envelope_integration.m', ...
    'Test_directional_deflection_envelope.m', ...
    'Test_step9_mode_gating.m', ...
    'Test_build_directional_summary.m'};

fprintf('\n--- Running Step 11 extended directional regression ---\n');
for i = 1:numel(extendedTests)
    testName = extendedTests{i};
    fprintf('\n--- Running %s ---\n', testName);
    try
        run(fullfile(thisFileDir, testName));
        fprintf('PASS: %s\n', testName);
    catch ME
        failed = true;
        fprintf('FAIL: %s\n', testName);
        fprintf('  %s: %s\n', ME.identifier, ME.message);
    end
end

writeDirectionalMatrix(matrixFile, results);

if failed
    fprintf('\nStep 11 directional validation run finished with failures.\n');
else
    fprintf('\nStep 11 directional validation run finished: all tests passed.\n');
end
fprintf('Directional validation matrix written to %s\n', matrixFile);

diary off;

function writeDirectionalMatrix(matrixFile, results)
fid = fopen(matrixFile, 'w', 'n', 'UTF-8');
if fid < 0
    error('Run_step11_directional_validation:MatrixOpenFailed', ...
        'Could not open matrix file: %s', matrixFile);
end
fprintf(fid, 'script,status,requirement,error\n');
for i = 1:numel(results)
    errText = results(i).error;
    errText = strrep(errText, '"', '""');
    if ~isempty(errText)
        errText = ['"' errText '"'];
    end
    fprintf(fid, '%s,%s,%s,%s\n', ...
        results(i).script, results(i).status, results(i).requirement, errText);
end
fclose(fid);
end
