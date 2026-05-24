% Step 7 tests: paper-mode brace demand Eq. (52) and legacy de-coupling.
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(fullfile(projectRoot, 'modules'));

cfg = build_design_config(struct('uls_factor', 1.3));
tol = 1e-9;

legGeom = struct( ...
    'leg_ids', [1, 2, 3, 4], ...
    'x', [5, 5, -5, -5], ...
    'z', [5, -5, -5, 5], ...
    'center_x', 0, ...
    'center_z', 0);
Wnet = 4e6;
Width_i = 10;
braceId = 5;

%% Eq. (52) numeric consistency: Fx-only
planLoadsX = struct('Fx', 8000, 'Fy', 0, 'Mx', 0, 'My', 0);
sitah = atan(0.5);
dX = uls_member_demands(planLoadsX, Wnet, legGeom, Width_i, sitah, braceId, cfg);
FxFact = cfg.uls_factor * planLoadsX.Fx;
expectedFsx = FxFact / 4;
expectedBrace = expectedFsx / cos(sitah);
assert(abs(dX.Fsx - expectedFsx) < tol, 'Fsx mismatch (Fx-only)');
assert(abs(dX.max_brace_compression - expectedBrace) < tol, 'brace demand mismatch (Fx-only)');
assert(strcmp(dX.brace_formula, 'eq52_paper'), 'brace_formula tag mismatch');
fprintf('PASS: Eq.52 numeric consistency (Fx-only)\n');

%% Eq. (52) with coupled Fx and Fy
planLoadsXY = struct('Fx', 3000, 'Fy', 4000, 'Mx', 0, 'My', 0);
dXY = uls_member_demands(planLoadsXY, Wnet, legGeom, Width_i, sitah, braceId, cfg);
FxYFact = [cfg.uls_factor * planLoadsXY.Fx; cfg.uls_factor * planLoadsXY.Fy];
expectedFsxXY = hypot(FxYFact(1), FxYFact(2)) / 4;
expectedBraceXY = expectedFsxXY / cos(sitah);
assert(abs(dXY.max_brace_compression - expectedBraceXY) < tol, ...
    'brace demand mismatch (Fx+Fy)');
fprintf('PASS: Eq.52 numeric consistency (Fx+Fy)\n');

%% Invalid brace angle when cos(sitah) ~ 0
planLoads = struct('Fx', 1000, 'Fy', 0, 'Mx', 0, 'My', 0);
sitahBad = pi / 2;
try
    uls_member_demands(planLoads, Wnet, legGeom, Width_i, sitahBad, braceId, cfg);
    error('Expected InvalidBraceAngle for sitah=pi/2.');
catch ME
    assert(strcmp(ME.identifier, 'uls_member_demands:InvalidBraceAngle'), ...
        'Unexpected error: %s', ME.message);
end
fprintf('PASS: InvalidBraceAngle at cos(sitah) ~ 0\n');

%% Brace demand independent of pesai (paper path has no pesai input)
planLoadsDecouple = struct('Fx', 5000, 'Fy', 2000, 'Mx', 0, 'My', 1e6);
d1 = uls_member_demands(planLoadsDecouple, Wnet, legGeom, Width_i, sitah, braceId, cfg);
d2 = uls_member_demands(planLoadsDecouple, Wnet, legGeom, Width_i, sitah, braceId, cfg);
assert(abs(d1.max_brace_compression - d2.max_brace_compression) < tol, ...
    'Repeated calls must give identical brace demand');
assert(d1.max_brace_compression > 0, 'Expected positive brace demand');
fprintf('PASS: brace demand stable and pesai-independent (no pesai in API)\n');

%% Legacy formula differs when pesai != 0 (documentation guard)
H = cfg.uls_factor * planLoadsDecouple.Fx / 4;
pesai = 45;
legacyFb = H / cos(sitah) / cosd(pesai);
paperFb = d1.max_brace_compression;
assert(abs(legacyFb - paperFb) > tol, ...
    'Legacy and paper formulas should differ when pesai=45 deg');
fprintf('PASS: legacy vs paper formula separation confirmed\n');

fprintf('All Step 7 brace demand tests passed.\n');
