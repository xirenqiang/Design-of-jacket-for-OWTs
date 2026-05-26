function Run_validation_matrix()
% Refresh Validations/validation_pass_fail_matrix.csv by running validation scripts.
% Run from repo root (R2018a):
%   matlab -nosplash -nodesktop -r "cd('<repo>'); Run_validation_matrix; exit;"
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(thisFileDir);
addpath(thisFileDir);
modelDir = fullfile(thisFileDir, 'model');
modulusDir = fullfile(thisFileDir, 'modulus');
matrixFile = fullfile(thisFileDir, 'validation_pass_fail_matrix.csv');
logFile = fullfile(modelDir, 'test_step12_validation_matrix_log.txt');

addpath(fullfile(projectRoot, 'modules'));

fclose(fopen(logFile, 'w'));
diary(logFile);
diary on;
fprintf('Validation matrix refresh started: %s\n', datestr(now));

scriptList = struct('relPath', {}, 'absPath', {});
scriptList = appendScripts(scriptList, listScripts(modelDir, 'Test_*.m'));
scriptList = appendScripts(scriptList, listScripts(modelDir, 'DriveCode_*.m'));
scriptList = appendScripts(scriptList, listScripts(modulusDir, 'Test_*.m'));

results = repmat(struct('script', '', 'status', '', 'error', ''), numel(scriptList), 1);

for i = 1:numel(scriptList)
    relPath = scriptList(i).relPath;
    absPath = scriptList(i).absPath;
    fprintf('\n--- Running %s ---\n', relPath);
    results(i).script = relPath;
    [status, errMsg] = run_one_validation(absPath);
    results(i).status = status;
    results(i).error = errMsg;
    if strcmp(status, 'PASS')
        fprintf('PASS: %s\n', relPath);
    else
        fprintf('FAIL: %s\n', relPath);
        if ~isempty(errMsg)
            fprintf('  %s\n', errMsg);
        end
    end
    writeValidationMatrix(matrixFile, results(1:i));
end

writeValidationMatrix(matrixFile, results);
failedCount = sum(strcmp({results.status}, 'FAIL'));
fprintf('\nValidation matrix refresh finished: %d PASS, %d FAIL\n', ...
    sum(strcmp({results.status}, 'PASS')), failedCount);
fprintf('Matrix written to %s\n', matrixFile);
fprintf('Log written to %s\n', logFile);

diary off;
end

function scriptList = appendScripts(scriptList, entries)
for i = 1:numel(entries)
    scriptList(end + 1) = entries(i); %#ok<AGROW>
end
end

function entries = listScripts(folder, pattern)
files = dir(fullfile(folder, pattern));
files = files(~[files.isdir]);
keep = true(numel(files), 1);
for k = 1:numel(files)
    if strncmp(files(k).name, 'Run_', 4)
        keep(k) = false;
    end
end
files = files(keep);
entries = repmat(struct('relPath', '', 'absPath', ''), numel(files), 1);
for i = 1:numel(files)
    [~, folderName] = fileparts(folder);
    entries(i).relPath = [folderName '/' files(i).name];
    entries(i).absPath = fullfile(folder, files(i).name);
end
end

function writeValidationMatrix(matrixFile, results)
fid = fopen(matrixFile, 'w', 'n', 'UTF-8');
if fid < 0
    error('Run_validation_matrix:MatrixOpenFailed', ...
        'Could not open matrix file: %s', matrixFile);
end
fprintf(fid, 'script,status,error\n');
for i = 1:numel(results)
    errText = results(i).error;
    errText = strrep(errText, '"', '""');
    if ~isempty(errText)
        errText = ['"' errText '"'];
    end
    fprintf(fid, '%s,%s,%s\n', results(i).script, results(i).status, errText);
end
fclose(fid);
end
