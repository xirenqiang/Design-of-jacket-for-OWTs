function key = build_hydro_cache_key(floorCtx, seaStateName, beta_wave)
%BUILD_HYDRO_CACHE_KEY Cache key for directional hydro maxima (Step 8).
%
% Key fields: floor_id, sea_state, beta_wave, D/t snapshot.

validateFloorCtx(floorCtx);
validateScalar(beta_wave, 'beta_wave');
if ~ischar(seaStateName) && ~(isstring(seaStateName) && isscalar(seaStateName))
    error('build_hydro_cache_key:InvalidSeaStateName', ...
        'seaStateName must be a char vector or string scalar.');
end
key = sprintf('f%d_%s_b%g_D%g_%g_%g_%g', floorCtx.floor_id, char(seaStateName), ...
    beta_wave, floorCtx.D_leg, floorCtx.t_leg, floorCtx.D_brace, floorCtx.t_brace);
end

function validateFloorCtx(floorCtx)
required = {'floor_id', 'D_leg', 't_leg', 'D_brace', 't_brace'};
if ~isstruct(floorCtx)
    error('build_hydro_cache_key:InvalidFloorCtx', 'floorCtx must be a struct.');
end
for i = 1:numel(required)
    if ~isfield(floorCtx, required{i})
        error('build_hydro_cache_key:MissingField', ...
            'floorCtx must contain ''%s''.', required{i});
    end
end
end

function validateScalar(value, name)
if ~isscalar(value) || ~isfinite(value)
    error('build_hydro_cache_key:InvalidInput', ...
        '%s must be a finite scalar.', name);
end
end
