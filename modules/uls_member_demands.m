function demands = uls_member_demands(planLoads, Wnet, legGeom, Width_i, sitah, braceIds, cfg)
%ULS_MEMBER_DEMANDS Leg/brace ULS demands for one direction/environment case.
%
% Step 6 contract (paper modes):
%   - Compute axial demand for all four legs; envelope compression and tension.
%   - max_leg_compression / compression_leg_id: largest positive compression demand.
%   - max_leg_tension / tension_leg_id: largest positive tension demand (pile input).
%   - FN_g = Wnet/4; compression gravity term uses cfg.uls_factor * FN_g.
%   - Tension gravity term uses 0.9*Wnet/4 (legacy pile formula, not factored).
%
% Step 7 contract (paper modes only):
%   - Brace compression: Eq. (52) FNb = Fsx/cos(theta_h).
%   - Fsx = hypot(Fx, Fy)/4 after cfg.uls_factor is applied to plan loads.
%   - Do NOT use cosd(pesai) or any structure-rotation projection here.
%   - cos(sitah) near zero raises InvalidBraceAngle.
%
% Sign convention: compression and tension outputs are non-negative magnitudes.
% Legacy_pesai scalar path is not handled here.

validatePlanLoads(planLoads);
validateScalar(Wnet, 'Wnet');
validateLegGeom(legGeom);
validateScalar(Width_i, 'Width_i');
validateScalar(sitah, 'sitah');
validateCfg(cfg);

ulsFactor = cfg.uls_factor;
Fx = ulsFactor * planLoads.Fx;
Fy = ulsFactor * planLoads.Fy;
Mx = ulsFactor * planLoads.Mx;
My = ulsFactor * planLoads.My;

FN_g = Wnet / 4;
nLegs = numel(legGeom.leg_ids);
if nLegs ~= 4
    error('uls_member_demands:LegCount', ...
        'Step 6 requires exactly four legs; got %d.', nLegs);
end

widthEff = effectivePlanWidth(legGeom, Width_i);
[legAxialComp, legAxialTens] = computeLegAxialDemands( ...
    legGeom, Mx, My, ulsFactor, FN_g, Wnet, widthEff);

[demands.max_leg_compression, idxComp] = max(legAxialComp);
[demands.max_leg_tension, idxTens] = max(legAxialTens);
demands.compression_leg_id = legGeom.leg_ids(idxComp);
demands.tension_leg_id = legGeom.leg_ids(idxTens);
demands.leg_axial_comp = legAxialComp;
demands.leg_axial_tens = legAxialTens;

[braceDemand, Fsx] = computeBraceCompressionDemand(Fx, Fy, sitah);
demands.max_brace_compression = braceDemand;
demands.brace_formula = 'eq52_paper';
if isempty(braceIds)
    demands.brace_id = NaN;
else
    demands.brace_id = braceIds(1);
end
demands.FN_g = FN_g;
demands.Fsx = Fsx;
demands.width_eff = widthEff;
demands.controls = 'leg';
end

function [braceDemand, Fsx] = computeBraceCompressionDemand(Fx, Fy, sitah)
%COMPUTEBRACECOMPRESSIONDEMAND Paper Eq. (52): FNb = Fsx/cos(theta_h).
Fsx = hypot(Fx, Fy) / 4;
if abs(cos(sitah)) < 1e-9
    error('uls_member_demands:InvalidBraceAngle', 'cos(sitah) is near zero.');
end
braceDemand = Fsx / cos(sitah);
end

function widthEff = effectivePlanWidth(legGeom, Width_i)
widthX = max(legGeom.x) - min(legGeom.x);
widthZ = max(legGeom.z) - min(legGeom.z);
widthEff = max([Width_i, widthX, widthZ, eps]);
end

function [legAxialComp, legAxialTens] = computeLegAxialDemands( ...
    legGeom, Mx, My, ulsFactor, FN_g, Wnet, widthEff)
nLegs = numel(legGeom.leg_ids);
legAxialComp = zeros(1, nLegs);
legAxialTens = zeros(1, nLegs);
for j = 1:nLegs
    armX = legGeom.x(j) - legGeom.center_x;
    armZ = legGeom.z(j) - legGeom.center_z;
    momentTerm = (My * armX + Mx * armZ) / (widthEff * sqrt(2));
    legAxialComp(j) = momentTerm + ulsFactor * FN_g;
    legAxialTens(j) = momentTerm - 0.9 * Wnet / 4;
end
legAxialComp = max(legAxialComp, 0);
legAxialTens = max(legAxialTens, 0);
end

function validatePlanLoads(planLoads)
required = {'Fx', 'Fy', 'Mx', 'My'};
if ~isstruct(planLoads)
    error('uls_member_demands:InvalidPlanLoads', 'planLoads must be a struct.');
end
for i = 1:numel(required)
    if ~isfield(planLoads, required{i})
        error('uls_member_demands:MissingField', ...
            'planLoads must contain ''%s''.', required{i});
    end
    validateScalar(planLoads.(required{i}), required{i});
end
end

function validateLegGeom(legGeom)
required = {'leg_ids', 'x', 'z', 'center_x', 'center_z'};
if ~isstruct(legGeom)
    error('uls_member_demands:InvalidLegGeom', 'legGeom must be a struct.');
end
for i = 1:numel(required)
    if ~isfield(legGeom, required{i})
        error('uls_member_demands:MissingLegGeom', ...
            'legGeom must contain ''%s''.', required{i});
    end
end
if numel(legGeom.leg_ids) ~= numel(legGeom.x) || numel(legGeom.leg_ids) ~= numel(legGeom.z)
    error('uls_member_demands:LegGeomSize', 'leg_ids, x, and z must have the same length.');
end
end

function validateCfg(cfg)
if ~isstruct(cfg) || ~isfield(cfg, 'uls_factor')
    error('uls_member_demands:InvalidCfg', 'cfg must contain uls_factor.');
end
validateScalar(cfg.uls_factor, 'uls_factor');
end

function validateScalar(value, name)
if ~isscalar(value) || ~isfinite(value)
    error('uls_member_demands:InvalidInput', '%s must be a finite scalar.', name);
end
end
