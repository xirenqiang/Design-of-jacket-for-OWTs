function [y] = surface_elevation(H,k,x,t,w,z,beta_wave)
% Wave surface elevation using H1 phase coordinate x_eff.

if nargin < 6 || isempty(z)
    z = 0;
end
if nargin < 7
    beta_wave = resolve_wave_beta_propagation();
else
    beta_wave = resolve_wave_beta_propagation(beta_wave);
end

global debug;
if debug==1
    if H<0
        error('H0surface_elevationH');
    end
    if k<0
        error('k0surface_elevationk');
    end
    if t<0
        error('t0surface_elevationt');
    end
    if w<0
        error('w0surface_elevationw');
    end
end

xPhase = wave_phase_x_eff(x, z, beta_wave);
y=H/2*cos(k*xPhase-w*t);
end
