function node_export(outPath, numBar, water_depth, decPlaces)
%NODE_EXPORT Export unique nodes in engineering axes to tab-separated .dat and plot.
% Compatible with older MATLAB (e.g. R2009b): avoids round(X,N) and unique(...,'stable').
% Engineering axes mapping from internal Member:
%   X_out = X_in, Y_out = Z_in, Z_out = Y_in - water_depth (SWL at Z=0).
global Member
global Wave
if isempty(Member) || ~isfield(Member, 'L')
    error('node_export: global Member is empty or missing fields; run geometry first.');
end
if nargin < 1 || isempty(outPath)
    outPath = fullfile(pwd, 'node_coordinates.dat');
end
if nargin < 2 || isempty(numBar)
    numBar = numel(Member.L);
end
if nargin < 3 || isempty(water_depth)
    if ~isempty(Wave) && isfield(Wave, 'S')
        water_depth = Wave.S;
    else
        water_depth = 50;
    end
end
if nargin < 4 || isempty(decPlaces)
    decPlaces = 6;
end
numBar = min(numBar, numel(Member.L));
p0 = [Member.X0(1:numBar)' Member.Z0(1:numBar)' Member.Y0(1:numBar)' - water_depth];
pt = [Member.Xt(1:numBar)' Member.Zt(1:numBar)' Member.Yt(1:numBar)' - water_depth];
scale = 10^decPlaces;
pts = round([p0; pt] * scale) / scale;
uNodes = node_export_unique_rows_first(pts);
nodeIndex = (1:size(uNodes, 1))';
headers = {'NodeIndex', 'X_m', 'Y_m', 'Z_m'};
M = [nodeIndex, uNodes(:, 1), uNodes(:, 2), uNodes(:, 3)];
write_tab_separated_dat(outPath, headers, M);
fprintf('node_export: wrote %d unique nodes to %s\n', size(uNodes, 1), outPath);

figure;
hold on;
grid on;
view(3);
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m, SWL=0)');
title('Jacket: members and nodes (engineering axes, SWL=0)');
for i = 1:numBar
    plot3( ...
        [Member.X0(i) Member.Xt(i)], ...
        [Member.Z0(i) Member.Zt(i)], ...
        [Member.Y0(i) - water_depth, Member.Yt(i) - water_depth], ...
        'k-', 'LineWidth', 1.0);
end
scatter3(uNodes(:, 1), uNodes(:, 2), uNodes(:, 3), 36, 'filled', 'MarkerFaceColor', [0.2 0.5 0.9]);
hold off;
end

function write_tab_separated_dat(path, headers, M)
fid = fopen(path, 'w');
if fid < 0
    error('node_export: cannot open %s for writing', path);
end
fprintf(fid, '# Coordinate convention: X horizontal, Y horizontal, Z vertical (SWL=0). Tab-separated.\n');
for i = 1:numel(headers)
    if i > 1
        fprintf(fid, '\t');
    end
    fprintf(fid, '%s', headers{i});
end
fprintf(fid, '\n');
[nr, nc] = size(M);
for r = 1:nr
    fprintf(fid, '%d', round(M(r, 1)));
    for c = 2:nc
        fprintf(fid, '\t%.12g', M(r, c));
    end
    fprintf(fid, '\n');
end
fclose(fid);
end

function B = node_export_unique_rows_first(A)
%NODE_EXPORT_UNIQUE_ROWS_FIRST  Unique rows keeping first occurrence (pre-R2013a unique).
[n, p] = size(A);
m = 0;
B = zeros(n, p);
for k = 1:n
    v = A(k, :);
    isNew = true;
    for t = 1:m
        if isequal(v, B(t, :))
            isNew = false;
            break;
        end
    end
    if isNew
        m = m + 1;
        B(m, :) = v;
    end
end
B = B(1:m, :);
end

