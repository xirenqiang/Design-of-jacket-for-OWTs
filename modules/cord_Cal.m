function cord_Cal(numBar, water_depth)
%CORD_CAL  Print and plot members in engineering axes (SWL at Z=0).
% Engineering axes mapping from internal Member:
%   X_out = X_in, Y_out = Z_in, Z_out = Y_in - water_depth.
global Member
global Wave
if isempty(Member) || ~isfield(Member, 'L')
    error('cord_Cal: global Member is empty or missing fields; run geometry first.');
end
if nargin < 1 || isempty(numBar)
    numBar = numel(Member.L);
end
if nargin < 2 || isempty(water_depth)
    if ~isempty(Wave) && isfield(Wave, 'S')
        water_depth = Wave.S;
    else
        water_depth = 50;
    end
end
numBar = min(numBar, numel(Member.L));
fprintf('cord_Cal: %d members (engineering axes, SWL=0)\n', numBar);
nShow = min(numBar, 24);
for i = 1:nShow
    x0 = Member.X0(i);
    y0 = Member.Z0(i);
    z0 = Member.Y0(i) - water_depth;
    xt = Member.Xt(i);
    yt = Member.Zt(i);
    zt = Member.Yt(i) - water_depth;
    fprintf( ...
        '  %2d: (%.4f,%.4f,%.4f) -> (%.4f,%.4f,%.4f)  D=%.4f t=%.4f\n', ...
        i, ...
        x0, y0, z0, ...
        xt, yt, zt, ...
        Member.D(i), Member.t(i));
end
if numBar > nShow
    fprintf('  ... (%d more members omitted from listing)\n', numBar - nShow);
end

figure;
hold on;
grid on;
view(3);
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m, SWL=0)');
title('Jacket members (engineering axes, SWL=0)');
for i = 1:numBar
    plot3( ...
        [Member.X0(i) Member.Xt(i)], ...
        [Member.Z0(i) Member.Zt(i)], ...
        [Member.Y0(i) - water_depth, Member.Yt(i) - water_depth], ...
        'b-', 'LineWidth', 1.2);
end
xc = [Member.X0(1:numBar)'; Member.Xt(1:numBar)'];
yc = [Member.Z0(1:numBar)'; Member.Zt(1:numBar)'];
zc = [Member.Y0(1:numBar)' - water_depth; Member.Yt(1:numBar)' - water_depth];
scatter3(xc, yc, zc, 24, 'r', 'filled');
hold off;
end
