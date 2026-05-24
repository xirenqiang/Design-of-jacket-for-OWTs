function member_export(outPath, numBar, water_depth)
%MEMBER_EXPORT Export member line elements in engineering axes to tab-separated .dat.
% Engineering axes mapping from internal Member:
%   X_out = X_in, Y_out = Z_in, Z_out = Y_in - water_depth (SWL at Z=0).
global Member
global Wave
if isempty(Member) || ~isfield(Member, 'L')
    error('member_export: global Member is empty or missing fields; run geometry first.');
end
if nargin < 1 || isempty(outPath)
    outPath = fullfile(pwd, 'jacket_elements.dat');
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
numBar = min(numBar, numel(Member.L));
elementId = (1:numBar)';
x0 = Member.X0(1:numBar)';
y0 = Member.Z0(1:numBar)';
z0 = Member.Y0(1:numBar)' - water_depth;
xt = Member.Xt(1:numBar)';
yt = Member.Zt(1:numBar)';
zt = Member.Yt(1:numBar)' - water_depth;
d_m = Member.D(1:numBar)';
t_m = Member.t(1:numBar)';
headers = {'ElementId', 'X0_m', 'Y0_m', 'Z0_m', 'Xt_m', 'Yt_m', 'Zt_m', 'D_m', 't_m'};
M = [elementId, x0, y0, z0, xt, yt, zt, d_m, t_m];
write_tab_separated_dat(outPath, headers, M);
fprintf('member_export: wrote %d members to %s\n', numBar, outPath);
end

function write_tab_separated_dat(path, headers, M)
fid = fopen(path, 'w');
if fid < 0
    error('member_export: cannot open %s for writing', path);
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
