% Step 6 integration test: only bottom-floor tension feeds pile design input V4.
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(fullfile(projectRoot, 'modules'));

numFloors = 4;
V4 = 0;
floorTensions = [120e3, 180e3, 240e3, 310e3];

for floorId = 1:numFloors
    [V4, assigned] = select_bottom_floor_pile_tension( ...
        floorId, numFloors, floorTensions(floorId), V4);
    if floorId < numFloors
        assert(~assigned, 'Upper floors must not assign pile tension');
        assert(V4 == 0, 'V4 must remain unchanged before bottom floor');
    else
        assert(assigned, 'Bottom floor must assign pile tension');
        assert(abs(V4 - floorTensions(end)) < 1e-9, ...
            'V4 must equal bottom-floor max_leg_tension');
    end
end
fprintf('PASS: bottom-floor-only V4 assignment (4 floors)\n');

% 3-floor jacket: bottom floor is floor 3
numFloors3 = 3;
V4 = 0;
tensions3 = [100e3, 150e3, 200e3];
for floorId = 1:numFloors3
    [V4, assigned] = select_bottom_floor_pile_tension( ...
        floorId, numFloors3, tensions3(floorId), V4);
end
assert(abs(V4 - 200e3) < 1e-9, '3-floor case: V4 must come from floor 3');
fprintf('PASS: bottom-floor-only V4 assignment (3 floors)\n');

fprintf('All Step 6 bottom-floor tension selection tests passed.\n');
