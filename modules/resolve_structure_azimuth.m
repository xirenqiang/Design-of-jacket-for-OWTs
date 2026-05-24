function azimuthDeg = resolve_structure_azimuth(cfg)
%RESOLVE_STRUCTURE_AZIMUTH Structure rotation angle for geometry transform.
%
% legacy_pesai (mode 2): cfg.pesai_legacy
% auto_envelope / single_direction: cfg.psi_site

if ~isstruct(cfg)
    error('resolve_structure_azimuth:InvalidCfg', ...
        'cfg must be a struct from build_design_config.');
end

requiredFields = {'load_direction_mode', 'psi_site', 'pesai_legacy'};
for i = 1:numel(requiredFields)
    if ~isfield(cfg, requiredFields{i})
        error('resolve_structure_azimuth:MissingCfgField', ...
            'cfg must contain field ''%s''.', requiredFields{i});
    end
end

switch cfg.load_direction_mode
    case 2
        azimuthDeg = cfg.pesai_legacy;
    case {0, 1}
        azimuthDeg = cfg.psi_site;
    otherwise
        error('resolve_structure_azimuth:ModeNotSupported', ...
            'load_direction_mode must be 0, 1, or 2. Got %g.', cfg.load_direction_mode);
end

if ~isfinite(azimuthDeg)
    error('resolve_structure_azimuth:InvalidAngle', ...
        'Resolved azimuth must be finite. Got %g.', azimuthDeg);
end
end
