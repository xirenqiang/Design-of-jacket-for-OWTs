function [D_leg, t_leg, D_brace, t_brace, resized] = resize_member_sections(D_leg, t_leg, D_brace, t_brace, demandStatus, cfg)
%RESIZE_MEMBER_SECTIONS Increment leg/brace sections using cfg delta increments.
%
% demandStatus fields (logical): leg_exceeds, brace_exceeds
% Paper modes must not reset OD to fixed absolute values.

validateScalar(D_leg, 'D_leg');
validateScalar(t_leg, 't_leg');
validateScalar(D_brace, 'D_brace');
validateScalar(t_brace, 't_brace');
validateDemandStatus(demandStatus);
validateCfg(cfg);

resized = false;
if isfield(demandStatus, 'leg_exceeds') && demandStatus.leg_exceeds
    D_leg = D_leg + cfg.delta_D_leg;
    t_leg = t_leg + cfg.delta_t_leg;
    resized = true;
end
if isfield(demandStatus, 'brace_exceeds') && demandStatus.brace_exceeds
    D_brace = D_brace + cfg.delta_D_brace;
    t_brace = t_brace + cfg.delta_t_brace;
    resized = true;
end
end

function validateDemandStatus(demandStatus)
if ~isstruct(demandStatus)
    error('resize_member_sections:InvalidDemandStatus', ...
        'demandStatus must be a struct.');
end
end

function validateCfg(cfg)
required = {'delta_D_leg', 'delta_t_leg', 'delta_D_brace', 'delta_t_brace'};
if ~isstruct(cfg)
    error('resize_member_sections:InvalidCfg', 'cfg must be a struct.');
end
for i = 1:numel(required)
    if ~isfield(cfg, required{i})
        error('resize_member_sections:MissingCfg', ...
            'cfg must contain ''%s''.', required{i});
    end
end
end

function validateScalar(value, name)
if ~isscalar(value) || ~isfinite(value) || value <= 0
    error('resize_member_sections:InvalidInput', ...
        '%s must be a positive finite scalar.', name);
end
end
