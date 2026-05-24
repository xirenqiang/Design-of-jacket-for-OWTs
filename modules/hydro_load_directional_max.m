function hydro = hydro_load_directional_max(seaState, beta_wave, t0, t1, dt, Num_bar_array, y0_position)
%HYDRO_LOAD_DIRECTIONAL_MAX DAF-scaled hydro maxima for one sea state and beta_wave.
%
% seaState fields: name, H, T, DAF

validateSeaState(seaState);

global Wave;
Wave.T = seaState.T;
Wave.h = seaState.H;
Wave.k = wave_number(Wave.T, Wave.h);
Wave.beta_propagation = beta_wave;

[Ftx, Fty, Ftz, Mtx, Mtz, ~] = Hydro_load_timehistory(t0, t1, dt, Num_bar_array, y0_position);
[Ftx_max, Fty_max, Ftz_max, Mtx_max, Mtz_max] = Hydro_load_max(Ftx, Fty, Ftz, Mtx, Mtz);

hydro.F = seaState.DAF * Ftx_max;
hydro.M = seaState.DAF * Mtz_max;
hydro.raw = struct( ...
    'Ftx', Ftx_max, ...
    'Fty', Fty_max, ...
    'Ftz', Ftz_max, ...
    'Mtx', Mtx_max, ...
    'Mtz', Mtz_max);
hydro.beta_wave = beta_wave;
hydro.sea_state_name = seaState.name;
end

function validateSeaState(seaState)
requiredFields = {'name', 'H', 'T', 'DAF'};
if ~isstruct(seaState)
    error('hydro_load_directional_max:InvalidSeaState', 'seaState must be a struct.');
end
for i = 1:numel(requiredFields)
    if ~isfield(seaState, requiredFields{i})
        error('hydro_load_directional_max:MissingSeaStateField', ...
            'seaState must contain field ''%s''.', requiredFields{i});
    end
end
end
