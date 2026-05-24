function floorIds = step5_floor_indices(numFloors)
%STEP5_FLOOR_INDICES Floor index range for Step 5 ULS sizing loop.
%
% Step 8 contract: loop 1:numFloors (not hard-coded 1:4).

validateScalar(numFloors, 'numFloors');
if numFloors ~= 3 && numFloors ~= 4
    error('step5_floor_indices:InvalidNumFloors', ...
        'numFloors must be 3 or 4. Got %g.', numFloors);
end
floorIds = 1:numFloors;
end

function validateScalar(value, name)
if ~isscalar(value) || ~isfinite(value)
    error('step5_floor_indices:InvalidInput', ...
        '%s must be a finite scalar.', name);
end
end
