function betaDeg = resolve_wave_beta_propagation(betaDeg)
%RESOLVE_WAVE_BETA_PROPAGATION Explicit beta_wave or Wave.beta_propagation (default 0).

if nargin >= 1 && ~isempty(betaDeg) && isfinite(betaDeg)
    return;
end

global Wave;
if exist('Wave', 'var') && isstruct(Wave) && isfield(Wave, 'beta_propagation')
    betaDeg = Wave.beta_propagation;
else
    betaDeg = 0;
end

if ~isfinite(betaDeg)
    error('resolve_wave_beta_propagation:InvalidAngle', ...
        'Wave beta_propagation must be finite. Got %g.', betaDeg);
end
end
