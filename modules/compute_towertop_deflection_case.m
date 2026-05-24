function caseResult = compute_towertop_deflection_case(deflectionCtx, beta_wind, beta_wave)
%COMPUTE_TOWERTOP_DEFLECTION_CASE Single Step 9 tower-top deflection case.
%
% deflectionCtx fields:
%   t0, t1, dt, Num_bar_array, Y0_position
%   Hm1, Tm1, h_total, K_R, EI_Jacket, EI_JacketTower, F_ntm
%   use_directional_hydro (logical, optional) — when true, beta_wave drives hydro
%   environment_case (char, optional) — audit label, default '1yr_NTM'
%
% beta_wind is recorded for audit metadata (wind deflection uses scalar F_ntm).

validateDeflectionCtx(deflectionCtx);

if nargin < 2 || isempty(beta_wind)
    beta_wind = 0;
end
if nargin < 3 || isempty(beta_wave)
    beta_wave = 0;
end

useDirectionalHydro = isfield(deflectionCtx, 'use_directional_hydro') ...
    && logical(deflectionCtx.use_directional_hydro);

if useDirectionalHydro
    seaState = struct( ...
        'name', 'Hm1_1yr', ...
        'H', deflectionCtx.Hm1, ...
        'T', deflectionCtx.Tm1, ...
        'DAF', 1);
    hydro = hydro_load_directional_max(seaState, beta_wave, ...
        deflectionCtx.t0, deflectionCtx.t1, deflectionCtx.dt, ...
        deflectionCtx.Num_bar_array, deflectionCtx.Y0_position);
    F1_wav = hydro.F;
    M1_wav = hydro.M;
else
    global Wave;
    Wave.T = deflectionCtx.Tm1;
    Wave.h = deflectionCtx.Hm1;
    Wave.k = wave_number(Wave.T, Wave.h);
    Wave.beta_propagation = 0;
    [Ftx, Fty, Ftz, Mtx, Mtz, ~] = Hydro_load_timehistory( ...
        deflectionCtx.t0, deflectionCtx.t1, deflectionCtx.dt, ...
        deflectionCtx.Num_bar_array, deflectionCtx.Y0_position);
    [Ftx_max, ~, ~, ~, Mtz_max] = Hydro_load_max(Ftx, Fty, Ftz, Mtx, Mtz);
    F1_wav = Ftx_max;
    M1_wav = Mtz_max;
end

a = deflectionCtx.h_total - M1_wav / F1_wav;
delt_wave = F1_wav * deflectionCtx.h_total * (deflectionCtx.h_total - a) / deflectionCtx.K_R ...
    + F1_wav / deflectionCtx.EI_Jacket * ((deflectionCtx.h_total - a)^3 / 3 ...
    - a * (deflectionCtx.h_total - a)^2 / 2);

F_ntm = deflectionCtx.F_ntm;
delt_wind = F_ntm * deflectionCtx.h_total^2 / deflectionCtx.K_R ...
    + F_ntm * deflectionCtx.h_total^3 / (3 * deflectionCtx.EI_JacketTower);

caseResult = struct( ...
    'delt_towertop', delt_wind + delt_wave, ...
    'delt_wave', delt_wave, ...
    'delt_wind', delt_wind, ...
    'F1_wav', F1_wav, ...
    'M1_wav', M1_wav, ...
    'beta_wind', beta_wind, ...
    'beta_wave', beta_wave, ...
    'environment_case', resolveEnvironmentCase(deflectionCtx));
end

function validateDeflectionCtx(deflectionCtx)
requiredFields = { ...
    't0', 't1', 'dt', 'Num_bar_array', 'Y0_position', ...
    'Hm1', 'Tm1', 'h_total', 'K_R', 'EI_Jacket', 'EI_JacketTower', 'F_ntm'};
if ~isstruct(deflectionCtx)
    error('compute_towertop_deflection_case:InvalidCtx', ...
        'deflectionCtx must be a struct.');
end
for i = 1:numel(requiredFields)
    name = requiredFields{i};
    if ~isfield(deflectionCtx, name)
        error('compute_towertop_deflection_case:MissingCtxField', ...
            'deflectionCtx must contain field ''%s''.', name);
    end
end
end

function environmentCase = resolveEnvironmentCase(deflectionCtx)
if isfield(deflectionCtx, 'environment_case') && ~isempty(deflectionCtx.environment_case)
    environmentCase = deflectionCtx.environment_case;
else
    environmentCase = '1yr_NTM';
end
end
