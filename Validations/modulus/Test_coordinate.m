%% Validation path setup
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(projectRoot);
addpath(fullfile(projectRoot, 'modules'));

clc;
clearvars;
xb=1;zb=1;
d_pesai=15;
N=360/15;
xg=zeros(N,1);
zg=zeros(N,1);
for i=1:N
pesai=i*15;
A=[cosd(pesai),sind(pesai);-sind(pesai),cosd(pesai)];
coord=A*[xb;zb];
xg(i)=coord(1);
zg(i)=coord(2);
end
