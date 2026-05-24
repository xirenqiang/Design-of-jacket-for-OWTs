%% Validation path setup
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(projectRoot);
addpath(fullfile(projectRoot, 'modules'));

clc;
clearvars;
T=10.4;
h=10;
S=40;
Vc=0;
x=0;
z=10;
t0=0;
t1=200;
dt=0.2;
N=(t1-t0)/dt+1;
t=zeros(N,1);
u=zeros(N,1);
v=zeros(N,1);
k=wave_number(T,S);
for i=1:N
    t(i)=(i-1)*dt;
    [u(i),v(i)]=Vel_fluid_particle(T,h,k,S,Vc,x,z,t(i));
end
umax=max(abs(u));
vmax=max(abs(v));
