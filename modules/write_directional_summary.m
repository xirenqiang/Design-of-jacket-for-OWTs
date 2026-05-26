function write_directional_summary(summaryPath, summary)
%WRITE_DIRECTIONAL_SUMMARY Write auditable directional summary to file and session log.

validateSummary(summary);
textBlock = formatSummaryText(summary);

writeTextFile(summaryPath, textBlock);
fprintf('%s', textBlock);
end

function textBlock = formatSummaryText(summary)
lines = {};

if ~isempty(summary.legacy)
    lines = [lines, ...
        '=== Directional Load Summary (Legacy) ===', ...
        sprintf('mode = %s', summary.mode), ...
        sprintf('pesai_legacy = %g deg', summary.legacy.pesai_legacy), ...
        sprintf('calculation = %s', summary.legacy.calculation), ...
        sprintf('purpose = %s', summary.legacy.purpose), ...
        ''];
    textBlock = joinLines(lines);
    return;
end

lines = [lines, ...
    '=== Directional Load Summary ===', ...
    sprintf('mode = %s', summary.mode)];

if ~isempty(summary.uls)
    lines = [lines, ...
        sprintf('governing_direction_case = %s', summary.uls.direction_case), ...
        sprintf('beta_wind = %g deg', summary.uls.beta_wind), ...
        sprintf('beta_wave = %g deg', summary.uls.beta_wave), ...
        sprintf('governing_environment_case = %s', summary.uls.environment_case), ...
        sprintf('governing_floor = %g', summary.uls.floor), ...
        sprintf('governing_member_type = %s', summary.uls.member_type), ...
        sprintf('governing_member_id = %g', summary.uls.member_id), ...
        sprintf('demand = %g', summary.uls.demand), ...
        sprintf('capacity = %g', summary.uls.capacity), ...
        ''];
end

if ~isempty(summary.deflection)
    lines = [lines, ...
        '=== Directional Deflection Summary ===', ...
        sprintf('governing_direction_case = %s', summary.deflection.direction_case), ...
        sprintf('beta_wind = %g deg', summary.deflection.beta_wind), ...
        sprintf('beta_wave = %g deg', summary.deflection.beta_wave), ...
        sprintf('governing_environment_case = %s', summary.deflection.environment_case), ...
        sprintf('governing_member_type = %s', summary.deflection.member_type), ...
        sprintf('max_deflection = %g m', summary.deflection.max_deflection), ...
        ''];
end

textBlock = joinLines(lines);
end

function writeTextFile(summaryPath, textBlock)
fid = fopen(summaryPath, 'w', 'n', 'UTF-8');
if fid < 0
    error('write_directional_summary:FileOpenFailed', ...
        'Could not open summary file: %s', summaryPath);
end
fprintf(fid, '%s', textBlock);
fclose(fid);
end

function text = joinLines(lines)
if isempty(lines)
    text = '';
    return;
end
text = sprintf('%s\n', lines{:});
end

function validateSummary(summary)
if ~isstruct(summary) || ~isfield(summary, 'mode')
    error('write_directional_summary:InvalidSummary', ...
        'summary must be a struct with field ''mode''.');
end

hasLegacy = isfield(summary, 'legacy') && ~isempty(summary.legacy);
hasUls = isfield(summary, 'uls') && ~isempty(summary.uls);
hasDeflection = isfield(summary, 'deflection') && ~isempty(summary.deflection);

if hasLegacy
    requiredLegacy = {'pesai_legacy', 'calculation', 'purpose'};
    for i = 1:numel(requiredLegacy)
        if ~isfield(summary.legacy, requiredLegacy{i})
            error('write_directional_summary:MissingField', ...
                'summary.legacy must contain field ''%s''.', requiredLegacy{i});
        end
    end
    return;
end

if ~hasUls
    error('write_directional_summary:MissingField', ...
        'Paper-mode summary must contain non-empty summary.uls.');
end

requiredUls = {'direction_case', 'beta_wind', 'beta_wave', 'environment_case', ...
    'floor', 'member_type', 'member_id', 'demand', 'capacity'};
for i = 1:numel(requiredUls)
    if ~isfield(summary.uls, requiredUls{i})
        error('write_directional_summary:MissingField', ...
            'summary.uls must contain field ''%s''.', requiredUls{i});
    end
end

if hasDeflection
    requiredDeflection = {'direction_case', 'beta_wind', 'beta_wave', ...
        'environment_case', 'max_deflection', 'member_type'};
    for i = 1:numel(requiredDeflection)
        if ~isfield(summary.deflection, requiredDeflection{i})
            error('write_directional_summary:MissingField', ...
                'summary.deflection must contain field ''%s''.', requiredDeflection{i});
        end
    end
end
end
