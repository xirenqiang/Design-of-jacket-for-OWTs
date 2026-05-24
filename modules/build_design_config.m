function cfg = build_design_config(dataStruct)
%BUILD_DESIGN_CONFIG Normalize directional-load and ULS resize settings.
% Maps inputdata.dat fields to cfg with defaults for backward compatibility.
%
% load_direction_mode:
%   0 = single_direction
%   1 = auto_envelope (default)
%   2 = legacy_pesai

if nargin < 1 || isempty(dataStruct)
    dataStruct = struct();
end

cfg.load_direction_mode = get_field_or_default(dataStruct, 'load_direction_mode', 1);
cfg.psi_site = get_field_or_default(dataStruct, 'psi_site', 0);
cfg.beta_wind = get_field_or_default(dataStruct, 'beta_wind', 0);
cfg.beta_wave = get_field_or_default(dataStruct, 'beta_wave', 45);
cfg.pesai_legacy = get_field_or_default(dataStruct, 'pesai_legacy', 45);
cfg.enable_directional_deflection = logical(get_field_or_default(dataStruct, 'enable_directional_deflection', 1));
cfg.delta_D_leg = get_field_or_default(dataStruct, 'delta_D_leg', 0.10);
cfg.delta_t_leg = get_field_or_default(dataStruct, 'delta_t_leg', 0.005);
cfg.delta_D_brace = get_field_or_default(dataStruct, 'delta_D_brace', 0.06);
cfg.delta_t_brace = get_field_or_default(dataStruct, 'delta_t_brace', 0.01);
cfg.uls_factor = get_field_or_default(dataStruct, 'uls_factor', 1.3);

validate_config(cfg);
cfg.mode_name = mode_name_from_code(cfg.load_direction_mode);
end

function value = get_field_or_default(dataStruct, fieldName, defaultValue)
if isfield(dataStruct, fieldName) && ~isempty(dataStruct.(fieldName))
    value = dataStruct.(fieldName);
else
    value = defaultValue;
end
end

function validate_config(cfg)
if ~ismember(cfg.load_direction_mode, [0, 1, 2])
    error('build_design_config:LoadDirectionMode', ...
        'load_direction_mode must be 0, 1, or 2. Got %g.', cfg.load_direction_mode);
end

deltaFields = {'delta_D_leg', 'delta_t_leg', 'delta_D_brace', 'delta_t_brace'};
for i = 1:numel(deltaFields)
    name = deltaFields{i};
    value = cfg.(name);
    if ~isfinite(value) || value <= 0
        error('build_design_config:InvalidIncrement', ...
            '%s must be a positive finite number. Got %g.', name, value);
    end
end

angleFields = {'psi_site', 'beta_wind', 'beta_wave', 'pesai_legacy'};
for i = 1:numel(angleFields)
    name = angleFields{i};
    value = cfg.(name);
    if ~isfinite(value)
        error('build_design_config:InvalidAngle', ...
            '%s must be a finite number. Got %g.', name, value);
    end
end

if ~isfinite(cfg.uls_factor) || cfg.uls_factor <= 0
    error('build_design_config:InvalidUlsFactor', ...
        'uls_factor must be a positive finite number. Got %g.', cfg.uls_factor);
end
end

function modeName = mode_name_from_code(modeCode)
switch modeCode
    case 0
        modeName = 'single_direction';
    case 1
        modeName = 'auto_envelope';
    case 2
        modeName = 'legacy_pesai';
    otherwise
        error('build_design_config:LoadDirectionMode', ...
            'Unsupported load_direction_mode: %g.', modeCode);
end
end
