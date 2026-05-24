function deflectionEnvelope = select_governing_deflection(caseResults)
%SELECT_GOVERNING_DEFLECTION Pick maximum tower-top deflection and metadata.
%
% caseResults struct array fields:
%   delt_towertop, direction_case, beta_wind, beta_wave, environment_case

if isempty(caseResults)
    error('select_governing_deflection:EmptyCaseResults', ...
        'caseResults must contain at least one evaluated deflection case.');
end

validateCaseResults(caseResults);

deltValues = [caseResults.delt_towertop];
[~, idxBest] = max(deltValues);
best = caseResults(idxBest);

deflectionEnvelope = struct( ...
    'max_deflection', best.delt_towertop, ...
    'direction_case', best.direction_case, ...
    'beta_wind', best.beta_wind, ...
    'beta_wave', best.beta_wave, ...
    'environment_case', best.environment_case, ...
    'num_cases_evaluated', numel(caseResults));
end

function validateCaseResults(caseResults)
requiredFields = {'delt_towertop', 'direction_case', 'beta_wind', 'beta_wave', 'environment_case'};
for i = 1:numel(caseResults)
    for j = 1:numel(requiredFields)
        name = requiredFields{j};
        if ~isfield(caseResults(i), name)
            error('select_governing_deflection:MissingCaseField', ...
                'caseResults(%d) must contain field ''%s''.', i, name);
        end
    end
end
end
