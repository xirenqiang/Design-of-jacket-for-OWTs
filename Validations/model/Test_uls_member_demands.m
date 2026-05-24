% Smoke and contract tests for uls_member_demands (Step 6 four-leg envelope).
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(fullfile(projectRoot, 'modules'));

cfg = build_design_config(struct('uls_factor', 1.3));
tol = 1e-6;

%% Symmetric square: My-dominant compression and brace demand
planLoads = struct('Fx', 4000, 'Fy', 0, 'Mx', 0, 'My', 1.3e6);
Wnet = 4e6;
legGeom = struct( ...
    'leg_ids', [1, 2, 3, 4], ...
    'x', [5, 5, -5, -5], ...
    'z', [5, -5, -5, 5], ...
    'center_x', 0, ...
    'center_z', 0);
Width_i = 10;
sitah = atan(0.5);

d = uls_member_demands(planLoads, Wnet, legGeom, Width_i, sitah, 5, cfg);

expectedMomentTerm = (cfg.uls_factor * planLoads.My * 5) / (Width_i * sqrt(2));
expectedComp = expectedMomentTerm + cfg.uls_factor * Wnet / 4;
assert(abs(d.max_leg_compression - expectedComp) < tol, 'max_leg_compression mismatch');
assert(d.compression_leg_id == 1 || d.compression_leg_id == 2, ...
    'Expected governing compression at +X corner');

Fsx = cfg.uls_factor * hypot(planLoads.Fx, planLoads.Fy) / 4;
expectedBrace = Fsx / cos(sitah);
assert(abs(d.max_brace_compression - expectedBrace) < 1e-9, 'brace demand mismatch');
fprintf('PASS: symmetric My-dominant compression and brace\n');

assert(d.max_leg_tension >= 0, 'Tension envelope must be non-negative');
fprintf('PASS: tension envelope non-negative\n');

%% Asymmetric geometry: governing leg id follows largest lever arm
legGeomAsym = struct( ...
    'leg_ids', [10, 20, 30, 40], ...
    'x', [6, 4, -4, -6], ...
    'z', [2, -2, -2, 2], ...
    'center_x', 0, ...
    'center_z', 0);
planLoadsMy = struct('Fx', 0, 'Fy', 0, 'Mx', 0, 'My', 2e6);
dAsym = uls_member_demands(planLoadsMy, Wnet, legGeomAsym, Width_i, sitah, 5, cfg);
[~, idxAsym] = max(dAsym.leg_axial_comp);
assert(dAsym.compression_leg_id == legGeomAsym.leg_ids(idxAsym), ...
    'compression_leg_id must match max envelope index');
assert(dAsym.compression_leg_id == 10, ...
    'Asymmetric plan: leg 10 (+X, +Z) should govern compression');
fprintf('PASS: asymmetric geometry governing compression leg id\n');

%% Mx-dominant case
planLoadsMx = struct('Fx', 0, 'Fy', 0, 'Mx', 1.5e6, 'My', 0);
dMx = uls_member_demands(planLoadsMx, Wnet, legGeom, Width_i, sitah, 5, cfg);
assert(dMx.compression_leg_id == 1 || dMx.compression_leg_id == 4, ...
    'Mx-dominant should govern +Z corner legs');
fprintf('PASS: Mx-dominant governing leg selection\n');

%% Coupled Mx+My and high moment / low weight tension case
planLoadsCoupled = struct('Fx', 0, 'Fy', 0, 'Mx', 8e5, 'My', 8e5);
WnetLight = 1e5;
dCoupled = uls_member_demands(planLoadsCoupled, WnetLight, legGeom, Width_i, sitah, 5, cfg);
assert(dCoupled.max_leg_tension > 0, 'Expected positive tension under coupled moments');
[~, idxTens] = max(dCoupled.leg_axial_tens);
assert(dCoupled.tension_leg_id == legGeom.leg_ids(idxTens), ...
    'tension_leg_id must match max envelope index');
fprintf('PASS: coupled moments and tension id mapping\n');

%% Exactly four legs required
legGeomBad = legGeom;
legGeomBad.leg_ids = [1, 2, 3];
legGeomBad.x = [1, 2, 3];
legGeomBad.z = [1, 2, 3];
try
    uls_member_demands(planLoads, Wnet, legGeomBad, Width_i, sitah, 5, cfg);
    error('Expected LegCount error for non-four-leg geometry.');
catch ME
    assert(strcmp(ME.identifier, 'uls_member_demands:LegCount'), ...
        'Unexpected error: %s', ME.message);
end
fprintf('PASS: four-leg requirement enforced\n');

fprintf('All uls_member_demands smoke tests passed.\n');
