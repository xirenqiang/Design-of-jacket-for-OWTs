%% Validation path setup
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(projectRoot);
addpath(fullfile(projectRoot, 'modules'));

clc;
clearvars;
global Member;
global Discrete;
global dL_ele_target;
dL_ele_target=3.0;
Num_bar=1;
Member.X0(1)=0; Member.Y0(1)=0; Member.Z0(1)=0;
Member.Xt(1)=0; Member.Yt(1)=35; Member.Zt(1)=0;
Member.D(1)=6.0;
Member.L(1)=sqrt((Member.Xt(1)-Member.X0(1))^2+(Member.Yt(1)-Member.Y0(1))^2+(Member.Zt(1)-Member.Z0(1))^2);
Member.fai_y(1)=atand(sqrt((Member.Xt(1)-Member.X0(1))^2+(Member.Zt(1)-Member.Z0(1))^2)/(Member.Yt(1)-Member.Y0(1)));
if Member.Xt(1)-Member.X0(1)==0
    Member.cita_x(1)=90;
else
    Member.cita_x(1)=atand((Member.Zt(1)-Member.Z0(1))/(Member.Xt(1)-Member.X0(1)));
end
Discrete.Num_ele(1)=ceil(Member.L(1));
Discrete.dL(1)=Member.L(1)/Discrete.Num_ele(1);

x=zeros(100,Num_bar);
y=zeros(100,Num_bar);
z=zeros(100,Num_bar);
for i=1:Num_bar
    dx=(Member.Xt(i)-Member.X0(i))/Discrete.Num_ele(i);
    dy=(Member.Yt(i)-Member.Y0(i))/Discrete.Num_ele(i);
    dz=(Member.Zt(i)-Member.Z0(i))/Discrete.Num_ele(i);
    for j=1:Discrete.Num_ele(i)
        x(j,i)=Member.X0(i)+(j-0.5)*dx;
        y(j,i)=Member.Y0(i)+(j-0.5)*dy;
        z(j,i)=Member.Z0(i)+(j-0.5)*dz;
    end
end
