%% Validation path setup
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(projectRoot);
addpath(fullfile(projectRoot, 'modules'));

clc;
clearvars;
% 模块说明：该段用于模型初始化或分步计算
pesai=0;% 关键参数或中间量设置
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
Num_bar=52;
% 模块说明：该段用于模型初始化或分步计算
Member.X0(1)=6;Member.Y0(1)=0;Member.Z0(1)=6;Member.Xt(1)=4;Member.Yt(1)=67;Member.Zt(1)=4;% 构件起点与终点坐标
Member.X0(2)=6;Member.Y0(2)=0;Member.Z0(2)=-6;Member.Xt(2)=4;Member.Yt(2)=67;Member.Zt(2)=-4;% 构件起点与终点坐标
Member.X0(3)=-6;Member.Y0(3)=0;Member.Z0(3)=-6;Member.Xt(3)=-4;Member.Yt(3)=67;Member.Zt(3)=-4;% 构件起点与终点坐标
Member.X0(4)=-6;Member.Y0(4)=0;Member.Z0(4)=6;Member.Xt(4)=-4;Member.Yt(4)=67;Member.Zt(4)=4;% 构件起点与终点坐标
% 模块说明：该段用于模型初始化或分步计算
Member.X0(5)=-6;Member.Y0(5)=0;Member.Z0(5)=6;Member.Xt(5)=6;Member.Yt(5)=0;Member.Zt(5)=6;% 构件起点与终点坐标
Member.X0(6)=6;Member.Y0(6)=0;Member.Z0(6)=6;Member.Xt(6)=6;Member.Yt(6)=0;Member.Zt(6)=-6;% 构件起点与终点坐标
Member.X0(7)=6;Member.Y0(7)=0;Member.Z0(7)=-6;Member.Xt(7)=-6;Member.Yt(7)=0;Member.Zt(7)=-6;% 构件起点与终点坐标
Member.X0(8)=-6;Member.Y0(8)=0;Member.Z0(8)=-6;Member.Xt(8)=-6;Member.Yt(8)=0;Member.Zt(8)=6;% 构件起点与终点坐标
Member.X0(9)=-5.45;Member.Y0(9)=19.25;Member.Z0(9)=5.45;Member.Xt(9)=5.45;Member.Yt(9)=19.25;Member.Zt(9)=5.45;% 构件起点与终点坐标
Member.X0(10)=5.45;Member.Y0(10)=19.25;Member.Z0(10)=5.45;Member.Xt(10)=5.45;Member.Yt(10)=19.25;Member.Zt(10)=-5.45;% 构件起点与终点坐标
Member.X0(11)=5.45;Member.Y0(11)=19.25;Member.Z0(11)=-5.45;Member.Xt(11)=-5.45;Member.Yt(11)=19.25;Member.Zt(11)=-5.45;% 构件起点与终点坐标
Member.X0(12)=-5.45;Member.Y0(12)=19.25;Member.Z0(12)=-5.45;Member.Xt(12)=-5.45;Member.Yt(12)=19.25;Member.Zt(12)=5.45;% 构件起点与终点坐标
Member.X0(13)=-4.95;Member.Y0(13)=36.75;Member.Z0(13)=4.95;Member.Xt(13)=4.95;Member.Yt(13)=36.75;Member.Zt(13)=4.95;% 构件起点与终点坐标
Member.X0(14)=4.95;Member.Y0(14)=36.75;Member.Z0(14)=4.95;Member.Xt(14)=4.95;Member.Yt(14)=36.75;Member.Zt(14)=-4.95;% 构件起点与终点坐标
Member.X0(15)=4.95;Member.Y0(15)=36.75;Member.Z0(15)=-4.95;Member.Xt(15)=-4.95;Member.Yt(15)=36.75;Member.Zt(15)=-4.95;% 构件起点与终点坐标
Member.X0(16)=-4.95;Member.Y0(16)=36.75;Member.Z0(16)=-4.95;Member.Xt(16)=-4.95;Member.Yt(16)=36.75;Member.Zt(16)=4.95;% 构件起点与终点坐标
Member.X0(17)=-4.45;Member.Y0(17)=52.55;Member.Z0(17)=4.45;Member.Xt(17)=4.45;Member.Yt(17)=52.55;Member.Zt(17)=4.45;% 构件起点与终点坐标
Member.X0(18)=4.45;Member.Y0(18)=52.55;Member.Z0(18)=4.45;Member.Xt(18)=4.45;Member.Yt(18)=52.55;Member.Zt(18)=-4.45;% 构件起点与终点坐标
Member.X0(19)=4.45;Member.Y0(19)=52.55;Member.Z0(19)=-4.45;Member.Xt(19)=-4.45;Member.Yt(19)=52.55;Member.Zt(19)=-4.45;% 构件起点与终点坐标
Member.X0(20)=-4.45;Member.Y0(20)=52.55;Member.Z0(20)=-4.45;Member.Xt(20)=-4.45;Member.Yt(20)=52.55;Member.Zt(20)=4.45;% 构件起点与终点坐标
% 模块说明：该段用于模型初始化或分步计算
Member.X0(21)=-6;Member.Y0(21)=0;Member.Z0(21)=6;Member.Xt(21)=5.45;Member.Yt(21)=19.25;Member.Zt(21)=5.45;% 构件起点与终点坐标
Member.X0(22)=6;Member.Y0(22)=0;Member.Z0(22)=6;Member.Xt(22)=-5.45;Member.Yt(22)=19.25;Member.Zt(22)=5.45;% 构件起点与终点坐标
Member.X0(23)=-5.45;Member.Y0(23)=19.25;Member.Z0(23)=5.45;Member.Xt(23)=4.95;Member.Yt(23)=36.75;Member.Zt(23)=4.95;% 构件起点与终点坐标
Member.X0(24)=5.45;Member.Y0(24)=19.25;Member.Z0(24)=5.45;Member.Xt(24)=-4.95;Member.Yt(24)=36.75;Member.Zt(24)=4.95;% 构件起点与终点坐标
Member.X0(25)=-4.95;Member.Y0(25)=36.75;Member.Z0(25)=4.95;Member.Xt(25)=4.45;Member.Yt(25)=52.55;Member.Zt(25)=4.45;% 构件起点与终点坐标
Member.X0(26)=4.95;Member.Y0(26)=36.75;Member.Z0(26)=4.95;Member.Xt(26)=-4.45;Member.Yt(26)=52.55;Member.Zt(26)=4.45;% 构件起点与终点坐标
Member.X0(27)=-4.45;Member.Y0(27)=52.55;Member.Z0(27)=4.45;Member.Xt(27)=4;Member.Yt(27)=67;Member.Zt(27)=4;% 构件起点与终点坐标
Member.X0(28)=4.45;Member.Y0(28)=52.55;Member.Z0(28)=4.45;Member.Xt(28)=-4;Member.Yt(28)=67;Member.Zt(28)=4;% 构件起点与终点坐标
Member.X0(29)=-6;Member.Y0(29)=0;Member.Z0(29)=-6;Member.Xt(29)=5.45;Member.Yt(29)=19.25;Member.Zt(29)=-5.45;% 构件起点与终点坐标
Member.X0(30)=6;Member.Y0(30)=0;Member.Z0(30)=-6;Member.Xt(30)=-5.45;Member.Yt(30)=19.25;Member.Zt(30)=-5.45;% 构件起点与终点坐标
Member.X0(31)=-5.45;Member.Y0(31)=19.25;Member.Z0(31)=-5.45;Member.Xt(31)=4.95;Member.Yt(31)=36.75;Member.Zt(31)=-4.95;% 构件起点与终点坐标
Member.X0(32)=5.45;Member.Y0(32)=19.25;Member.Z0(32)=-5.45;Member.Xt(32)=-4.95;Member.Yt(32)=36.75;Member.Zt(32)=-4.95;% 构件起点与终点坐标
Member.X0(33)=-4.95;Member.Y0(33)=36.75;Member.Z0(33)=-4.95;Member.Xt(33)=4.45;Member.Yt(33)=52.55;Member.Zt(33)=-4.45;% 构件起点与终点坐标
Member.X0(34)=4.95;Member.Y0(34)=36.75;Member.Z0(34)=-4.95;Member.Xt(34)=-4.45;Member.Yt(34)=52.55;Member.Zt(34)=-4.45;% 构件起点与终点坐标
Member.X0(35)=-4.45;Member.Y0(35)=52.55;Member.Z0(35)=-4.45;Member.Xt(35)=4;Member.Yt(35)=67;Member.Zt(35)=-4;% 构件起点与终点坐标
Member.X0(36)=4.45;Member.Y0(36)=52.55;Member.Z0(36)=-4.45;Member.Xt(36)=-4;Member.Yt(36)=67;Member.Zt(36)=-4;% 构件起点与终点坐标
Member.X0(37)=-6;Member.Y0(37)=0;Member.Z0(37)=6;Member.Xt(37)=-5.45;Member.Yt(37)=19.25;Member.Zt(37)=-5.45;% 构件起点与终点坐标
Member.X0(38)=-6;Member.Y0(38)=0;Member.Z0(38)=-6;Member.Xt(38)=-5.45;Member.Yt(38)=19.25;Member.Zt(38)=5.45;% 构件起点与终点坐标
Member.X0(39)=-5.45;Member.Y0(39)=19.25;Member.Z0(39)=5.45;Member.Xt(39)=-4.95;Member.Yt(39)=36.75;Member.Zt(39)=-4.95;% 构件起点与终点坐标
Member.X0(40)=-5.45;Member.Y0(40)=19.25;Member.Z0(40)=-5.45;Member.Xt(40)=-4.95;Member.Yt(40)=36.75;Member.Zt(40)=4.95;% 构件起点与终点坐标
Member.X0(41)=-4.95;Member.Y0(41)=36.75;Member.Z0(41)=4.95;Member.Xt(41)=-4.45;Member.Yt(41)=52.55;Member.Zt(41)=-4.45;% 构件起点与终点坐标
Member.X0(42)=-4.95;Member.Y0(42)=36.75;Member.Z0(42)=-4.95;Member.Xt(42)=-4.45;Member.Yt(42)=52.55;Member.Zt(42)=4.45;% 构件起点与终点坐标
Member.X0(43)=-4.45;Member.Y0(43)=52.55;Member.Z0(43)=4.45;Member.Xt(43)=-4;Member.Yt(43)=67;Member.Zt(43)=-4;% 构件起点与终点坐标
Member.X0(44)=-4.45;Member.Y0(44)=52.55;Member.Z0(44)=-4.45;Member.Xt(44)=-4;Member.Yt(44)=67;Member.Zt(44)=4;% 构件起点与终点坐标
Member.X0(45)=6;Member.Y0(45)=0;Member.Z0(45)=6;Member.Xt(45)=5.45;Member.Yt(45)=19.25;Member.Zt(45)=-5.45;% 构件起点与终点坐标
Member.X0(46)=6;Member.Y0(46)=0;Member.Z0(46)=-6;Member.Xt(46)=5.45;Member.Yt(46)=19.25;Member.Zt(46)=5.45;% 构件起点与终点坐标
Member.X0(47)=5.45;Member.Y0(47)=19.25;Member.Z0(47)=5.45;Member.Xt(47)=4.95;Member.Yt(47)=36.75;Member.Zt(47)=-4.95;% 构件起点与终点坐标
Member.X0(48)=5.45;Member.Y0(48)=19.25;Member.Z0(48)=-5.45;Member.Xt(48)=4.95;Member.Yt(48)=36.75;Member.Zt(48)=4.95;% 构件起点与终点坐标
Member.X0(49)=4.95;Member.Y0(49)=36.75;Member.Z0(49)=4.95;Member.Xt(49)=4.45;Member.Yt(49)=52.55;Member.Zt(49)=-4.45;% 构件起点与终点坐标
Member.X0(50)=4.95;Member.Y0(50)=36.75;Member.Z0(50)=-4.95;Member.Xt(50)=4.45;Member.Yt(50)=52.55;Member.Zt(50)=4.45;% 构件起点与终点坐标
Member.X0(51)=4.45;Member.Y0(51)=52.55;Member.Z0(51)=4.45;Member.Xt(51)=4;Member.Yt(51)=67;Member.Zt(51)=-4;% 构件起点与终点坐标
Member.X0(52)=4.45;Member.Y0(52)=52.55;Member.Z0(52)=-4.45;Member.Xt(52)=4;Member.Yt(52)=67;Member.Zt(52)=4;% 构件起点与终点坐标
Member.D=[1.2 1.2 1.2 1.2 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6];% 构件直径
for i=1:Num_bar
    [Member.X0(i),Member.Y0(i),Member.Z0(i)]=coordinate_trans(Member.X0(i),Member.Y0(i),Member.Z0(i),pesai);
    [Member.Xt(i),Member.Yt(i),Member.Zt(i)]=coordinate_trans(Member.Xt(i),Member.Yt(i),Member.Zt(i),pesai);
    Member.L(i)=Member_length(Member.X0(i),Member.Y0(i),Member.Z0(i),Member.Xt(i),Member.Yt(i),Member.Zt(i));
    Member.fai_y(i)=Member_fai_y(Member.X0(i),Member.Y0(i),Member.Z0(i),Member.Xt(i),Member.Yt(i),Member.Zt(i));
    [Member.cita_x(i)]=Member_cita_x(Member.X0(i),Member.Y0(i),Member.Z0(i),Member.Xt(i),Member.Yt(i),Member.Zt(i));
    [Member.cx(i),Member.cy(i),Member.cz(i)]=Direction_bar(Member.fai_y(i),Member.cita_x(i));
    [Discrete.Num_ele(i),Discrete.dL(i)]=Discrete_bar(Member.L(i), dL_ele_target);
end
Hydro.density=1025;% 海水密度
Hydro.cd=1.0;% 阻力系数
Hydro.cm=2.0;% 惯性系数
Wave.T=12.49;% 波浪周期
Wave.h=0;% 波高
Wave.S=50;% 水深
Wave.k=wave_number(Wave.T,Wave.S);% 波浪周期
Current.Vc=2;% 海流速度
t0=0;
t1=100;
dt=0.1;
Num_bar_array=1:Num_bar;
y0_position=Member.Y0(1);
[Ftx,Fty,Ftz,Mtx,Mtz,t]=Hydro_load_timehistory(t0,t1,dt,Num_bar_array,y0_position);
[Ftx_max,Fty_max,Ftz_max,Mtx_max,Mtz_max]=Hydro_load_max(Ftx,Fty,Ftz,Mtx,Mtz);
% Ftx_max=max(abs(Ftx));
% Fty_max=max(abs(Fty));
% Ftz_max=max(abs(Ftz));
% Mtx_max=max(abs(Mtx));
% Mtz_max=max(abs(Mtz));
plot(t,Ftx)
hold on
plot(t,Fty,'r')



