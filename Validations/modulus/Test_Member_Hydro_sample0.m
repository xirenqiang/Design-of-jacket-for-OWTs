%% Validation path setup
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(projectRoot);
addpath(fullfile(projectRoot, 'modules'));

clc;
clearvars;
% 模块说明：该段用于模型初始化或分步计算
global Member;
global Hydro;
global Wave;
global Current;
global Discrete;
global debug;
global dL_ele_target;
debug=0;
if isempty(dL_ele_target), dL_ele_target=1; end
if ~isstruct(Hydro), Hydro=struct(); end
if ~isstruct(Wave), Wave=struct(); end
if ~isstruct(Current), Current=struct(); end
if ~isstruct(Discrete), Discrete=struct(); end
if ~isfield(Hydro,'density'), Hydro.density=1025; end
if ~isfield(Hydro,'cd'), Hydro.cd=1.0; end
if ~isfield(Hydro,'cm'), Hydro.cm=2.0; end
if ~isfield(Wave,'S'), Wave.S=50; end
if ~isfield(Wave,'T'), Wave.T=12.49; end
if ~isfield(Wave,'h'), Wave.h=0; end
if ~isfield(Wave,'k'), Wave.k=wave_number(Wave.T,Wave.S); end
if ~isfield(Current,'U_ss0'), Current.U_ss0=0; end
if ~isfield(Current,'U_ns0'), Current.U_ns0=0; end
if ~isfield(Current,'h_ref'), Current.h_ref=20; end
Num_bar=1;
% 模块说明：该段用于模型初始化或分步计算
Member.X0(1)=8.4853;Member.Y0(1)=0;Member.Z0(1)=0;Member.Xt(1)=0;Member.Yt(1)=0;Member.Zt(1)=-8.4853;% 构件起点与终点坐标
Member.D=[0.6 0.6];% 构件直径
for i=1:Num_bar
    Member.L(i)=sqrt((Member.Xt(i)-Member.X0(i))^2+(Member.Yt(i)-Member.Y0(i))^2+(Member.Zt(i)-Member.Z0(i))^2);% 构件起点与终点坐标
    if Member.Yt(i)-Member.Y0(i)==0
        Member.fai_y(i)=90;
    else
        Member.fai_y(i)=atand(sqrt((Member.Xt(i)-Member.X0(i))^2+(Member.Zt(i)-Member.Z0(i))^2)/(Member.Yt(i)-Member.Y0(i)));% 构件起点与终点坐标
    end
    if Member.Xt(i)-Member.X0(i)==0
        Member.cita_x(i)=90;
    else
        Member.cita_x(i)=atand((Member.Zt(i)-Member.Z0(i))/(Member.Xt(i)-Member.X0(i)));% 构件起点与终点坐标
    end
    Member.cx(i)=sind(Member.fai_y(i))*cosd(Member.cita_x(i));
    Member.cy(i)=cosd(Member.fai_y(i));
    Member.cz(i)=sind(Member.fai_y(i))*sind(Member.cita_x(i));
end
Hydro.density=1025;% 海水密度
Hydro.cd=1.0;% 阻力系数
Hydro.cm=2.0;% 惯性系数
Wave.T=10.4;% 波浪周期
Wave.h=10;% 波高
Wave.S=40;% 水深
Wave.k=wave_number(Wave.T,Wave.S);% 波浪周期
Current.Vc=0;% 海流速度
Discrete.Num_ele(1)=1;
Discrete.dL(1)=Member.L(1)/Discrete.Num_ele(1);
Num_element=Discrete.Num_ele(1);
t0=0;
t1=100;
dt=0.2;
N=(t1-t0)/dt+1;
t=zeros(N,1);
Ftx=zeros(N,1);
Fty=zeros(N,1);
Ftz=zeros(N,1);
Mtx=zeros(N,1);
Mtz=zeros(N,1);
ut=zeros(N,1);
vt=zeros(N,1);
i=1;
pesai=0;
for k=1:N
    t(k)=(k-1)*dt;
% 模块说明：该段用于模型初始化或分步计算
    x=zeros(Num_element,1);y=zeros(Num_element,1);
    ux=zeros(Num_element,1);vy=zeros(Num_element,1);
    V=zeros(Num_element,1);un=zeros(Num_element,1);vn=zeros(Num_element,1);wn=zeros(Num_element,1);
    ax=zeros(Num_element,1);ay=zeros(Num_element,1);
    anx=zeros(Num_element,1);any=zeros(Num_element,1);anz=zeros(Num_element,1);
    Fx=0;Fy=0;Fz=0;
    Mx=0;Mz=0;
    for j=1:Num_element
        dt_L=Discrete.dL(1);
        y(j)=Member.Y0(i)+(j-0.5)*dt_L*cosd(Member.fai_y(i));
        x(j)=Member.X0(i)+(j-0.5)*dt_L*sind(Member.fai_y(i))*sind(Member.cita_x(i));
        A=[cosd(pesai),sind(pesai);-sind(pesai),cosd(pesai)]*[Member.X0(i)+(j-0.5)*dt_L*sind(Member.fai_y(i))*cosd(Member.cita_x(i));Member.Y0(i)+(j-0.5)*dt_L*sind(Member.fai_y(i))*sind(Member.cita_x(i))];
        x(j,1)=A(1,1);
        z(j,1)=A(2,1);
        [ux(j),vy(j)]=Vel_fluid_particle(Wave.T,Wave.h,Wave.k,Wave.S,Current.Vc,x(j),y(j),t(k),z(j,1));
        [ax(j),ay(j)]=ACC_fluid_particle(Wave.T,Wave.h,Wave.k,Wave.S,x(j),y(j),t(k),z(j,1));
        [V(j),un(j),vn(j),wn(j)]=Vel_resolve(ux(j),vy(j),Member.cx(i),Member.cy(i),Member.cz(i));
        [anx(j),any(j),anz(j)]=ACC_resolve(ax(j),ay(j),Member.cx(i),Member.cy(i),Member.cz(i));
        Fjx=(0.5*Hydro.density*Member.D(i)*Hydro.cd*V(j)*un(j)+0.25*Hydro.density*pi*(Member.D(i))^2*Hydro.cm*anx(j))*dt_L; %
        Mjz=Fjx*y(j);
        Fjy=(0.5*Hydro.density*Member.D(i)*Hydro.cd*V(j)*vn(j)+0.25*Hydro.density*pi*(Member.D(i))^2*Hydro.cm*any(j))*dt_L; %
        Fjz=(0.5*Hydro.density*Member.D(i)*Hydro.cd*V(j)*wn(j)+0.25*Hydro.density*pi*(Member.D(i))^2*Hydro.cm*anz(j))*dt_L;%
        Mjx=Fjz*y(j);
        Fx=Fx+Fjx;
        Fy=Fy+Fjy;
        Fz=Fz+Fjz;
        Mx=Mx+Mjx;
        Mz=Mz+Mjz;
    end
    ut(k,1)=ux(Num_element);
    vt(k,1)=vy(Num_element);
    Ftx(k)=Fx;
    Fty(k)=Fy;
    Ftz(k)=Fz;
    Mtx(k)=Mx;
    Mtz(k)=Mz;
end
Ftx_max=max(abs(Ftx));
Fty_max=max(abs(Fty));
Ftz_max=max(abs(Ftz));
Mtx_max=max(abs(Mtx));
Mtz_max=max(abs(Mtz));



