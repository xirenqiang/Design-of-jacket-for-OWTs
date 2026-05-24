% Smoke tests for get_floor_leg_positions (Step 6 geometry contract).
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(fullfile(projectRoot, 'modules'));

global Member;
Member = struct();
Member.X0 = [10, 12, -8, -10, 5, 5, -5, -5];
Member.Z0 = [4, -4, -4, 4, 1, -1, -1, 1];

LegidPfloor = [1, 2, 3, 4; 5, 6, 7, 8];

legGeom = get_floor_leg_positions(1, LegidPfloor);
assert(numel(legGeom.leg_ids) == 4, 'Floor 1 must return four leg ids');
assert(abs(legGeom.center_x - mean(legGeom.x)) < 1e-12, 'center_x mismatch');
assert(abs(legGeom.center_z - mean(legGeom.z)) < 1e-12, 'center_z mismatch');
assert(legGeom.x(1) == Member.X0(1) && legGeom.z(1) == Member.Z0(1), ...
    'Start-node coordinates must be used');
fprintf('PASS: floor 1 four-leg geometry and centroid\n');

legGeom2 = get_floor_leg_positions(2, LegidPfloor);
assert(legGeom2.floor_id == 2, 'floor_id must match input');
fprintf('PASS: floor 2 geometry extraction\n');

try
    get_floor_leg_positions(0, LegidPfloor);
    error('Expected InvalidFloor for floorId=0.');
catch ME
    assert(strcmp(ME.identifier, 'get_floor_leg_positions:InvalidFloor'), ...
        'Unexpected error: %s', ME.message);
end
fprintf('PASS: invalid floor rejected\n');

LegidBad = [1, 2, 3, 4; 5, 6, 7, 999];
try
    get_floor_leg_positions(2, LegidBad);
    error('Expected InvalidLegId for out-of-range member.');
catch ME
    assert(strcmp(ME.identifier, 'get_floor_leg_positions:InvalidLegId'), ...
        'Unexpected error: %s', ME.message);
end
fprintf('PASS: invalid leg id rejected\n');

LegidThree = [1, 2, 3, 0; 5, 6, 7, 8];
try
    get_floor_leg_positions(1, LegidThree);
    error('Expected LegCount for fewer than four legs.');
catch ME
    assert(strcmp(ME.identifier, 'get_floor_leg_positions:LegCount'), ...
        'Unexpected error: %s', ME.message);
end
fprintf('PASS: non-four-leg floor rejected\n');

fprintf('All get_floor_leg_positions smoke tests passed.\n');
