function pathName = resolve_step9_deflection_path(cfg)
%RESOLVE_STEP9_DEFLECTION_PATH Step 9 mode dispatch: legacy vs directional envelope.
%
% Step 9 contract:
%   load_direction_mode == 2 -> legacy_step9 (regression path)
%   enable_directional_deflection == false -> legacy_step9 (single-case compat)
%   otherwise -> directional_envelope (scenario loop)

validateCfg(cfg);

if cfg.load_direction_mode == 2 || ~cfg.enable_directional_deflection
    pathName = 'legacy_step9';
else
    pathName = 'directional_envelope';
end
end

function validateCfg(cfg)
if ~isstruct(cfg) || ~isfield(cfg, 'load_direction_mode')
    error('resolve_step9_deflection_path:InvalidCfg', ...
        'cfg must contain load_direction_mode.');
end
if ~isfield(cfg, 'enable_directional_deflection')
    error('resolve_step9_deflection_path:InvalidCfg', ...
        'cfg must contain enable_directional_deflection.');
end
if ~ismember(cfg.load_direction_mode, [0, 1, 2])
    error('resolve_step9_deflection_path:InvalidMode', ...
        'load_direction_mode must be 0, 1, or 2.');
end
end
