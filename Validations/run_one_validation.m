function [status, errMsg] = run_one_validation(absPath)
%RUN_ONE_VALIDATION Run one validation script in base workspace.
% Legacy scripts often call clearvars; running in the caller workspace would
% wipe this function's output variables before return.
status = 'PASS';
errMsg = '';
runPath = strrep(absPath, '\', '/');
runPath = strrep(runPath, '''', '''''');
try
    evalin('base', 'clearvars;');
    evalin('base', sprintf('run(''%s'');', runPath));
catch ME
    status = 'FAIL';
    errMsg = sprintf('%s: %s', ME.identifier, ME.message);
end
end
