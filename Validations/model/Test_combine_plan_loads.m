% Smoke test for combine_plan_loads (Step 5 Eq. 48).
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(fullfile(projectRoot, 'modules'));

Faero = 1000;
Maero = 5000;
Fhydro = 800;
Mhydro = 4000;
beta_wind = 0;
beta_wave = 90;

p = combine_plan_loads(Faero, Maero, Fhydro, Mhydro, beta_wind, beta_wave);
tol = 1e-9;
assert(abs(p.Fx - Faero - 0) < tol, 'Fx mismatch at beta_wind=0, beta_wave=90');
assert(abs(p.Fy - Fhydro) < tol, 'Fy mismatch');
assert(abs(p.Mx - Mhydro) < tol, 'Mx mismatch');
assert(abs(p.My - Maero) < tol, 'My mismatch');
fprintf('PASS: combine_plan_loads hand check (0, 90)\n');

p2 = combine_plan_loads(100, 200, 300, 400, 45, 45);
FxExp = 100 * cosd(45) + 300 * cosd(45);
FyExp = 100 * sind(45) + 300 * sind(45);
assert(abs(p2.Fx - FxExp) < tol, 'Fx mismatch at 45/45');
assert(abs(p2.Fy - FyExp) < tol, 'Fy mismatch at 45/45');
fprintf('PASS: combine_plan_loads hand check (45, 45)\n');

fprintf('All combine_plan_loads smoke tests passed.\n');
