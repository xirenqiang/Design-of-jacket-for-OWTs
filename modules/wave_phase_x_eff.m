function xEff = wave_phase_x_eff(x, z, betaWaveDeg)
%WAVE_PHASE_X_EFF Effective horizontal phase coordinate for oblique waves (H1).
%
% PLAN Step 4 / Option H1:
%   x_eff = x*cosd(beta_wave) + z*sind(beta_wave)
%
% Angles are in the code X-Z horizontal plane (Y vertical), CCW from +X.

if ~isfinite(x) || ~isfinite(z)
    error('wave_phase_x_eff:InvalidCoordinate', ...
        'x and z must be finite scalars.');
end
if ~isscalar(betaWaveDeg) || ~isfinite(betaWaveDeg)
    error('wave_phase_x_eff:InvalidAngle', ...
        'betaWaveDeg must be a finite scalar angle in degrees.');
end

xEff = x * cosd(betaWaveDeg) + z * sind(betaWaveDeg);
end
