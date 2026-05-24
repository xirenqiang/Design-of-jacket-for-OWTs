function [u,v]=Vel_fluid_particle(TT,h,k,S,Vc,x,y,t,z,beta_wave)
% Regular-wave fluid velocity at (x,y,z) with optional propagation angle beta_wave.
% Parameter y is vertical (code Y); z is horizontal (code Z).
% Step 4 H1: phase uses x_eff = wave_phase_x_eff(x, z, beta_wave).

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
        error('TT0Vel_fluid_parTTicleTT');
    end
    if h<0
        error('h0Vel_fluid_parTTicleh');
    end
    if k<0
        error('k0Vel_fluid_parTTiclek');
    end
    if S<0
        error('S0Vel_fluid_parTTicleS');
    end
    if t<0
        error('t0Vel_fluid_parTTiclet');
    end
end

pi=3.1415926;
omiga=2*pi/TT;
xPhase = wave_phase_x_eff(x, z, beta_wave);
u=(omiga*h/2)*cosh(k*y)/sinh(k*S)*cos(k*xPhase-omiga*t)+Vc;
v=(omiga*h/2)*sinh(k*y)/sinh(k*S)*sin(k*xPhase-omiga*t);
end
