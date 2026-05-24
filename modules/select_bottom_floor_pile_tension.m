function [V4, assigned] = select_bottom_floor_pile_tension(floorId, numFloors, floorTension, currentV4)
%SELECT_BOTTOM_FLOOR_PILE_TENSION Assign pile tension from bottom floor only.
%
% Step 6: pile sizing uses max leg tension from the bottom (lowest) floor.
% Upper floors do not update V4.

if nargin < 4
    currentV4 = 0;
end
validateScalar(floorId, 'floorId');
validateScalar(numFloors, 'numFloors');
validateScalar(floorTension, 'floorTension');
validateScalar(currentV4, 'currentV4');

if floorId == numFloors
    V4 = floorTension;
    assigned = true;
else
    V4 = currentV4;
    assigned = false;
end
end

function validateScalar(value, name)
if ~isscalar(value) || ~isfinite(value)
    error('select_bottom_floor_pile_tension:InvalidInput', ...
        '%s must be a finite scalar.', name);
end
end
