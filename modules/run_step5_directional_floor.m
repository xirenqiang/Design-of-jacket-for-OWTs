function [D_leg, t_leg, D_brace, t_brace, V4_tension, floorEnvelope] = run_step5_directional_floor( ...
    floorCtx, scenarios, cfg, LegidPfloor, BraceidPfloor, floorId)
%RUN_STEP5_DIRECTIONAL_FLOOR Directional ULS sizing for one floor (paper modes).

floorCtx.legGeom = get_floor_leg_positions(floorId, LegidPfloor);
count_leg = 0;
count_brace = 0;
maxIter = 200;

floorEnvelope = uls_floor_envelope(floorCtx, scenarios, [], cfg);
V1 = floorEnvelope.demands.max_leg_compression;
Fb = floorEnvelope.demands.max_brace_compression;
fprintf('      Governing case: %s, env %s, beta_wind=%g, beta_wave=%g, controls=%s\n', ...
    floorEnvelope.direction_case, floorEnvelope.environment_case, ...
    floorEnvelope.beta_wind, floorEnvelope.beta_wave, floorEnvelope.controls);
fprintf('      Leg compression demand = %g (leg id %g), tension demand = %g (leg id %g)\n', ...
    V1, floorEnvelope.demands.compression_leg_id, ...
    floorEnvelope.demands.max_leg_tension, floorEnvelope.demands.tension_leg_id);
fprintf('      Leg capacity = %g; brace demand = %g, capacity = %g\n', ...
    floorCtx.F_allowable_leg, Fb, floorCtx.F_allowable_brace);
fprintf('      Hydro cache: hits=%d, misses=%d, evaluations=%d\n', ...
    floorEnvelope.cache_stats.hits, floorEnvelope.cache_stats.misses, ...
    floorEnvelope.cache_stats.evaluations);

D_leg = floorCtx.D_leg;
t_leg = floorCtx.t_leg;
D_brace = floorCtx.D_brace;
t_brace = floorCtx.t_brace;
k_leg = 1.0;
k_brace = 0.8;
L_leg = floorCtx.L_leg;
L_brace = floorCtx.L_brace;

iter = 0;
while (V1 > floorCtx.F_allowable_leg || Fb > floorCtx.F_allowable_brace) && iter < maxIter
    iter = iter + 1;
    legExceeds = V1 > floorCtx.F_allowable_leg;
    braceExceeds = Fb > floorCtx.F_allowable_brace;
    [D_leg, t_leg, D_brace, t_brace, resized] = resize_member_sections( ...
        D_leg, t_leg, D_brace, t_brace, ...
        struct('leg_exceeds', legExceeds, 'brace_exceeds', braceExceeds), cfg);
    if ~resized
        break;
    end
    if legExceeds
        count_leg = count_leg + 1;
    end
    if braceExceeds
        count_brace = count_brace + 1;
    end
    A_leg = 1/4 * 3.14 * (D_leg^2 - (D_leg - 2*t_leg)^2);
    I_leg = 1/64 * 3.14 * (D_leg^4 - (D_leg - 2*t_leg)^4);
    ir_leg = sqrt(I_leg / A_leg);
    A_brace = 1/4 * 3.14 * (D_brace^2 - (D_brace - 2*t_brace)^2);
    I_brace = 1/64 * 3.14 * (D_brace^4 - (D_brace - 2*t_brace)^4);
    ir_brace = sqrt(I_brace / A_brace);
    floorCtx.F_allowable_leg = sigma_allowable(k_leg, L_leg, ir_leg, A_leg);
    floorCtx.F_allowable_brace = sigma_allowable(k_brace, L_brace, ir_brace, A_brace);
    floorCtx.D_leg = D_leg;
    floorCtx.t_leg = t_leg;
    floorCtx.D_brace = D_brace;
    floorCtx.t_brace = t_brace;
    Diameter_thickness_update(floorId, LegidPfloor, BraceidPfloor, D_leg, D_brace, t_leg, t_brace);
    floorCtx.Wnet = Weight_jacket(floorCtx.Num_bar_array, floorCtx.steel_density, ...
        floorCtx.hydro_density, floorCtx.Y0_position) + floorCtx.deck_weight;
    floorEnvelope = uls_floor_envelope(floorCtx, scenarios, [], cfg);
    V1 = floorEnvelope.demands.max_leg_compression;
    Fb = floorEnvelope.demands.max_brace_compression;
    fprintf('      Iter %d: leg demand=%g cap=%g; brace demand=%g cap=%g\n', ...
        iter, V1, floorCtx.F_allowable_leg, Fb, floorCtx.F_allowable_brace);
end

if iter >= maxIter
    warning('run_step5_directional_floor:MaxIter', ...
        'Floor %d reached max iterations (%d).', floorId, maxIter);
end

fprintf('      After %d leg / %d brace iterations, floor %d ULS pass.\n', ...
    count_leg, count_brace, floorId);
V4_tension = floorEnvelope.demands.max_leg_tension;
floorEnvelope.floor_id = floorId;
floorEnvelope.leg_capacity = floorCtx.F_allowable_leg;
floorEnvelope.brace_capacity = floorCtx.F_allowable_brace;
end
