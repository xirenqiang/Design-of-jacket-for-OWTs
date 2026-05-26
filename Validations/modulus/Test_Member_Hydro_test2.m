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
Member.X0(1)=0;Member.Y0(1)=0;Member.Z0(1)=0;
Member.Xt(1)=28.2843;Member.Yt(1)=28.2843;Member.Zt(1)=0;% 关键参数或中间量设置
Member.D=[6.0];% 构件直径
for i=1:Num_bar
    Member.L(i)=sqrt((Member.Xt(i)-Member.X0(i))^2+(Member.Yt(i)-Member.Y0(i))^2+(Member.Zt(i)-Member.Z0(i))^2);% 构件起点与终点坐标
    Member.fai_y(i)=atand(sqrt((Member.Xt(i)-Member.X0(i))^2+(Member.Zt(i)-Member.Z0(i))^2)/(Member.Yt(i)-Member.Y0(i)));% 构件起点与终点坐标
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
Wave.h=0;% 波高
Wave.S=40;% 水深
Wave.k=wave_number(Wave.T,Wave.S);% 波浪周期
Current.Vc=2;% 海流速度
Discrete.Num_ele(1)=ceil(Member.L(1));
Discrete.dL(1)=Member.L(1)/Discrete.Num_ele(1);
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
for i=1:N
    ti=(i-1)*dt;
    [Ftx(i),Fty(i),Ftz(i),Mtx(i),Mtz(i)]=Hydro_member1(1,Discrete.Num_ele(1),Discrete.dL(1),ti);
end
Ftx_max=max(abs(Ftx));
Fty_max=max(abs(Fty));
Ftz_max=max(abs(Ftz));
Mtx_max=max(abs(Mtx));
Mtz_max=max(abs(Mtz));



