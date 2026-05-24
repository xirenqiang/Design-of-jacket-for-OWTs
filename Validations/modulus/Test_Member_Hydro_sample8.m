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
Num_bar=32;
Member.X0(1)=-6;Member.Y0(1)=0;Member.Z0(1)=6;Member.Xt(1)=5.45;Member.Yt(1)=19.25;Member.Zt(1)=5.45;% 构件起点与终点坐标
Member.X0(2)=6;Member.Y0(2)=0;Member.Z0(2)=6;Member.Xt(2)=-5.45;Member.Yt(2)=19.25;Member.Zt(2)=5.45;% 构件起点与终点坐标
Member.X0(3)=-5.45;Member.Y0(3)=19.25;Member.Z0(3)=5.45;Member.Xt(3)=4.95;Member.Yt(3)=36.75;Member.Zt(3)=4.95;% 构件起点与终点坐标
Member.X0(4)=5.45;Member.Y0(4)=19.25;Member.Z0(4)=5.45;Member.Xt(4)=-4.95;Member.Yt(4)=36.75;Member.Zt(4)=4.95;% 构件起点与终点坐标
Member.X0(5)=-4.95;Member.Y0(5)=36.75;Member.Z0(5)=4.95;Member.Xt(5)=4.45;Member.Yt(5)=52.55;Member.Zt(5)=4.45;% 构件起点与终点坐标
Member.X0(6)=4.95;Member.Y0(6)=36.75;Member.Z0(6)=4.95;Member.Xt(6)=-4.45;Member.Yt(6)=52.55;Member.Zt(6)=4.45;% 构件起点与终点坐标
Member.X0(7)=-4.45;Member.Y0(7)=52.55;Member.Z0(7)=4.45;Member.Xt(7)=4;Member.Yt(7)=67;Member.Zt(7)=4;% 构件起点与终点坐标
Member.X0(8)=4.45;Member.Y0(8)=52.55;Member.Z0(8)=4.45;Member.Xt(8)=-4;Member.Yt(8)=67;Member.Zt(8)=4;% 构件起点与终点坐标
Member.X0(9)=-6;Member.Y0(9)=0;Member.Z0(9)=-6;Member.Xt(9)=5.45;Member.Yt(9)=19.25;Member.Zt(9)=-5.45;% 构件起点与终点坐标
Member.X0(10)=6;Member.Y0(10)=0;Member.Z0(10)=-6;Member.Xt(10)=-5.45;Member.Yt(10)=19.25;Member.Zt(10)=-5.45;% 构件起点与终点坐标
Member.X0(11)=-5.45;Member.Y0(11)=19.25;Member.Z0(11)=-5.45;Member.Xt(11)=4.95;Member.Yt(11)=36.75;Member.Zt(11)=-4.95;% 构件起点与终点坐标
Member.X0(12)=5.45;Member.Y0(12)=19.25;Member.Z0(12)=-5.45;Member.Xt(12)=-4.95;Member.Yt(12)=36.75;Member.Zt(12)=-4.95;% 构件起点与终点坐标
Member.X0(13)=-4.95;Member.Y0(13)=36.75;Member.Z0(13)=-4.95;Member.Xt(13)=4.45;Member.Yt(13)=52.55;Member.Zt(13)=-4.45;% 构件起点与终点坐标
Member.X0(14)=4.95;Member.Y0(14)=36.75;Member.Z0(14)=-4.95;Member.Xt(14)=-4.45;Member.Yt(14)=52.55;Member.Zt(14)=-4.45;% 构件起点与终点坐标
Member.X0(15)=-4.45;Member.Y0(15)=52.55;Member.Z0(15)=-4.45;Member.Xt(15)=4;Member.Yt(15)=67;Member.Zt(15)=-4;% 构件起点与终点坐标
Member.X0(16)=4.45;Member.Y0(16)=52.55;Member.Z0(16)=-4.45;Member.Xt(16)=-4;Member.Yt(16)=67;Member.Zt(16)=-4;% 构件起点与终点坐标
Member.X0(17)=-6;Member.Y0(17)=0;Member.Z0(17)=6;Member.Xt(17)=-5.45;Member.Yt(17)=19.25;Member.Zt(17)=-5.45;% 构件起点与终点坐标
Member.X0(18)=-6;Member.Y0(18)=0;Member.Z0(18)=-6;Member.Xt(18)=-5.45;Member.Yt(18)=19.25;Member.Zt(18)=5.45;% 构件起点与终点坐标
Member.X0(19)=-5.45;Member.Y0(19)=19.25;Member.Z0(19)=5.45;Member.Xt(19)=-4.95;Member.Yt(19)=36.75;Member.Zt(19)=-4.95;% 构件起点与终点坐标
Member.X0(20)=-5.45;Member.Y0(20)=19.25;Member.Z0(20)=-5.45;Member.Xt(20)=-4.95;Member.Yt(20)=36.75;Member.Zt(20)=4.95;% 构件起点与终点坐标
Member.X0(21)=-4.95;Member.Y0(21)=36.75;Member.Z0(21)=4.95;Member.Xt(21)=-4.45;Member.Yt(21)=52.55;Member.Zt(21)=-4.45;% 构件起点与终点坐标
Member.X0(22)=-4.95;Member.Y0(22)=36.75;Member.Z0(22)=-4.95;Member.Xt(22)=-4.45;Member.Yt(22)=52.55;Member.Zt(22)=4.45;% 构件起点与终点坐标
Member.X0(23)=-4.45;Member.Y0(23)=52.55;Member.Z0(23)=4.45;Member.Xt(23)=-4;Member.Yt(23)=67;Member.Zt(23)=-4;% 构件起点与终点坐标
Member.X0(24)=-4.45;Member.Y0(24)=52.55;Member.Z0(24)=-4.45;Member.Xt(24)=-4;Member.Yt(24)=67;Member.Zt(24)=4;% 构件起点与终点坐标
Member.X0(25)=6;Member.Y0(25)=0;Member.Z0(25)=6;Member.Xt(25)=5.45;Member.Yt(25)=19.25;Member.Zt(25)=-5.45;% 构件起点与终点坐标
Member.X0(26)=6;Member.Y0(26)=0;Member.Z0(26)=-6;Member.Xt(26)=5.45;Member.Yt(26)=19.25;Member.Zt(26)=5.45;% 构件起点与终点坐标
Member.X0(27)=5.45;Member.Y0(27)=19.25;Member.Z0(27)=5.45;Member.Xt(27)=4.95;Member.Yt(27)=36.75;Member.Zt(27)=-4.95;% 构件起点与终点坐标
Member.X0(28)=5.45;Member.Y0(28)=19.25;Member.Z0(28)=-5.45;Member.Xt(28)=4.95;Member.Yt(28)=36.75;Member.Zt(28)=4.95;% 构件起点与终点坐标
Member.X0(29)=4.95;Member.Y0(29)=36.75;Member.Z0(29)=4.95;Member.Xt(29)=4.45;Member.Yt(29)=52.55;Member.Zt(29)=-4.45;% 构件起点与终点坐标
Member.X0(30)=4.95;Member.Y0(30)=36.75;Member.Z0(30)=-4.95;Member.Xt(30)=4.45;Member.Yt(30)=52.55;Member.Zt(30)=4.45;% 构件起点与终点坐标
Member.X0(31)=4.45;Member.Y0(31)=52.55;Member.Z0(31)=4.45;Member.Xt(31)=4;Member.Yt(31)=67;Member.Zt(31)=-4;% 构件起点与终点坐标
Member.X0(32)=4.45;Member.Y0(32)=52.55;Member.Z0(32)=-4.45;Member.Xt(32)=4;Member.Yt(32)=67;Member.Zt(32)=4;% 构件起点与终点坐标
% for j=1:Num_bar
%     [Member.X0(j),Member.Y0(j),Member.Z0(j)]=coordinate_trans(Member.X0(j),Member.Y0(j),Member.Z0(j),pesai);
%     [Member.Xt(j),Member.Yt(j),Member.Zt(j)]=coordinate_trans(Member.Xt(j),Member.Yt(j),Member.Zt(j),pesai);
% end
Member.D=[0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6];% 构件直径
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



