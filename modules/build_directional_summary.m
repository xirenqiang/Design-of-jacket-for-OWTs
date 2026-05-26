function summary = build_directional_summary(cfg, ulsRecords, deflectionEnvelope)
%BUILD_DIRECTIONAL_SUMMARY Assemble auditable directional summary metadata.
%
% cfg: build_design_config output.
% ulsRecords: struct array from uls_record_from_floor_envelope (paper modes).
% deflectionEnvelope: Step 9 envelope output; omit or pass [] when unavailable.

validateCfg(cfg);

if nargin < 2
    ulsRecords = [];
end
if nargin < 3
    deflectionEnvelope = [];
end

summary = struct();
summary.mode = cfg.mode_name;
summary.uls = [];
summary.deflection = [];
summary.legacy = [];

if cfg.load_direction_mode == 2
    summary.legacy = struct( ...
        'pesai_legacy', cfg.pesai_legacy, ...
        'calculation', 'old scalar formulation', ...
        'purpose', 'regression comparison only');
    return;
end

if isempty(ulsRecords)
    error('build_directional_summary:EmptyUlsRecords', ...
        'Paper modes require at least one ULS floor record.');
end

summary.uls = selectGoverningUls(ulsRecords);
summary.deflection = mapDeflectionSummary(deflectionEnvelope);
end

function ulsSummary = selectGoverningUls(ulsRecords)
utilizations = zeros(1, numel(ulsRecords));
for i = 1:numel(ulsRecords)
    validateUlsRecord(ulsRecords(i));
    utilizations(i) = max(ulsRecords(i).leg_ratio, ulsRecords(i).brace_ratio);
end
[~, idxBest] = max(utilizations);
best = ulsRecords(idxBest);

ulsSummary = struct( ...
    'direction_case', best.direction_case, ...
    'beta_wind', best.beta_wind, ...
    'beta_wave', best.beta_wave, ...
    'environment_case', best.environment_case, ...
    'floor', best.floor_id, ...
    'member_type', best.member_type, ...
    'member_id', best.member_id, ...
    'demand', best.demand, ...
    'capacity', best.capacity);
end

function deflectionSummary = mapDeflectionSummary(deflectionEnvelope)
deflectionSummary = [];
if isempty(deflectionEnvelope)
    return;
end

requiredFields = {'direction_case', 'beta_wind', 'beta_wave', ...
    'environment_case', 'max_deflection'};
for i = 1:numel(requiredFields)
    if ~isfield(deflectionEnvelope, requiredFields{i})
        error('build_directional_summary:MissingDeflectionField', ...
            'deflectionEnvelope must contain field ''%s''.', requiredFields{i});
    end
end

deflectionSummary = struct( ...
    'direction_case', deflectionEnvelope.direction_case, ...
    'beta_wind', deflectionEnvelope.beta_wind, ...
    'beta_wave', deflectionEnvelope.beta_wave, ...
    'environment_case', deflectionEnvelope.environment_case, ...
    'max_deflection', deflectionEnvelope.max_deflection, ...
    'member_type', 'deflection');
end

function validateCfg(cfg)
if ~isstruct(cfg) || ~isfield(cfg, 'load_direction_mode') || ~isfield(cfg, 'mode_name')
    error('build_directional_summary:InvalidCfg', ...
        'cfg must contain load_direction_mode and mode_name.');
end
if cfg.load_direction_mode == 2 && ~isfield(cfg, 'pesai_legacy')
    error('build_directional_summary:InvalidCfg', ...
        'legacy_pesai cfg must contain pesai_legacy.');
end
end

function validateUlsRecord(record)
requiredFields = { ...
    'floor_id', 'direction_case', 'environment_case', 'beta_wind', 'beta_wave', ...
    'controls', 'leg_ratio', 'brace_ratio', 'member_type', 'member_id', ...
    'demand', 'capacity'};
for i = 1:numel(requiredFields)
    if ~isfield(record, requiredFields{i})
        error('build_directional_summary:MissingUlsField', ...
            'ulsRecords entry must contain field ''%s''.', requiredFields{i});
    end
end
end
