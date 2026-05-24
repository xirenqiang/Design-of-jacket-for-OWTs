% Smoke test for resize_member_sections.
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(fullfile(projectRoot, 'modules'));

cfg = build_design_config(struct());
D_leg = 0.8;
t_leg = 0.04;
D_brace = 0.5;
t_brace = 0.02;

[D_leg2, t_leg2, D_brace2, t_brace2, resized] = resize_member_sections( ...
    D_leg, t_leg, D_brace, t_brace, struct('leg_exceeds', true, 'brace_exceeds', false), cfg);
assert(resized, 'Expected resized true');
assert(abs(D_leg2 - (D_leg + cfg.delta_D_leg)) < 1e-12, 'D_leg increment mismatch');
assert(abs(t_leg2 - (t_leg + cfg.delta_t_leg)) < 1e-12, 't_leg increment mismatch');
assert(D_brace2 == D_brace, 'D_brace should be unchanged');
fprintf('PASS: resize_member_sections leg increment\n');

[D_leg3, t_leg3, D_brace3, t_brace3, resized2] = resize_member_sections( ...
    D_leg, t_leg, D_brace, t_brace, struct('leg_exceeds', false, 'brace_exceeds', true), cfg);
assert(resized2, 'Expected resized true for brace');
assert(abs(D_brace3 - (D_brace + cfg.delta_D_brace)) < 1e-12, 'D_brace increment mismatch');
fprintf('PASS: resize_member_sections brace increment\n');

fprintf('All resize_member_sections smoke tests passed.\n');
