%% Validation path setup
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(projectRoot);
addpath(fullfile(projectRoot, 'modules'));

clc;
clearvars;
% 模块说明：该段用于模型初始化或分步计算
pesai=45;% 关键参数或中间量设置
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
Num_bar=4;
% 模块说明：该段用于模型初始化或分步计算
Member.X0(1)=6;Member.Y0(1)=0;Member.Z0(1)=6;Member.Xt(1)=4;Member.Yt(1)=67;Member.Zt(1)=4;% 构件起点与终点坐标
Member.X0(2)=6;Member.Y0(2)=0;Member.Z0(2)=-6;Member.Xt(2)=4;Member.Yt(2)=67;Member.Zt(2)=-4;% 构件起点与终点坐标
Member.X0(3)=-6;Member.Y0(3)=0;Member.Z0(3)=-6;Member.Xt(3)=-4;Member.Yt(3)=67;Member.Zt(3)=-4;% 构件起点与终点坐标
Member.X0(4)=-6;Member.Y0(4)=0;Member.Z0(4)=6;Member.Xt(4)=-4;Member.Yt(4)=67;Member.Zt(4)=4;% 构件起点与终点坐标
% for j=1:Num_bar
%     [Member.X0(j),Member.Y0(j),Member.Z0(j)]=coordinate_trans(Member.X0(j),Member.Y0(j),Member.Z0(j),pesai);
%     [Member.Xt(j),Member.Yt(j),Member.Zt(j)]=coordinate_trans(Member.Xt(j),Member.Yt(j),Member.Zt(j),pesai);
% end
Member.D=[1.2 1.2 1.2 1.2 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6];% 构件直径
for i=1:Num_bar
    [Member.X0(i),Member.Y0(i),Member.Z0(i)]=coordinate_trans(Member.X0(i),Member.Y0(i),Member.Z0(i),pesai);
    [Member.Xt(i),Member.Yt(i),Member.Zt(i)]=coordinate_trans(Member.Xt(i),Member.Yt(i),Member.Zt(i),pesai);
    Member.L(i)=sqrt((Member.Xt(i)-Member.X0(i))^2+(Member.Yt(i)-Member.Y0(i))^2+(Member.Zt(i)-Member.Z0(i))^2);% 构件起点与终点坐标
    if abs(Member.Yt(i)-Member.Y0(i))<=1e-6
        Member.fai_y(i)=90;
    else
        Member.fai_y(i)=atand(sqrt((Member.Xt(i)-Member.X0(i))^2+(Member.Zt(i)-Member.Z0(i))^2)/(Member.Yt(i)-Member.Y0(i)));% 构件起点与终点坐标
    end
    if abs(Member.Xt(i)-Member.X0(i))<=1e-6
        Member.cita_x(i)=90*(Member.Zt(i)-Member.Z0(i))/abs((Member.Zt(i)-Member.Z0(i)));
    else
        Member.cita_x(i)=atand((Member.Zt(i)-Member.Z0(i))/(Member.Xt(i)-Member.X0(i)));% 构件起点与终点坐标
    end
    Member.cx(i)=sind(Member.fai_y(i))*cosd(Member.cita_x(i));
    Member.cy(i)=cosd(Member.fai_y(i));
    Member.cz(i)=sind(Member.fai_y(i))*sind(Member.cita_x(i));
    Discrete.Num_ele(i)=ceil(Member.L(i));
    Discrete.dL(i)=Member.L(i)/Discrete.Num_ele(i);
end
Hydro.density=1025;% 海水密度
Hydro.cd=1.0;% 阻力系数
Hydro.cm=2.0;% 惯性系数
Wave.T=12.49;% 波浪周期
Wave.h=12.42;% 波高
Wave.S=40;% 水深
Wave.k=wave_number(Wave.T,Wave.S);% 波浪周期
Current.Vc=0;% 海流速度
t0=0;
t1=50;
dt=0.1;
N=(t1-t0)/dt+1;
t=zeros(N,1);
Ftx=zeros(N,1);
F_bracex=zeros(N,Num_bar);
F_bracez=zeros(N,Num_bar);
Fty=zeros(N,1);
Ftz=zeros(N,1);
Mtx=zeros(N,1);
Mtz=zeros(N,1);
for i=1:N
    t(i)=(i-1)*dt;
    F_brax=zeros(Num_bar,1);
    F_bray=zeros(Num_bar,1);
    F_braz=zeros(Num_bar,1);
    M_brx=zeros(Num_bar,1);
    M_brz=zeros(Num_bar,1);
    for j_brace=1:Num_bar
        [F_brax( j_brace),F_bray( j_brace),F_braz( j_brace),M_brx( j_brace),M_brz( j_brace)]=Hydro_member1(j_brace,Discrete.Num_ele(j_brace),Discrete.dL(j_brace),t(i));
        Ftx(i)=Ftx(i)+F_brax( j_brace);
        F_bracex(i,j_brace)=F_brax( j_brace);
        F_bracez(i,j_brace)=F_braz( j_brace);
        Fty(i)=Fty(i)+F_bray( j_brace);
        Ftz(i)=Ftz(i)+F_braz( j_brace);
        Mtx(i)=Mtx(i)+M_brx( j_brace);
        Mtz(i)=Mtz(i)+M_brz( j_brace);
    end
end
Ftx_max=max(abs(Ftx));
Fty_max=max(abs(Fty));
Ftz_max=max(abs(Ftz));
Mtx_max=max(abs(Mtx));
Mtz_max=max(abs(Mtz));
plot(t,F_bracex(:,1))
hold on
plot(t,F_bracex(:,2),'r')



