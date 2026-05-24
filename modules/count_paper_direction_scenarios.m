function nPaper = count_paper_direction_scenarios(scenarios)
%COUNT_PAPER_DIRECTION_SCENARIOS Number of non-legacy direction cases.
%
% Step 8: legacy metadata scenarios (is_legacy=true) are excluded from
% uls_floor_envelope evaluation.

if isempty(scenarios)
    nPaper = 0;
    return;
end
isLegacy = false(1, numel(scenarios));
for i = 1:numel(scenarios)
    if isfield(scenarios(i), 'is_legacy') && scenarios(i).is_legacy
        isLegacy(i) = true;
    end
end
nPaper = sum(~isLegacy);
end
