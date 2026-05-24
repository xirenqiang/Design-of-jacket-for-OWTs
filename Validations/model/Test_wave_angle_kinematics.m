% Smoke test for Step 4 wave-direction hydrodynamics (H1 phase rotation).
% Run from repo root (R2018a): matlab -nosplash -nodesktop -r "cd('<repo>'); run('Validations/model/Test_wave_angle_kinematics.m'); exit;"
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(fullfile(projectRoot, 'modules'));

TT = 12;
h = 2;
S = 50;
k = 2 * pi / 80;
Vc = 0.5;
x = 10;
y = -20;
z = 5;
t = 3.7;
w = 2 * pi / TT;

assert(abs(wave_phase_x_eff(1, 0, 0) - 1) < 1e-12);
assert(abs(wave_phase_x_eff(0, 1, 90) - 1) < 1e-12);
fprintf('PASS: wave_phase_x_eff hand checks\n');

[u0, v0] = Vel_fluid_particle(TT, h, k, S, Vc, x, y, t);
piVal = 3.1415926;
omiga = 2 * piVal / TT;
uLegacy = (omiga * h / 2) * cosh(k * y) / sinh(k * S) * cos(k * x - omiga * t) + Vc;
vLegacy = (omiga * h / 2) * sinh(k * y) / sinh(k * S) * sin(k * x - omiga * t);
assert(max(abs([u0 - uLegacy, v0 - vLegacy])) < 1e-12);
fprintf('PASS: Vel_fluid_particle beta=0 matches legacy formula\n');

[ax0, ay0] = ACC_fluid_particle(TT, h, k, S, x, y, t);
axLegacy = (omiga^2) * (h / 2) * cosh(k * y) / sinh(k * S) * sin(k * x - omiga * t);
ayLegacy = -(omiga^2) * (h / 2) * sinh(k * y) / sinh(k * S) * cos(k * x - omiga * t);
assert(max(abs([ax0 - axLegacy, ay0 - ayLegacy])) < 1e-12);
fprintf('PASS: ACC_fluid_particle beta=0 matches legacy formula\n');

eta0 = surface_elevation(h, k, x, t, w);
etaLegacy = h / 2 * cos(k * x - w * t);
assert(abs(eta0 - etaLegacy) < 1e-12);
fprintf('PASS: surface_elevation beta=0 matches legacy formula\n');

[u90, v90] = Vel_fluid_particle(TT, h, k, S, Vc, x, y, t, z, 90);
assert(all(isfinite([u90, v90])));
fprintf('PASS: Vel_fluid_particle beta=90 sanity\n');

global Wave;
Wave = struct('beta_propagation', 45);
assert(resolve_wave_beta_propagation() == 45);
Wave.beta_propagation = 0;
assert(resolve_wave_beta_propagation() == 0);
fprintf('PASS: resolve_wave_beta_propagation global fallback\n');

setupMinimalHydroFixture();
seaState = struct('name', 'Hm2_test', 'H', 2.0, 'T', 12.0, 'DAF', 1.1);
t0 = 0;
t1 = 2;
dt = 0.5;
memberGroup = 1;
y0 = 0;

Wave.beta_propagation = 0;
hydroNew = hydro_load_directional_max(seaState, 0, t0, t1, dt, memberGroup, y0);

Wave.T = seaState.T;
Wave.h = seaState.H;
Wave.k = wave_number(Wave.T, Wave.h);
Wave.beta_propagation = 0;
[Ftx, Fty, Ftz, Mtx, Mtz, ~] = Hydro_load_timehistory(t0, t1, dt, memberGroup, y0);
[Ftx_max, ~, ~, ~, Mtz_max] = Hydro_load_max(Ftx, Fty, Ftz, Mtx, Mtz);
Flegacy = seaState.DAF * Ftx_max;
Mlegacy = seaState.DAF * Mtz_max;

assert(abs(hydroNew.F - Flegacy) < 1e-6 * max(1, abs(Flegacy)));
assert(abs(hydroNew.M - Mlegacy) < 1e-6 * max(1, abs(Mlegacy)));
assert(strcmp(hydroNew.sea_state_name, 'Hm2_test'));
fprintf('PASS: hydro_load_directional_max beta=0 matches legacy chain\n');

fprintf('All wave angle kinematics smoke tests passed.\n');

function setupMinimalHydroFixture()
global Member Hydro Wave Current Discrete debug dL_ele_target;

debug = 0;
dL_ele_target = 3.0;
Hydro = struct('density', 1025, 'cd', 1.0, 'cm', 2.0);
Wave = struct('S', 50, 'T', 12, 'h', 2, 'k', 0.05, 'beta_propagation', 0);
Current = struct('U_ss0', 0, 'U_ns0', 0, 'h_ref', 20);

Member.X0(1) = 6;
Member.Y0(1) = 0;
Member.Z0(1) = 6;
Member.Xt(1) = 4;
Member.Yt(1) = 20;
Member.Zt(1) = 4;
Member.D(1) = 1.0;
Member.t(1) = 0.05;
Member.L(1) = sqrt(sum(([Member.Xt(1), Member.Yt(1), Member.Zt(1)] - [Member.X0(1), Member.Y0(1), Member.Z0(1)]).^2));
Member.fai_y(1) = atand(sqrt((Member.Xt(1)-Member.X0(1))^2 + (Member.Zt(1)-Member.Z0(1))^2) / abs(Member.Yt(1)-Member.Y0(1)));
Member.cita_x(1) = atand((Member.Zt(1)-Member.Z0(1)) / (Member.Xt(1)-Member.X0(1)));
[Member.cx(1), Member.cy(1), Member.cz(1)] = Direction_bar(Member.fai_y(1), Member.cita_x(1));
Discrete.Num_ele(1) = 4;
Discrete.dL(1) = Member.L(1) / Discrete.Num_ele(1);
end
