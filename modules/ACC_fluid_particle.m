function [ax,ay]=ACC_fluid_particle(TT,h,k,S,x,y,t,z,beta_wave)
% Regular-wave fluid acceleration at (x,y,z) with optional propagation angle.
% Step 4 H1: phase uses x_eff = wave_phase_x_eff(x, z, beta_wave).

if nargin < 7
    error('ACC_fluid_particle:NotEnoughInputs', ...
        'Expected at least (TT,h,k,S,x,y,t).');
end
if nargin < 9 || isempty(z)
    z = 0;
end
if nargin < 10
    beta_wave = resolve_wave_beta_propagation();
else
    beta_wave = resolve_wave_beta_propagation(beta_wave);
end

global debug;
if debug==1
    if TT<0
        error('TT0ACC_fluid_particleTT');
    end
    if h<0
        error('h0ACC_fluid_particleh');
    end
    if k<0
        error('k0ACC_fluid_particlek');
    end
    if S<0
        error('S0ACC_fluid_particleS');
    end
    if t<0
        error('t0ACC_fluid_particlet');
    end
end

pi=3.1415926;
omiga=2*pi/TT;
xPhase = wave_phase_x_eff(x, z, beta_wave);
ax=(omiga^2)*(h/2)*cosh(k*y)/sinh(k*S)*sin(k*xPhase-omiga*t);
ay=-(omiga^2)*(h/2)*sinh(k*y)/sinh(k*S)*cos(k*xPhase-omiga*t);
end
