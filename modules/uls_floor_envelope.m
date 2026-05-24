function floorEnvelope = uls_floor_envelope(floorCtx, scenarios, envCases, cfg)
%ULS_FLOOR_ENVELOPE Governing ULS demands over direction x environment cases.
%
% Step 8 contract:
%   - Loop paper direction scenarios x default ULS environment pairs.
%   - Skip legacy metadata scenarios (is_legacy=true).
%   - Cache hydro by (floor, sea_state, beta_wave, D/t snapshot).
%   - Return cache_stats (hits, misses, evaluations) for audit/tests.
%
% floorCtx: floor geometry, capacities, wind moments, hydro time range, sections.
% scenarios: from direction_scenarios(cfg).
% envCases: struct array with wind/hydro fields per combination.

validateFloorCtx(floorCtx);
validateCfg(cfg);
if isempty(scenarios)
    error('uls_floor_envelope:EmptyScenarios', 'scenarios must not be empty.');
end
nPaperScenarios = count_paper_direction_scenarios(scenarios);
if nPaperScenarios == 0
    error('uls_floor_envelope:NoPaperScenarios', ...
        'No paper direction scenarios to evaluate (legacy-only input).');
end
if isempty(envCases)
    envCases = build_default_env_cases(floorCtx);
end

hydroCache = struct('keys', {{}}, 'values', {{}});
cacheStats = struct('hits', 0, 'misses', 0, 'evaluations', 0);

bestRatio = -inf;
best = struct();

for s = 1:numel(scenarios)
    scenario = scenarios(s);
    if isfield(scenario, 'is_legacy') && scenario.is_legacy
        continue;
    end
    for e = 1:numel(envCases)
        env = envCases(e);
        cacheStats.evaluations = cacheStats.evaluations + 1;
        [hydro, hydroCache, cacheStats] = get_cached_hydro(hydroCache, floorCtx, env, scenario.beta_wave, cacheStats);
        planLoads = combine_plan_loads(env.Faero, env.Maero, hydro.F, hydro.M, ...
            scenario.beta_wind, scenario.beta_wave);
        demands = uls_member_demands(planLoads, floorCtx.Wnet, floorCtx.legGeom, ...
            floorCtx.Width_i, floorCtx.sitah, floorCtx.brace_ids, cfg);

        legRatio = demands.max_leg_compression / floorCtx.F_allowable_leg;
        braceRatio = demands.max_brace_compression / floorCtx.F_allowable_brace;
        ratio = max(legRatio, braceRatio);
        if ratio > bestRatio
            bestRatio = ratio;
            best.demands = demands;
            best.direction_case = scenario.id;
            best.environment_case = env.name;
            best.beta_wind = scenario.beta_wind;
            best.beta_wave = scenario.beta_wave;
            best.leg_ratio = legRatio;
            best.brace_ratio = braceRatio;
            if legRatio >= braceRatio
                best.controls = 'leg';
            else
                best.controls = 'brace';
            end
            best.planLoads = planLoads;
            best.hydro = hydro;
        end
    end
end

if isempty(fieldnames(best))
    error('uls_floor_envelope:NoResult', ...
        'No paper direction/environment combination was evaluated.');
end

floorEnvelope = struct( ...
    'demands', best.demands, ...
    'direction_case', best.direction_case, ...
    'environment_case', best.environment_case, ...
    'beta_wind', best.beta_wind, ...
    'beta_wave', best.beta_wave, ...
    'controls', best.controls, ...
    'leg_ratio', best.leg_ratio, ...
    'brace_ratio', best.brace_ratio, ...
    'planLoads', best.planLoads, ...
    'hydro', best.hydro, ...
    'cache_stats', cacheStats);
end

function envCases = build_default_env_cases(floorCtx)
envCases(1) = make_env_case('ETM+Hm2', floorCtx.F_etm, floorCtx.M_etm, ...
    'Hm2', floorCtx.Hm2, floorCtx.Tm2, floorCtx.DAF2);
envCases(2) = make_env_case('EOG+Hm2', floorCtx.F_eog, floorCtx.M_eog, ...
    'Hm2', floorCtx.Hm2, floorCtx.Tm2, floorCtx.DAF2);
envCases(3) = make_env_case('EWM_50+Hm50', floorCtx.F_ewm_50, floorCtx.M_ewm_50, ...
    'Hm50', floorCtx.Hm50, floorCtx.Tm50, floorCtx.DAF50);
envCases(4) = make_env_case('EWM_1+Hm1', floorCtx.F_ewm_1, floorCtx.M_ewm_1, ...
    'Hm1', floorCtx.Hm1, floorCtx.Tm1, floorCtx.DAF1);
end

function env = make_env_case(name, Faero, Maero, seaName, H, T, DAF)
env = struct( ...
    'name', name, ...
    'Faero', Faero, ...
    'Maero', Maero, ...
    'sea_state', struct('name', seaName, 'H', H, 'T', T, 'DAF', DAF));
end

function [hydro, hydroCache, cacheStats] = get_cached_hydro(hydroCache, floorCtx, env, beta_wave, cacheStats)
key = build_hydro_cache_key(floorCtx, env.sea_state.name, beta_wave);
idx = find(strcmp(hydroCache.keys, key), 1);
if ~isempty(idx)
    cacheStats.hits = cacheStats.hits + 1;
    hydro = hydroCache.values{idx};
    return;
end
cacheStats.misses = cacheStats.misses + 1;
hydro = hydro_load_directional_max(env.sea_state, beta_wave, floorCtx.t0, ...
    floorCtx.t1, floorCtx.dt, floorCtx.Num_bar_array, floorCtx.Y0_position);
hydroCache.keys{end + 1} = key;
hydroCache.values{end + 1} = hydro;
end

function validateFloorCtx(floorCtx)
required = {'floor_id', 'Num_bar_array', 'Y0_position', 'Width_i', 'Wnet', ...
    'legGeom', 'sitah', 'brace_ids', 'F_allowable_leg', 'F_allowable_brace', ...
    'D_leg', 't_leg', 'D_brace', 't_brace', 't0', 't1', 'dt', ...
    'F_etm', 'M_etm', 'F_eog', 'M_eog', 'F_ewm_50', 'M_ewm_50', 'F_ewm_1', 'M_ewm_1', ...
    'Hm2', 'Tm2', 'DAF2', 'Hm50', 'Tm50', 'DAF50', 'Hm1', 'Tm1', 'DAF1'};
if ~isstruct(floorCtx)
    error('uls_floor_envelope:InvalidFloorCtx', 'floorCtx must be a struct.');
end
for i = 1:numel(required)
    if ~isfield(floorCtx, required{i})
        error('uls_floor_envelope:MissingField', ...
            'floorCtx must contain ''%s''.', required{i});
    end
end
end

function validateCfg(cfg)
if ~isstruct(cfg) || ~isfield(cfg, 'uls_factor')
    error('uls_floor_envelope:InvalidCfg', 'cfg must contain uls_factor.');
end
end
