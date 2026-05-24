function scenarios = direction_scenarios(cfg)
%DIRECTION_SCENARIOS Return active wind/wave direction cases for the selected mode.
%
% Output struct array fields:
%   id, paper_case, description, beta_wind, beta_wave, is_legacy
%
% Modes (from cfg.load_direction_mode via build_design_config):
%   0 = single_direction  -> one case from cfg.beta_wind, cfg.beta_wave
%   1 = auto_envelope     -> D1-D4 per paper Section 2.5
%   2 = legacy_pesai      -> LEGACY metadata only (not a paper Eq. 48 case)

validate_cfg(cfg);

switch cfg.load_direction_mode
    case 1
        scenarios = auto_envelope_scenarios();
    case 0
        scenarios = single_direction_scenario(cfg);
    case 2
        scenarios = legacy_pesai_scenario(cfg);
    otherwise
        error('direction_scenarios:ModeNotSupported', ...
            'load_direction_mode must be 0, 1, or 2. Got %g.', cfg.load_direction_mode);
end
end

function validate_cfg(cfg)
if ~isstruct(cfg)
    error('direction_scenarios:InvalidCfg', 'cfg must be a struct from build_design_config.');
end
requiredFields = {'load_direction_mode', 'mode_name', 'beta_wind', 'beta_wave'};
for i = 1:numel(requiredFields)
    if ~isfield(cfg, requiredFields{i})
        error('direction_scenarios:MissingCfgField', ...
            'cfg must contain field ''%s''.', requiredFields{i});
    end
end
if ~ismember(cfg.load_direction_mode, [0, 1, 2])
    error('direction_scenarios:ModeNotSupported', ...
        'load_direction_mode must be 0, 1, or 2. Got %g.', cfg.load_direction_mode);
end
end

function scenarios = auto_envelope_scenarios()
scenarios(1) = make_scenario('D1', '(a)', ...
    'Co-directional wind and wave', 0, 0, false);
scenarios(2) = make_scenario('D2', '(b)', ...
    'Wind and wave/current differ by 90 deg', 0, 90, false);
scenarios(3) = make_scenario('D3', '(c)', ...
    'Wind and wave/current differ by 45 deg', 0, 45, false);
scenarios(4) = make_scenario('D4', '(d)', ...
    'Wind and wave both at 45 deg to structure', 45, 45, false);
end

function scenarios = single_direction_scenario(cfg)
scenarios = make_scenario('SINGLE', '', ...
    'User-specified single direction pair', cfg.beta_wind, cfg.beta_wave, false);
end

function scenarios = legacy_pesai_scenario(cfg)
scenarios = make_scenario('LEGACY', '', ...
    sprintf('Legacy pesai-style regression (pesai_legacy=%g deg)', cfg.pesai_legacy), ...
    cfg.pesai_legacy, cfg.pesai_legacy, true);
end

function s = make_scenario(id, paper_case, description, beta_wind, beta_wave, is_legacy)
s = struct( ...
    'id', id, ...
    'paper_case', paper_case, ...
    'description', description, ...
    'beta_wind', beta_wind, ...
    'beta_wave', beta_wave, ...
    'is_legacy', logical(is_legacy));
end
