%% Validation path setup
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(projectRoot);
addpath(fullfile(projectRoot, 'modules'));

clc;
clearvars;
% Test current velocity
% [Vc]=Current_vel(U_ss0,U_ns0,z,d,h_ref)
U_ss0=0.6;
U_ns0=0.6;
d=50;
h_ref=20; % 与 inputdata.dat 表层流参考深度一致
z=zeros(51,1);
Vc=zeros(51,1);
for i=1:51
    z(i)=(i-1);
    Vc(i)=Current_vel(U_ss0,U_ns0,z(i),d,h_ref);
end

