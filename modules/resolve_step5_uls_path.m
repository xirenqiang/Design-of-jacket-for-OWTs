function pathName = resolve_step5_uls_path(cfg)
%RESOLVE_STEP5_ULS_PATH Step 5 mode dispatch: legacy vs directional envelope.
%
% Step 8 contract:
%   load_direction_mode == 2 -> legacy_pesai (scalar, no uls_floor_envelope)
%   load_direction_mode == 0|1 -> directional_envelope (scenario loops)

validateCfg(cfg);
if cfg.load_direction_mode == 2
    pathName = 'legacy_pesai';
else
    pathName = 'directional_envelope';
end
end

function validateCfg(cfg)
if ~isstruct(cfg) || ~isfield(cfg, 'load_direction_mode')
    error('resolve_step5_uls_path:InvalidCfg', ...
        'cfg must contain load_direction_mode.');
end
if ~ismember(cfg.load_direction_mode, [0, 1, 2])
    error('resolve_step5_uls_path:InvalidMode', ...
        'load_direction_mode must be 0, 1, or 2.');
end
end
