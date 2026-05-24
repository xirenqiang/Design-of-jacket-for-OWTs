function planLoads = combine_plan_loads(Faero, Maero, Fhydro, Mhydro, beta_wind, beta_wave)
%COMBINE_PLAN_LOADS Paper Eq. (48) plan force/moment components (code X-Z plane).
%
%   Fx = Faero*cosd(beta_wind) + Fhydro*cosd(beta_wave)
%   Fy = Faero*sind(beta_wind) + Fhydro*sind(beta_wave)   (paper y -> code Z)
%   Mx = Maero*sind(beta_wind) + Mhydro*sind(beta_wave)
%   My = Maero*cosd(beta_wind) + Mhydro*cosd(beta_wave)
%
% planLoads.Fx/Fy are mapped to code horizontal X and Z respectively.

validateScalar(Faero, 'Faero');
validateScalar(Maero, 'Maero');
validateScalar(Fhydro, 'Fhydro');
validateScalar(Mhydro, 'Mhydro');
validateScalar(beta_wind, 'beta_wind');
validateScalar(beta_wave, 'beta_wave');

planLoads = struct( ...
    'Fx', Faero * cosd(beta_wind) + Fhydro * cosd(beta_wave), ...
    'Fy', Faero * sind(beta_wind) + Fhydro * sind(beta_wave), ...
    'Mx', Maero * sind(beta_wind) + Mhydro * sind(beta_wave), ...
    'My', Maero * cosd(beta_wind) + Mhydro * cosd(beta_wave), ...
    'beta_wind', beta_wind, ...
    'beta_wave', beta_wave);
end

function validateScalar(value, name)
if ~isscalar(value) || ~isfinite(value)
    error('combine_plan_loads:InvalidInput', ...
        '%s must be a finite scalar.', name);
end
end
