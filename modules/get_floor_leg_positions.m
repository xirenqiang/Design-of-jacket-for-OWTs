function legGeom = get_floor_leg_positions(floorId, LegidPfloor)
%GET_FLOOR_LEG_POSITIONS Leg IDs and plan coordinates for one floor.
%
% Step 6 geometry contract:
%   - Each floor must have exactly four legs in LegidPfloor.
%   - Plan coordinates use each leg member start node (Member.X0, Member.Z0).
%   - Horizontal plane is code X-Z; Y is vertical.
%   - center_x / center_z are arithmetic means of the four leg start nodes.

global Member;

if nargin < 2 || isempty(LegidPfloor)
    error('get_floor_leg_positions:InvalidInput', 'LegidPfloor is required.');
end
if floorId < 1 || floorId > size(LegidPfloor, 1)
    error('get_floor_leg_positions:InvalidFloor', ...
        'floorId %g is out of range for LegidPfloor.', floorId);
end

legIds = LegidPfloor(floorId, :);
legIds = legIds(legIds > 0);
nLegs = numel(legIds);
if nLegs ~= 4
    error('get_floor_leg_positions:LegCount', ...
        'Floor %g must have exactly four legs; found %d.', floorId, nLegs);
end

legGeom.leg_ids = legIds(:)';
legGeom.x = zeros(1, nLegs);
legGeom.z = zeros(1, nLegs);

for j = 1:nLegs
    id = legIds(j);
    if id < 1 || id > numel(Member.X0)
        error('get_floor_leg_positions:InvalidLegId', ...
            'Leg member id %g is out of range.', id);
    end
    legGeom.x(j) = Member.X0(id);
    legGeom.z(j) = Member.Z0(id);
end

legGeom.center_x = mean(legGeom.x);
legGeom.center_z = mean(legGeom.z);
legGeom.floor_id = floorId;
end
