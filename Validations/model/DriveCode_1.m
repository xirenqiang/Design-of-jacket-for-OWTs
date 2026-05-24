%% Validation path setup
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(projectRoot);
addpath(fullfile(projectRoot, 'modules'));

clc;
clearvars;
projRoot = fullfile(projectRoot, 'Validations', 'model');
DriveCode = struct( ...
    'inputdataFile', fullfile(projRoot, 'inputdata.dat'), ...
    'elementsDat', fullfile(projRoot, 'jacket_elements.dat'), ...
    'nodesDat', fullfile(projRoot, 'node_coordinates.dat') ...
    );
% Optional: inp = readData(DriveCode.inputdataFile);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 模块说明：该段用于模型初始化或分步计算
% 模块说明：该段用于模型初始化或分步计算
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('执行当前步骤...\n');
k_weibull=11.75;% Weibull 形状参数
s_weibull=2.04;% Weibull 尺度参数
n_min=6.9;% 机组最小转速（rpm）
n_max=12.1;% 机组最大转速（rpm）
M_rna=350000;% 机舱与转子总质量（kg）
D_Tower_top=4;% 塔顶直径（m）
D_Tower_bottom=5.6;% 塔底直径（m）
m_t=261100;% 塔筒总质量（kg）
h_Tower=70;% 塔筒高度（m）
av=1.75;% 关键参数或中间量设置
Num_floor=4;% 导管架层数
Num_pile=4;% 桩腿数量
L_top=8;% 导管架顶部边长（m）
water_depth=50;% 水深（m）
Hs50=8.24;% 50 年一遇显著波高（m）
Hm50=15.33;% 50 年一遇波高（m）
steel_density=7850;% 钢材密度（kg/m^3）
E=2.1*10^11;% 弹性模量（Pa）
m_tower_eq=m_t/h_Tower;% 塔筒总质量（kg）
Mtp=666000;% 关键参数或中间量设置
MTower=h_Tower*3730;% 塔筒高度（m）
global debug;
debug=1;
fprintf('执行当前步骤...\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 模块说明：该段用于模型初始化或分步计算
% 模块说明：该段用于模型初始化或分步计算
% 模块说明：该段用于模型初始化或分步计算
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('执行当前步骤...\n');
% 模块说明：该段用于模型初始化或分步计算
global Member;% 构件全局变量
% 模块说明：该段用于模型初始化或分步计算
Zplatform=water_depth+Hm50+0.2*Hs50;% 水深（m）
h_Jacket=ceil(Zplatform);% 平台高程估计值
L_bottom=L_top+2*h_Jacket*tand(av);% 导管架顶部边长（m）
m=(L_bottom/L_top)^(1/Num_floor);% 导管架层数
h1=h_Jacket*((m-1)/(m^Num_floor-1));% 导管架层数
l1=m*L_top;% 导管架顶部边长（m）
sitah=atan(h1/(l1-h1*tand(av)));% 关键参数或中间量设置
% 模块说明：该段用于模型初始化或分步计算
if Num_floor==3
    disp('提示：按当前配置继续执行。');
    [h2, h3, l2, l3]=height_wd_jac_floor_3f(Num_floor, h1, l1, m);
    if (l3-L_bottom>0.05)
        error('参数配置不满足当前分支约束，请检查输入。');
    end
elseif Num_floor==4
    disp('提示：按当前配置继续执行。');
    [h2, h3, h4, l2, l3, l4]=height_wd_jac_floor_4f(Num_floor, h1, l1, m);
    if (l4-L_bottom>0.05)
        error('参数配置不满足当前分支约束，请检查输入。');
    end
else
    disp('提示：按当前配置继续执行。');
    error('参数配置不满足当前分支约束，请检查输入。');
end
% 模块说明：该段用于模型初始化或分步计算
Num_bar=Bar_num_determine(Num_floor, Num_pile);% 导管架层数
if Num_floor==3
    disp('提示：按当前配置继续执行。');
    Geometry_jacket_3f(Num_floor, L_bottom, L_top, h_Jacket, h1, m);
elseif Num_floor==4
    disp('提示：按当前配置继续执行。');
    Geometry_jacket_4f(Num_floor, L_bottom, L_top, h_Jacket, h1, m);
else
    disp('提示：按当前配置继续执行。');
    error('参数配置不满足当前分支约束，请检查输入。');
end
fprintf('执行当前步骤...\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 模块说明：该段用于模型初始化或分步计算
% 模块说明：该段用于模型初始化或分步计算
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('执行当前步骤...\n');
f_3p_min=3*n_min*2*3.14/60*0.9/(2*3.14);
f_1p_max=n_max*2*3.14/60*1.1/(2*3.14);
f_fb_target=1/2*(f_1p_max+f_3p_min);% 关键参数或中间量设置
fprintf('计算结果: %g
',f_fb_target);
m_JT_eq=m_tower_eq;% 关键参数或中间量设置
fai=h_Jacket/h_Tower;% 塔筒高度（m）
Dt_Tower=(D_Tower_top+D_Tower_bottom)/2;% 塔顶直径（m）
t_tower=(m_t/(steel_density*pi*h_Tower*Dt_Tower));% 塔筒总质量（kg）
h_total=h_Jacket+h_Tower;% 塔筒高度（m）
I_Tower_top=(pi*(D_Tower_top^3)*t_tower)/8;% 塔顶直径（m）
q=D_Tower_bottom/D_Tower_top;% 塔顶直径（m）
fq=((2*q^2*(q-1)^3)/(q^2*(2*log(q)-3)+4*q-1))/3;
EI_tower=E*I_Tower_top*fq;% 弹性模量（Pa）
EI_tj_target=(((f_fb_target*2*pi)^2)*((0.243*m_JT_eq*h_total+M_rna)*(h_total)^3))/3;% 机舱与转子总质量（kg）
kai=(1/(EI_tj_target/(((h_Jacket+h_Tower)/h_Tower)^3*EI_tower))-1)/((1+fai)^3-1);% 塔筒高度（m）
EI_Jacket=EI_tower/kai;% 关键参数或中间量设置
m_BtoT=L_bottom/L_top;% 导管架顶部边长（m）
fm1=m_BtoT*(m_BtoT-1)^3/(m_BtoT^2-2*m_BtoT*log(m_BtoT)-1)/3;
Itopj=EI_Jacket/(fm1*E);% 弹性模量（Pa）
Aleg=Itopj/(L_top)^2;% 导管架顶部边长（m）
Abrace=0.2*Aleg;% 关键参数或中间量设置
D_leg_ini=4*Aleg/(3.14*(1-23^2/25^2));% 关键参数或中间量设置
t_leg_ini=D_leg_ini/25;
fprintf('计算结果: %g, %g
',D_leg_ini,t_leg_ini);
prompt='请输入参数值: ';
D_leg=input(prompt);
prompt='请输入参数值: ';
t_leg=input(prompt);
D_brace_ini=0.4*D_leg_ini;
t_brace_ini=Abrace/(3.14*D_brace_ini);
fprintf('计算结果: %g, %g
',D_brace_ini,t_brace_ini);
prompt='请输入参数值: ';
D_brace=input(prompt);
prompt='请输入参数值: ';
t_brace=input(prompt);
LegidPfloor=set_leg_ID_per_floor(Num_floor, Num_pile);
BraceidPfloor=set_brace_ID_per_floor(Num_floor, Num_pile);
% 模块说明：该段用于模型初始化或分步计算
checkbarnumber(Num_bar, LegidPfloor, BraceidPfloor);
% 模块说明：该段用于模型初始化或分步计算
[Member.D, Member.t]=Diameter_thickness_ini(LegidPfloor, BraceidPfloor, D_leg, D_brace, t_leg, t_brace);
fprintf('执行当前步骤...\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 模块说明：该段用于模型初始化或分步计算
% 模块说明：该段用于模型初始化或分步计算
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 模块说明：该段用于模型初始化或分步计算
fprintf('执行当前步骤...\n');
U_r=11.4;% 关键参数或中间量设置
Ar=12469;% 关键参数或中间量设置
air_density=1.225;% 关键参数或中间量设置
Lk=340.2;% 关键参数或中间量设置
Ct=3.5*(2*U_r+3.5)/U_r^2;% 关键参数或中间量设置
f1p_max=n_max/60;% 机组最大转速（rpm）
c=2;% 关键参数或中间量设置
I_ref=0.18;% 关键参数或中间量设置
sigmau_etm=c*I_ref*(0.072*(U_r/c+3)*(U_r/c-4)+10);% 关键参数或中间量设置
sigmau_etmfdayu1p=sigmau_etm*sqrt(1/(((6*Lk*f1p_max)/U_r+1)^(2/3)));% 关键参数或中间量设置
u_etm=2*sigmau_etmfdayu1p;% 关键参数或中间量设置
F_etm=air_density*Ar*Ct*(U_r+u_etm)^2/2;% 关键参数或中间量设置
% 模块说明：该段用于模型初始化或分步计算
% 模块说明：该段用于模型初始化或分步计算
D_rotor=sqrt(4*Ar/pi);% 关键参数或中间量设置
U10_50year=(-log(1-0.98^(1/52596)))^(1/s_weibull)*k_weibull;
U10_1year=0.8*U10_50year;
% U10_50year=40.2;
% U10_1year=30;
sigma_Uc=0.08*U10_50year;
u_eog=min(1.35*(U10_1year-U_r),3.33*sigma_Uc/(1+0.8*D_rotor/Lk));% 关键参数或中间量设置
F_eog=air_density*Ar*Ct*(U_r+u_eog)^2/2;% 关键参数或中间量设置
% 模块说明：该段用于模型初始化或分步计算
fprintf('执行当前步骤...\n');
% 模块说明：该段用于模型初始化或分步计算
fprintf('执行当前步骤...\n');
% 模块说明：该段用于模型初始化或分步计算
g=9.81;% 关键参数或中间量设置
Hs1=0.8*Hs50;% 50 年一遇显著波高（m）
Ts1=11.1*sqrt(Hs1/g);% 关键参数或中间量设置
N1=10800/(Ts1);
Hm1=Hs1*sqrt(log(N1)/2);% 关键参数或中间量设置
Tm1=11.1*sqrt(Hm1/g);% 关键参数或中间量设置
Tm50=11.1*sqrt(Hm50/g);% 50 年一遇波高（m）
DAF1=1/(sqrt((1-1/(Tm1*f_fb_target)^2)^2+(2*0.05*1/(Tm1*f_fb_target))));% 关键参数或中间量设置
DAF50=1/(sqrt((1-1/(Tm50*f_fb_target)^2)^2+(2*0.05*1/(Tm50*f_fb_target))));% 关键参数或中间量设置
% Hs2 (3rd wave for Hydro_load_1and50yrs); default 1.07 per inputdata.dat
Hs2=1.07;
Ts2=11.1*sqrt(Hs2/g);
N2=3600/(Ts2);
Hm2=Hs2*sqrt(log(N2)/2);
Tm2=11.1*sqrt(Hm2/g);
DAF2=1/(sqrt((1-1/(Tm2*f_fb_target)^2)^2+(2*0.05*1/(Tm2*f_fb_target))));
pesai=45;% 关键参数或中间量设置
global Hydro;
global Wave;
global Current;
global Discrete;
global dL_ele_target;
dL_ele_target=1.0;
Coord_trans_bar_discrete(pesai, Num_bar);
Num_total_element=0;
for i=1:Num_bar% 循环计算
    Num_total_element=Num_total_element+Discrete.Num_ele(i);
end
fprintf('计算结果: %g
',Num_total_element);
Hydro.density=1025;% 海水密度
% 模块说明：该段用于模型初始化或分步计算
Hydro.cd=1.0;% 阻力系数
Hydro.cm=2.0;% 惯性系数
Wave.S=50;% 水深
Current.U_ss0=0.6;
Current.U_ns0=0.6;
Current.h_ref=20;
t0=0;
t1=100;
dt=0.1;
% 模块说明：该段用于模型初始化或分步计算
% 模块说明：该段用于模型初始化或分步计算
% 模块说明：该段用于模型初始化或分步计算
F_1y_all=zeros(Num_floor, 1);% 导管架层数
M_1y_all=zeros(Num_floor, 1);
F_50y_all=zeros(Num_floor, 1);% 导管架层数
M_50y_all=zeros(Num_floor, 1);
% 模块说明：该段用于模型初始化或分步计算
Y0_position=zeros(Num_floor,1);
Width=zeros(Num_floor,1);
for i = 1:Num_floor
    Num_bar_array = get_bar_array_for_floor(i, LegidPfloor, BraceidPfloor);% 关键参数或中间量设置
    if Num_floor==4
        disp('提示：按当前配置继续执行。');
        Y0_position(i)=get_center_hydro_load_for_floor_4f(h2, h3, h4, i);% 关键参数或中间量设置
        Width(i)= get_width_of_floor_4f(i,l1,l2,l3,l4);
    elseif Num_floor==3
        disp('提示：按当前配置继续执行。');
        Y0_position(i)=get_center_hydro_load_for_floor_3f(h2, h3, i);
        Width(i)= get_width_of_floor_3f(i,l1,l2,l3);
    else
        disp('提示：按当前配置继续执行。');
        error('参数配置不满足当前分支约束，请检查输入。');
    end
% 模块说明：该段用于模型初始化或分步计算
    M_etm=Moment_Jac_wind(F_etm,h_Tower,h_Jacket,Y0_position(i));% 塔筒高度（m）
    M_eog=Moment_Jac_wind(F_eog,h_Tower,h_Jacket,Y0_position(i));% 塔筒高度（m）
% 模块说明：该段用于模型初始化或分步计算
    Wave.T=Tm1;% 波浪周期
    Wave.h=Hm1;% 波高
    Wave.k=wave_number(Wave.T, Wave.h);% 波浪周期
    [Ftx_1y, Fty_1y, Ftz_1y, Mtx_1y, Mtz_1y,t]=Hydro_load_timehistory(t0, t1, dt, Num_bar_array, Y0_position(i));
    if numel(Ftx_1y)~=numel(t)
        error('参数配置不满足当前分支约束，请检查输入。');
    end
    [Ftx_1y_max, Fty_1y_max, Ftz_1y_max, Mtx_1y_max, Mtz_1y_max]=Hydro_load_max(Ftx_1y, Fty_1y, Ftz_1y, Mtx_1y, Mtz_1y);
% 模块说明：该段用于模型初始化或分步计算
    F_1y_all(i)=DAF1*Ftx_1y_max;
    M_1y_all(i)=DAF1*Mtz_1y_max;
% 模块说明：该段用于模型初始化或分步计算
    Wave.T=Tm50;% 波浪周期
    Wave.h=Hm50;% 50 年一遇波高（m）
    Wave.k=wave_number(Wave.T,Wave.h);% 波浪周期
    [Ftx_50y, Fty_50y, Ftz_50y, Mtx_50y, Mtz_50y,t] = Hydro_load_timehistory(t0, t1, dt, Num_bar_array, Y0_position(i));
    if numel(Ftx_50y)~=numel(t)
        error('参数配置不满足当前分支约束，请检查输入。');
    end
    [Ftx_50y_max, Fty_50y_max, Ftz_50y_max, Mtx_50y_max, Mtz_50y_max] = Hydro_load_max(Ftx_50y, Fty_50y, Ftz_50y, Mtx_50y, Mtz_50y);
% 模块说明：该段用于模型初始化或分步计算
    F_50y_all(i)=DAF50*Ftx_50y_max;
    M_50y_all(i)=DAF50*Mtz_50y_max;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 模块说明：该段用于模型初始化或分步计算
% 模块说明：该段用于模型初始化或分步计算
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('执行当前步骤...\n');
% 模块说明：该段用于模型初始化或分步计算
    leg_id_i_floor=LegidPfloor(i,1);
    L_leg=Member.L(leg_id_i_floor);% 构件长度
    D_leg=Member.D(leg_id_i_floor);
    t_leg=Member.t(leg_id_i_floor);
    k_leg=1.0;% 关键参数或中间量设置
    A_leg=1/4*3.14*(D_leg^2-(D_leg-2*t_leg)^2);
    I_leg=1/64*3.14*(D_leg^4-(D_leg-2*t_leg)^4);
    ir_leg=sqrt(I_leg/A_leg);
	F_allowable_leg=sigma_allowable(k_leg, L_leg, ir_leg, A_leg);% 关键参数或中间量设置
% 模块说明：该段用于模型初始化或分步计算
    brace_id_i_floor=BraceidPfloor(i,1);
    L_brace=Member.L(brace_id_i_floor);% 构件长度
    D_brace=Member.D(brace_id_i_floor);
    t_brace=Member.t(brace_id_i_floor);
    k_brace=0.8;% 关键参数或中间量设置
    A_brace=1/4*3.14*(D_brace^2-(D_brace-2*t_brace)^2);
    I_brace=1/64*3.14*(D_brace^4-(D_brace-2*t_brace)^4);
    ir_brace=sqrt(I_brace/A_brace);
    F_allowable_brace=sigma_allowable(k_brace, L_brace, ir_brace, A_brace);% 关键参数或中间量设置
    fprintf('执行当前步骤...\n');
% 模块说明：该段用于模型初始化或分步计算
    W_jk=Weight_jacket(Num_bar_array,steel_density,Hydro.density,Y0_position(i));
    Wnet=W_jk+(Mtp+MTower+M_rna)*g;% 机舱与转子总质量（kg）
    [F1,M1,F50,M50,~,~]=Hydro_load_1and50yrs(Hm2, Tm2, DAF2, Hm50, Tm50, DAF50, Hm1, Tm1, DAF1, t0, t1, dt, Num_bar_array, Y0_position(i));
    M=1.3*max(M_etm+M50,M_eog+M1);% 关键参数或中间量设置
    V1=(1/Width(i))*(M/sqrt(2))+1.3*Wnet/4;% 关键参数或中间量设置
    fprintf('计算结果: %g
',V1);
    fprintf('计算结果: %g
',F_allowable_leg);
    if i==Num_floor
        V4=(1/L_bottom)*(M/sqrt(2))-0.9*Wnet/4;% 导管架底部边长
    end
    label_bar='leg';
    fprintf('计算结果: %g
',label_bar);
    if V1<=F_allowable_leg
        count=0;
        fprintf('计算结果: %g
',label_bar);
    else
        fprintf('计算结果: %g, %g
',label_bar,label_bar);
        count=0;
        while V1>F_allowable_leg% 关键参数或中间量设置
            count=count+1;
            D_leg=D_leg+0.2;% 关键参数或中间量设置
            t_leg=D_leg/20;
            %         k_factor_leg=sqrt(abs(V1)/abs(F_allowable_leg));
% 模块说明：该段用于模型初始化或分步计算
% 模块说明：该段用于模型初始化或分步计算
% 模块说明：该段用于模型初始化或分步计算
            %         t_leg=ceil(1.2*t_leg*100)/100;
% 模块说明：该段用于模型初始化或分步计算
            % t_leg=ceil(V1/F_allowable_leg*t_leg*100)/100;
            %         t_leg=ceil((t_leg*k_factor_leg*1000)/5)*5/1000;
            A_leg=1/4*3.14*(D_leg^2-(D_leg-2*t_leg)^2);
            I_leg=1/64*3.14*(D_leg^4-(D_leg-2*t_leg)^4);
            ir_leg=sqrt(I_leg/A_leg);
            F_allowable_leg=sigma_allowable(k_leg,L_leg,ir_leg,A_leg);% 关键参数或中间量设置
            Diameter_thickness_update(i,LegidPfloor, BraceidPfloor, D_leg, D_brace, t_leg, t_brace);
            [F1,M1,F50,M50,~,~]=Hydro_load_1and50yrs(Hm2, Tm2, DAF2, Hm50, Tm50, DAF50, Hm1, Tm1, DAF1, t0, t1, dt, Num_bar_array, Y0_position(i));
            fprintf('计算结果: %g, %g
',count,M1);
            fprintf('计算结果: %g, %g
',count,M50);
            M=1.3*max(M50+M_etm, M1+M_eog);% 关键参数或中间量设置
            W_jk=Weight_jacket(Num_bar_array,steel_density, Hydro.density,Y0_position(i));
            Wnet=W_jk+(Mtp+MTower+M_rna)*g;% 机舱与转子总质量（kg）
            V1=(1/L_bottom)*(M/sqrt(2))+1.3*Wnet/4;% 导管架底部边长
        end
        fprintf('计算结果: %g, %g
',count,label_bar);
    end
    H=1.3*max((F_etm+F50)/4,(F_eog+F1)/4);% 关键参数或中间量设置
    Fb=H/cos(sitah);% 关键参数或中间量设置
    label_bar='brace';
    fprintf('计算结果: %g
',label_bar);
    if Fb<=F_allowable_brace
        count=0;
        fprintf('计算结果: %g
',label_bar);
    else
        fprintf('计算结果: %g, %g
',label_bar,label_bar);
        count=0;
        while Fb>=F_allowable_brace
            count=count+1;
            D_brace=D_brace+0.2;
            t_brace=D_brace/20;
            %         k_factor_b=sqrt(abs(Fb)/abs(F_allowable_brace));
            %         D_brace=ceil(D_brace*k_factor_b*10)/10;
            %         t_brace=ceil(t_brace*k_factor_b*1000/5)*5/1000;
            A_brace=1/4*3.14*(D_brace^2-(D_brace-2*t_brace)^2);
            I_brace=1/64*3.14*(D_brace^4-(D_brace-2*t_brace)^4);
            ir_brace=sqrt(I_brace/A_brace);
            F_allowable_brace=sigma_allowable(k_brace, L_brace, ir_brace, A_brace);% 关键参数或中间量设置
            Diameter_thickness_update(i,LegidPfloor, BraceidPfloor, D_leg, D_brace, t_leg, t_brace);
            [F1,M1,F50,M50,~,~]=Hydro_load_1and50yrs(Hm2, Tm2, DAF2, Hm50, Tm50, DAF50, Hm1, Tm1, DAF1, t0, t1, dt, Num_bar_array, Y0_position(i));
            fprintf('计算结果: %g, %g
',count,M1);
            fprintf('计算结果: %g, %g
',count,M50);
            H=1.3*max((F_etm+F50)/4,(F_eog+F1)/4);% 关键参数或中间量设置
            Fb=H/cos(sitah);% 关键参数或中间量设置
        end
        fprintf('计算结果: %g, %g
',count,label_bar);
    end
    fprintf('计算结果: %g
',i);
    A_leg=1/4*3.14*(D_leg^2-(D_leg-2*t_leg)^2);
    I_leg=1/64*3.14*(D_leg^4-(D_leg-2*t_leg)^4);
    ir_leg=sqrt(I_leg/A_leg);
    A_brace=1/4*3.14*(D_brace^2-(D_brace-2*t_brace)^2);
    I_brace=1/64*3.14*(D_brace^4-(D_brace-2*t_brace)^4);
    ir_brace=sqrt(I_brace/A_brace);
    F_allowable_leg=sigma_allowable(k_leg,L_leg,ir_leg,A_leg);% 关键参数或中间量设置
    F_allowable_brace=sigma_allowable(k_brace, L_brace, ir_brace, A_brace);% 关键参数或中间量设置
    [F1,M1,F50,M50,~,~]=Hydro_load_1and50yrs(Hm2, Tm2, DAF2, Hm50, Tm50, DAF50, Hm1, Tm1, DAF1, t0, t1, dt, Num_bar_array, Y0_position(i));
    fprintf('计算结果: %g, %g
',count,M1);
    fprintf('计算结果: %g, %g
',count,M50);
    M=1.3*max(M50+M_etm, M1+M_eog);% 关键参数或中间量设置
    W_jk=Weight_jacket(Num_bar_array,steel_density, Hydro.density,Y0_position(i));
    Wnet=W_jk+(Mtp+MTower+M_rna)*g;% 机舱与转子总质量（kg）
    V1=(1/L_bottom)*(M/sqrt(2))+1.3*Wnet/4;% 导管架底部边长
    H=1.3*max((F_etm+F50)/4,(F_eog+F1)/4);% 关键参数或中间量设置
    Fb=H/cos(sitah);% 关键参数或中间量设置
    if F_allowable_leg>V1
        fprintf('计算结果: %g
',i);
    end
    if F_allowable_brace>Fb
        fprintf('计算结果: %g
',i);
    end
end% 关键参数或中间量设置
fprintf('执行当前步骤...\n');
fprintf('执行当前步骤...\n');
fprintf('计算结果输出
',D_leg,t_leg,D_brace,t_brace);
fprintf('执行当前步骤...\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 模块说明：该段用于模型初始化或分步计算
% 模块说明：该段用于模型初始化或分步计算
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('执行当前步骤...\n');
L_pile=50;% 关键参数或中间量设置
% 模块说明：该段用于模型初始化或分步计算
wgh_soil=10.0e3;
fs_limit=95.7e3;
interface_angle=29;
K0=1.0;
D_pile=Diameter_pile(V4,L_pile,wgh_soil,fs_limit,interface_angle,K0);
t_pile=D_pile*1000/100+6.35;
t_pile=ceil(t_pile)/1000;
fprintf('计算结果: %g, %g, %g
',L_pile,D_pile,t_pile);
fprintf('执行当前步骤...\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 模块说明：该段用于模型初始化或分步计算
% 模块说明：该段用于模型初始化或分步计算
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('执行当前步骤...\n');
% 模块说明：该段用于模型初始化或分步计算
% 模块说明：该段用于模型初始化或分步计算
I_J_top=A_leg*L_top^2;
mm=L_bottom/L_top;
f_m=1/3*mm*(mm-1)^3/(mm^2-2*mm*log(mm)-1);
EI_Jacket=E*I_J_top*f_m;
% 模块说明：该段用于模型初始化或分步计算
% 模块说明：该段用于模型初始化或分步计算
kai=EI_tower/EI_Jacket;
EI_JacketTower=EI_tower*(1/(1+(1+fai)^3*kai-kai))*((h_Jacket+h_Tower)/h_Tower)^3;
% 模块说明：该段用于模型初始化或分步计算
lamda1=1.8751;
beta1=-(cos(lamda1)+cosh(lamda1))/(sin(lamda1)+sinh(lamda1));
m_Jacket_eq=Distribute_mass_jacket(Num_bar,steel_density,h_Jacket);
m_JT_eq=(m_Jacket_eq*(intergral_mode_shape(h_Jacket,lamda1,h_Tower,h_Jacket)-intergral_mode_shape(0,lamda1,h_Tower,h_Jacket))+m_tower_eq*(intergral_mode_shape(h_Jacket+h_Tower,lamda1,h_Tower,h_Jacket)-intergral_mode_shape(h_Jacket,lamda1,h_Tower,h_Jacket)))/(intergral_mode_shape(h_Jacket+h_Tower,lamda1,h_Tower,h_Jacket)-intergral_mode_shape(0,lamda1,h_Tower,h_Jacket));
% 模块说明：该段用于模型初始化或分步计算
f_fb=1/(2*3.14)*sqrt(3*EI_JacketTower/((0.243*m_JT_eq*h_total+M_rna)*(h_total)^3));
% 模块说明：该段用于模型初始化或分步计算
Gs=15e6;
kexi=4;
k_pile=2*3.14*L_pile*Gs/kexi;
K_v=2*k_pile;
alpha=1;
K_R=K_v*L_bottom^2*(1/(1+alpha));
tao=K_R*h_total/EI_JacketTower;
C_J=sqrt(tao/(tao+3));
f_0=C_J*f_fb;
fprintf('计算结果: %g
',f_0);
fprintf('执行当前步骤...\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 模块说明：该段用于模型初始化或分步计算
% 模块说明：该段用于模型初始化或分步计算
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 模块说明：该段用于模型初始化或分步计算
fprintf('执行当前步骤...\n');
factor1=1.30;
Gs1=Gs*factor1;
k_pile1=2*3.14*L_pile*Gs1/kexi;
K_v1=2*k_pile1;
K_R1=K_v1*L_bottom^2*(1/(1+alpha));
tao1=K_R1*h_total/EI_JacketTower;
C_J1=sqrt(tao1/(tao1+3));
f_0_1=C_J1*f_fb;
fprintf('计算结果: %g, %g
',factor1,f_0_1);
% 模块说明：该段用于模型初始化或分步计算
factor2=0.7;
Gs2=Gs*factor2;
k_pile2=2*3.14*L_pile*Gs2/kexi;
K_v2=2*k_pile2;
K_R2=K_v2*L_bottom^2*(1/(1+alpha));
tao2=K_R2*h_total/EI_JacketTower;
C_J2=sqrt(tao2/(tao2+3));
f_0_2=C_J2*f_fb;
fprintf('计算结果: %g, %g
',factor2,f_0_2);
fprintf('执行当前步骤...\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 模块说明：该段用于模型初始化或分步计算
% 模块说明：该段用于模型初始化或分步计算
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('执行当前步骤...\n');
% Current.U_ss0=0.0;
% Current.U_ns0=0.0;
Wave.T=Tm1;% 波浪周期
Wave.h=Hm1;% 波高
Wave.k=wave_number(Wave.T,Wave.h);% 波浪周期
Num_bar_array_uls=get_bar_array_for_floor(Num_floor,LegidPfloor,BraceidPfloor);
y0_uls=Y0_position(Num_floor);
[Ftx_1y_wav,Fty_1y_wav,Ftz_1y_wav,Mtx_1y_wav,Mtz_1y_wav,t]=Hydro_load_timehistory(t0,t1,dt,Num_bar_array_uls,y0_uls);
[Ftx_1y_wav_max,Fty_1y_wav_max,Ftz_1y_wav_max,Mtx_1y_wav_max,Mtz_1y_wav_max]=Hydro_load_max(Ftx_1y_wav,Fty_1y_wav,Ftz_1y_wav,Mtx_1y_wav,Mtz_1y_wav);
F1_wav=Ftx_1y_wav_max;
M1_wav=Mtz_1y_wav_max;
a=h_total-M1_wav/F1_wav;
delt_wave=F1_wav*h_total*(h_total-a)/K_R+F1_wav/EI_Jacket*((h_total-a)^3/3-a*(h_total-a)^2/2);
sigmau_ntm=I_ref*(0.75*U_r+5.6);% 关键参数或中间量设置
sigmau_ntmfdayu1p=sigmau_ntm*sqrt(1/(((6*Lk*f1p_max)/U_r+1)^(2/3)));% 关键参数或中间量设置
u_ntm=1.28*sigmau_ntmfdayu1p;% 关键参数或中间量设置
F_ntm=air_density*Ar*Ct*(U_r+u_ntm)^2/2;% 关键参数或中间量设置
delt_wind=F_ntm*h_total^2/K_R+F_ntm*h_total^3/(3*EI_JacketTower);
delt_towertop=delt_wind+delt_wave;
fprintf('计算结果: %g
',delt_towertop);
fprintf('执行当前步骤...\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 模块说明：该段用于模型初始化或分步计算
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('执行当前步骤...\n');
member_export(DriveCode.elementsDat, Num_bar, water_depth);
node_export(DriveCode.nodesDat, Num_bar, water_depth);
cord_Cal(Num_bar);
fprintf('执行当前步骤...\n');

