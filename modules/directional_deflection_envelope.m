function deflectionEnvelope = directional_deflection_envelope(deflectionCtx, scenarios, cfg)
%DIRECTIONAL_DEFLECTION_ENVELOPE Step 9 tower-top deflection over direction cases.
%
% Evaluates non-legacy scenarios from direction_scenarios(cfg) and returns the
% governing deflection with beta_wind / beta_wave audit metadata.

if nargin < 3
    cfg = struct();
end

validateDeflectionCtx(deflectionCtx);
validateScenarios(scenarios);

paperScenarios = filterPaperScenarios(scenarios);
if isempty(paperScenarios)
    error('directional_deflection_envelope:NoPaperScenarios', ...
        'No non-legacy direction scenarios available for Step 9 envelope.');
end

caseResults = repmat(struct( ...
    'delt_towertop', 0, ...
    'direction_case', '', ...
    'beta_wind', 0, ...
    'beta_wave', 0, ...
    'environment_case', ''), 1, numel(paperScenarios));

deflectionCtx.use_directional_hydro = true;

for i = 1:numel(paperScenarios)
    scenario = paperScenarios(i);
    caseOut = compute_towertop_deflection_case(deflectionCtx, ...
        scenario.beta_wind, scenario.beta_wave);
    caseResults(i).delt_towertop = caseOut.delt_towertop;
    caseResults(i).direction_case = scenario.id;
    caseResults(i).beta_wind = scenario.beta_wind;
    caseResults(i).beta_wave = scenario.beta_wave;
    caseResults(i).environment_case = caseOut.environment_case;
end

deflectionEnvelope = select_governing_deflection(caseResults);
deflectionEnvelope.mode_name = resolveModeName(cfg);
deflectionEnvelope.scenarios_evaluated = numel(paperScenarios);
end

function paperScenarios = filterPaperScenarios(scenarios)
isLegacy = false(1, numel(scenarios));
for i = 1:numel(scenarios)
    if isfield(scenarios(i), 'is_legacy') && scenarios(i).is_legacy
        isLegacy(i) = true;
    end
end
paperScenarios = scenarios(~isLegacy);
end

function validateDeflectionCtx(deflectionCtx)
if ~isstruct(deflectionCtx)
    error('directional_deflection_envelope:InvalidCtx', ...
        'deflectionCtx must be a struct.');
end
requiredFields = {'t0', 't1', 'dt', 'Num_bar_array', 'Y0_position', ...
    'Hm1', 'Tm1', 'h_total', 'K_R', 'EI_Jacket', 'EI_JacketTower', 'F_ntm'};
for i = 1:numel(requiredFields)
    if ~isfield(deflectionCtx, requiredFields{i})
        error('directional_deflection_envelope:MissingCtxField', ...
            'deflectionCtx must contain field ''%s''.', requiredFields{i});
    end
end
end

function validateScenarios(scenarios)
if ~isstruct(scenarios) || isempty(scenarios)
    error('directional_deflection_envelope:InvalidScenarios', ...
        'scenarios must be a non-empty struct array from direction_scenarios.');
end
end

function modeName = resolveModeName(cfg)
if isstruct(cfg) && isfield(cfg, 'mode_name') && ~isempty(cfg.mode_name)
    modeName = cfg.mode_name;
else
    modeName = 'unknown';
end
end
