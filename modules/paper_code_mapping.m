classdef paper_code_mapping
%PAPER_CODE_MAPPING Paper-to-code coordinate mapping helpers (Step 3).
%
% Convention (PLAN_DIRECTIONAL_LOADS §17 Step 3):
%   paper x -> code X
%   paper y -> code Z
%   paper z -> code Y
%
% Direction angles beta are measured in the horizontal plane,
% counter-clockwise from +X (code X-Z plane).

    methods (Static)
        function betaCode = map_paper_plan_to_code(betaPaper, psiSite)
            validateAngle(betaPaper, 'betaPaper');
            validateAngle(psiSite, 'psiSite');
            betaCode = normalize_angle(betaPaper + psiSite);
        end

        function betaPaper = map_code_to_paper_plan(betaCode, psiSite)
            validateAngle(betaCode, 'betaCode');
            validateAngle(psiSite, 'psiSite');
            betaPaper = normalize_angle(betaCode - psiSite);
        end

        function components = paper_plan_components_to_code(F_paper_x, F_paper_y)
            if ~isfinite(F_paper_x) || ~isfinite(F_paper_y)
                error('paper_code_mapping:InvalidComponent', ...
                    'Force components must be finite scalars.');
            end
            components = struct( ...
                'Fx', F_paper_x, ...
                'Fz', F_paper_y, ...
                'Fy', 0);
        end

        function A = rotation_matrix_code_xz(thetaDeg)
            validateAngle(thetaDeg, 'thetaDeg');
            A = [cosd(thetaDeg), sind(thetaDeg); -sind(thetaDeg), cosd(thetaDeg)];
        end
    end
end

function angleDeg = normalize_angle(angleDeg)
angleDeg = mod(angleDeg, 360);
end

function validateAngle(value, name)
if ~isscalar(value) || ~isfinite(value)
    error('paper_code_mapping:InvalidAngle', ...
        '%s must be a finite scalar angle in degrees.', name);
end
end
