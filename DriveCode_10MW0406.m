 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 主程序: DriveCode_20250405.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear;
%% 读取数据并将相关变量初始化
% 输入文件名（请修改为实际的文件路径）
fileName = 'C:\Users\xirenqiang\Documents\MATLAB\jacket_design_10MW\inputdata.dat';
% 调用读取数据函数
dataStruct = readData(fileName);
% 提取需要的数据
global Hydro;
global Wave;
global Current;
%%初始化相关变量%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 风力发电机组整体参数
U_r = dataStruct.U_r;						% 轮毂高度处平均风速
Ar = dataStruct.Ar;							% 叶片扫掠面积
n_min = dataStruct.n_min;             		% Wind turbine minimum speed
n_max = dataStruct.n_max;             		% Wind turbine maximum speed
z_hub = dataStruct.z_hub;					% 风机轮毂高度
thru_coef_code = dataStruct.thrust_coef_code_pre;
Ct_out_user = dataStruct.Ct_out;
Ct_rated_user = dataStruct.Ct_rated;
% 塔筒相关参数
D_Tower_top = dataStruct.D_Tower_top; 		% Tower top diameter
D_Tower_bottom = dataStruct.D_Tower_bottom; % Tower bottom diameter
m_t = dataStruct.m_t;                 		% Total mass of tower
h_Tower = dataStruct.h_Tower;         		% Height of the tower
M_rna = dataStruct.M_rna;             		% Total mass of wind turbine engine compartment
% 导管架相关参数
av = dataStruct.av;                   		% Inclination angle of the main limb of the jacket
Num_floor = dataStruct.Num_floor;     		% Number of layers in the jacket
Num_pile = dataStruct.Num_pile;       		% 多桩导管架桩数
Mtp = dataStruct.Mtp;                 		% Conversion platform mass  
L_top = dataStruct.L_top;             		% Platform width on the jacket
h_jacket_code = dataStruct.h_jacket_code_predict;
h_jacket_user = dataStruct.h_jacket;
% 材料相关参数
steel_density = dataStruct.steel_density; 	% Steel density
E = dataStruct.E; 							% Young's modulus of tower material
g = dataStruct.gravity;
% 风速场相关参数
k_weibull = dataStruct.k_weibull;			% Weibull scale parameter
s_weibull = dataStruct.s_weibull;			% Weibull shape parameter
air_density = dataStruct.air_density; 		% 空气密度
Lk = dataStruct.Lk;                   		% 积分长度尺度
I_ref = dataStruct.I_ref;             		% Iref为U_r=11.4 m/s时的参考湍流强度
Lambda = dataStruct.Lambda;           		% 湍流尺度参数
U_ref = dataStruct.U_ref;             		% 1级风机的10分钟参考平均风速
% 波浪、海流相关参数
water_depth = dataStruct.water_depth; 		% Water depth
Hydro.density = dataStruct.water_density;   % 海水密度
Hydro.cd = dataStruct.cd;             		% 阻力系数
Hydro.cm = dataStruct.cm;             		% 惯性系数
Wave.S= dataStruct.water_depth;
Hs50 = dataStruct.Hs50;               		% 50-year characteristic wave height
Hm50 = dataStruct.Hm50;               		% 50-year extreme wave height
Hs2 = dataStruct.Hs2;                 		% 用户输入eog模式波高
Current.U_ss0 = dataStruct.U_ss0;     		% 稳态流速
Current.U_ns0 = dataStruct.U_ns0;     		% 非稳态流速
Current.h_ref = dataStruct.h_ref;     		% 参考高度
% 地基、基础相关参数
L_pile = dataStruct.L_pile;           		% 建议按照D_leg处理：prompt='请输入导管架Leg外直径初始值: D_leg = ';
wgh_soil = dataStruct.wgh_soil; 
fs_limit = dataStruct.fs_limit;
% 将已读取的数据输出到屏幕
disp('已加载的数据:');
disp(dataStruct);
fprintf('程序进入"Step 1: 输入计算参数"已完成;\n\n');
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 2: 确定导管架整体几何参数%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 本步骤依据设计经验，确定导管架整体几何参数;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('程序进入"Step 2: 确定导管架整体几何参数":\n');
% 定义全局变量Member
global Member;								%Struct类型变量，包含构件起点终点坐标，直径、壁厚
% 计算导管架部分整体几何参数：
% 计算单位长度塔筒质量
m_tower_eq = m_t / h_Tower;					% 单位长度塔筒质量
% 计算塔筒质量
MTower = h_Tower * m_tower_eq;				% 塔筒总质量
% 计算平台的Z坐标
Zplatform = water_depth + Hm50 + 0.2 * Hs50;	% 导管架总高度计算值
% 显示计算结果
fprintf('单位长度塔筒质量为: %.2f\n', m_tower_eq);
fprintf('塔筒总质量为: %.2f\n', MTower);
if h_jacket_code==1
    h_Jacket=ceil(Zplatform);                                   %平台总高度取值
    fprintf('导管架平台总高度使用软件预测值: %.2f\n', h_Jacket);
else
    h_Jacket=h_jacket_user;
    fprintf('导管架平台总高度使用用户自定义值: %.2f\n', h_Jacket);
end
L_bottom=L_top+sqrt(2)*h_Jacket*tand(av);                   %导管架泥线处宽带
m=(L_bottom/L_top)^(1/Num_floor);                           %比例系数,m＞1
h1=h_Jacket*((m-1)/(m^Num_floor-1));                        %第一层高度
l1=m*L_top;                                                 %第一层底部宽度
sitah=atan(sqrt(1+0.5*(tand(av)^2))/(L_top/h1-(sqrt(2)/2)*tand(av)));		%此处应采用tand函数，sitah为支撑的夹角；
% 根据层数，设定各层高度及宽度参数
if Num_floor==3
    disp('      本软件将用于设计3层导管架结构');
    [h2, h3, l2, l3]=height_wd_jac_floor_3f(Num_floor, h1, l1, m);
    if (l3-L_bottom>0.05)
        error('致命错误：导管架底部宽层计算误差过大，程序运行终止；请检查l3和bottom取值');
    end
elseif Num_floor==4
    disp('      本软件将用于设计4层导管架结构');
    [h2, h3, h4, l2, l3, l4]=height_wd_jac_floor_4f(Num_floor, h1, l1, m);
    if (l4-L_bottom>0.05)
        error('致命错误：导管架底部宽层计算误差过大，程序运行终止；请检查l4和bottom取值');
    end
else
    disp('      当前输入参数Num_floor发生致命错误');
    error('本软件适用于导管架层数为层3或4层');
end
%计算导管架的总杆件数量；
Num_bar=Bar_num_determine(Num_floor, Num_pile);                       %Num_bar为导管架总构件数量;
%确定导管架各构件两端节点坐标：
if Num_floor==3
    disp('      确定3层导管架结构各杆件起点和终点坐标');
    Geometry_jacket_3f(Num_floor, L_bottom, L_top, h_Jacket, h1, m);
elseif Num_floor==4
    disp('      确定4层导管架结构各杆件起点和终点坐标');
    Geometry_jacket_4f(Num_floor, L_bottom, L_top, h_Jacket, h1, m);
else
    disp('当前输入参数Num_floor发生致命错误');
    error('本软件仅适用于3层或4层四桩导管架结构初步设计');
end
fprintf('"Step 2: 确定导管架整体几何参数"已完成;\n\n');
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 3: 初始化导管架各构件截面尺寸%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 本步骤基于固有频率目标值，初步确定各杆件截面尺寸；
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('程序进入"Step 3: 初始化导管架各构件截面尺寸":\n');
% 确定目标频率
f_3p_min=3*n_min*2*3.14/60*0.9/(2*3.14);
f_1p_max=n_max*2*3.14/60*1.1/(2*3.14);
f_fb_target=(f_3p_min+f_1p_max)/2;							%支撑结构的目标频率;
fprintf('      系统基准频率目标值设定为:%fHz\n',f_fb_target);
m_JT_eq=m_tower_eq;                                         %m_JT_eq为导管架等效分布质量，初始值取为塔筒等效分布质量m_tower_eq，单位为kg/m
fai=h_Jacket/h_Tower;                                       %导管架与塔筒的高度之比
Dt_Tower=(D_Tower_top+D_Tower_bottom)/2;                    %塔筒的平均直径
t_tower=(m_t/(steel_density*pi*h_Tower*Dt_Tower));          %塔筒的等效壁厚
h_total=h_Jacket+h_Tower;                                   %支撑结构的总高度(导管架高度与塔筒高度之和)
I_Tower_top=(pi*(D_Tower_top^3)*t_tower)/8;                 %塔筒的转动惯量
q=D_Tower_bottom/D_Tower_top;                               %塔筒下上直径之比
fq=((2*q^2*(q-1)^3)/(q^2*(2*log(q)-3)+4*q-1))/3;
EI_tower=E*I_Tower_top*fq;                                  %塔筒的等效刚度
EI_tj_target=(((f_fb_target*2*pi)^2)*((0.243*m_JT_eq*h_total+M_rna)*(h_total)^3))/3; %塔筒和导管架的目标等效刚度；
kai=(1/(EI_tj_target/(((h_Jacket+h_Tower)/h_Tower)^3*EI_tower))-1)/((1+fai)^3-1); %kai为塔筒和导管架刚度之比；
EI_Jacket=EI_tower/kai;                                     %塔筒的等效刚度
m_BtoT=L_bottom/L_top;                                      %导管架底部宽度与顶部宽度之比
fm1=m_BtoT*(m_BtoT-1)^3/(m_BtoT^2-2*m_BtoT*log(m_BtoT)-1)/3;
Itopj=EI_Jacket/(fm1*E);                                    %导管架的等效刚度
% 导管架主肢横截面初始截面积
Aleg=Itopj/(L_top)^2;                                       %Ac为导管架的横截面积；
Abrace=0.2*Aleg;                                            %Abrace为支撑的横截面积；
D_leg_ini=4*Aleg/(3.14*(1-23^2/25^2));                      %D_leg为导管架的直径,单位为米；
t_leg_ini=D_leg_ini/25;
fprintf('     Leg初始外直径D_leg_ini = %f 壁厚t_leg_ini = %f\n',D_leg_ini,t_leg_ini);
prompt='      请输入导管架Leg外直径初始值: D_leg = ';
D_leg=input(prompt);
prompt='      请输入导管架Leg壁厚初始值: t_leg = ';
t_leg=input(prompt);
D_brace_ini=0.4*D_leg_ini;
t_brace_ini=Abrace/(3.14*D_brace_ini);
fprintf('     支撑初始外直径D_brace_ini = %f 壁厚t_brace_ini = %f\n',D_brace_ini,t_brace_ini);
prompt='      请输入导管架支撑外直径初始值: D_brace = ';
D_brace=input(prompt);
prompt='      请输入导管架支撑壁厚初始值: t_brace = ';
t_brace=input(prompt);
% 确定主肢、支撑杆件编号
LegidPfloor=set_leg_ID_per_floor(Num_floor, Num_pile);
BraceidPfloor=set_brace_ID_per_floor(Num_floor, Num_pile);
% 判断根据LegidPfloor和BraceidPfloor矩阵计算得到的结构杆件数是否等于前文的Num_bar结果，
checkbarnumber(Num_bar, LegidPfloor, BraceidPfloor);
% 为各构件截面尺寸赋值;
[Member.D, Member.t]=Diameter_thickness_ini(LegidPfloor, BraceidPfloor, D_leg, D_brace, t_leg, t_brace);
fprintf('"Step 3: 初始化导管架各构件截面尺寸"已完成;\n\n');
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 4: 确定导管架所受极端风荷载，准备波浪荷载计算所需参数;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%本步骤针对极端风、波浪工况，计算导管架受到的荷载
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
desktopPath = fullfile(getenv('USERPROFILE'), 'Desktop');  % Windows 路径
% 设置输出文件名
outputFile = fullfile(desktopPath, 'session_output.txt');
% 清空文件并开始记录日志
fclose(fopen(outputFile, 'w'));  % 清空文件内容
diary(outputFile);  % 开始记录日志
%计算风荷载: 1极端湍流模式
fprintf('程序进入"Step 4: 计算导管架所受极端风荷载和准备波浪荷载计算所需参数":\n');
if thru_coef_code==1
    Ct = 3.5*(2*U_r+3.5)/U_r^2;%该参数的取值也分为默认值或者用户自定义值；               %推力系数
    Ct1 = 0.06;
else
    Ct = Ct_rated_user;
	Ct1 = Ct_out_user;
end
f1p_max = n_max/60;                                           %叶片旋转的频率
c=2;                                                        %变量
sigmau_etm=c*I_ref*(0.072*(U_r/c+3)*(U_r/c-4)+10);          %标准差
sigmau_etmfdayu1p=sigmau_etm*sqrt(1/(((6*Lk*f1p_max)/U_r+1)^(2/3))); %大于1p频率的标准差
u_etm=2*sigmau_etmfdayu1p;                                  %etm风况下的湍流分量
F_etm=air_density*Ar*Ct*(U_r+u_etm)^2/2;                    %etm风况下风机受力
%M_etm为泥面位置处的总弯矩，为了单独设计各层leg和brace，还需要计算其它层底部位置处的弯矩；
%计算风荷载: 2极端阵风模式
D_rotor=sqrt(4*Ar/pi); 
sigmau_eog=I_ref*(0.75*U_r+5.6);
z_1=z_hub;
%计算 U_e50 和 U_e1
U_e50=1.4*U_ref*(z_1/z_hub)^0.11;
U_e1=0.8*U_e50;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 计算 u_eog，此处为关键，需确认公式；
u_eog=min(1.35*abs(U_e1-U_r),3.33*sigmau_eog/(1+0.1*D_rotor/Lambda));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
F_eog=air_density*Ar*Ct*(U_r+u_eog)^2/2;	%该公式与IEC 61400-1不太一致，此处直接带入阵风幅值，此处是保守考虑？
%M_eog为泥面位置处的总弯矩，为了单独设计各层leg和brace，还需要计算其它层底部位置处的弯矩；
%计算风荷载：3极端风速模式
F_ewm_6_1=air_density*Ar*Ct1*(U_e50^2)/2;
F_ewm_6_3=air_density*Ar*Ct1*(U_e1^2)/2;
fprintf('      完成1极端湍、2极端阵风、3极端风速气动荷载计算;\n');
%计算波浪力；
fprintf('      开始重现周期1年、50年波浪荷载计算;\n');
%用户输入ETM EOG模式下的Hs2
%g=9.81;
Ts2=11.1*sqrt(Hs2/g);
N2=3600/(Ts2);
Hm2=Hs2*sqrt(log(N2)/2); 
Tm2=11.1*sqrt(Hm2/g); 
DAF2=1/(sqrt((1-1/(Tm2*f_fb_target)^2)^2+(2*0.05*1/(Tm2*f_fb_target)))); 
%计算1年极端波高以及50年极端波高；
g=9.81;                                                     %重力加速度
Hs1=0.8*Hs50;                                               %一年特征波高
Ts1=11.1*sqrt(Hs1/g);                                       %一年特征波高的周期
N1=10800/(Ts1);
Hm1=Hs1*sqrt(log(N1)/2);                                    %一年极端波高
Tm1=11.1*sqrt(Hm1/g);                                       %一年极端波高的周期      
Tm50=11.1*sqrt(Hm50/g);                                     %50年极端波高的周期
DAF1=1/(sqrt((1-1/(Tm1*f_fb_target)^2)^2+(2*0.05*1/(Tm1*f_fb_target))));                %1年极端波高的动力放大系数；
DAF50=1/(sqrt((1-1/(Tm50*f_fb_target)^2)^2+(2*0.05*1/(Tm50*f_fb_target))));             %50年极端波高的动力放大系数
pesai=45;													%导管架方向角,
if pesai>=90
    error('建议导管架方位角取值范围为0~45度，等于90度时，代码有bug');
end                                                
global Hydro;
global Wave;
global Current;
global Discrete;
global dL_ele_target;
dL_ele_target=2.0;
Coord_trans_bar_discrete(pesai, Num_bar);
Num_total_element=0;
for i=1:Num_bar                                             %对杆件编号进行循环
    Num_total_element=Num_total_element+Discrete.Num_ele(i);
end
fprintf('      导管架结构设计使用的单元总数为%d；\n',Num_total_element);
fprintf('"Step 4: 计算导管架所受极端风荷载和波浪荷载"已完成;\n\n');
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 5: 校核各构件承载力;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%本步骤针对极端风、波浪工况，计算导管架受到的荷载
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('程序进入"Step 5: 校核各构件承载力":\n');
t0=0;
t1=100;
dt=0.1;
D_legs=[];
t_legs=[];
D_braces=[];
t_braces=[];
% 初始化结果变量
F_2_all=zeros(Num_floor, 1);                                %储存etm eog模式下水动力荷载
M_2_all=zeros(Num_floor, 1);
F_1y_all=zeros(Num_floor, 1);                               %存储每层构件设计使用的1年重现周期水动力荷载
M_1y_all=zeros(Num_floor, 1);
F_50y_all=zeros(Num_floor, 1);                              %存储每层构件设计使用的50年重现周期水动力荷载
M_50y_all=zeros(Num_floor, 1);
% 测试get_bar_array_for_floor函数get_bar_array_for_floor(1,LegidPfloor,BraceidPfloor)
Y0_position=zeros(Num_floor,1);
Width=zeros(Num_floor,1);
for i = 1:4
    fprintf('\n软件进入导管架第%d 层杆件设计\n',i);
    Num_bar_array = get_bar_array_for_floor(i, LegidPfloor, BraceidPfloor);                         % 获取第 i 层的构件编号数组
    if Num_floor==4
        fprintf('确定导管架结构第%d 层杆件设计内力计算起点坐标\n',i);
        Y0_position(i)=get_center_hydro_load_for_floor_4f(h2, h3, h4, i);                              % Y0_position为i层杆件水动荷载计算时的力系简化中心；
        Width(i)= get_width_of_floor_4f(i,l1,l2,l3,l4);
    elseif Num_floor==3
        fprintf('确定导管架结构第%d 层杆件设计内力计算起点坐标',i);
        Y0_position(i)=get_center_hydro_load_for_floor_3f(h2, h3, i);
        Width(i)= get_width_of_floor_3f(i,l1,l2,l3);
    else
        disp('当前输入参数Num_floor发生致命错误');
        error('本软件适用于导管架层数为层3或4层');
    end
    % 风荷载对水动荷载简化中心之矩，修改了下面的函数，调用代码一并修改
    M_etm=Moment_Jac_wind(F_etm,z_hub,Wave.S,Y0_position(i));                           %etm风况下风机所受力矩
    M_eog=Moment_Jac_wind(F_eog,z_hub,Wave.S,Y0_position(i));                           %etm风况下风机所受力矩
    M_ewm_6_1=Moment_Jac_wind(F_ewm_6_1,z_hub,Wave.S,Y0_position(i));
    M_ewm_6_3=Moment_Jac_wind(F_ewm_6_3,z_hub,Wave.S,Y0_position(i));
   
    % 计算ETM EOG水动力荷载
    Wave.T=Tm2;
    Wave.h=Hm2;
    Wave.k=wave_number(Wave.T, Wave.h);                     %波数
    [Ftx_2, Fty_2, Ftz_2, Mtx_2, Mtz_2,t]=Hydro_load_timehistory(t0, t1, dt, Num_bar_array, Y0_position(i));
    if size(Ftx_2)~=size(t)
        error('致命错误：水动荷载Ftx_1y和时间序列t长度不同，程序运行终止；检查Hydro_load_timehistory函数输出结果Ftx_1y和t');
    end
    [Ftx_2_max, Fty_2_max, Ftz_2_max, Mtx_2_max, Mtz_2_max]=Hydro_load_max(Ftx_2, Fty_2, Ftz_2, Mtx_2, Mtz_2);
    %储存ETM EOG模式下的荷载值
    F_2_all(i)=Ftx_2_max;
    M_2_all(i)=Mtz_2_max;
    
    % 计算1年重现周期的水动力荷载
    Wave.T=Tm1;                                            %50年极端波高的周期
    Wave.h=Hm1;                                            %50年极端波高
    Wave.k=wave_number(Wave.T,Wave.h); 
    [Ftx_1y, Fty_1y, Ftz_1y, Mtx_1y, Mtz_1y,t]=Hydro_load_timehistory(t0, t1, dt, Num_bar_array, Y0_position(i));
    if size(Ftx_1y)~=size(t)
        error('致命错误：水动荷载Ftx_1y和时间序列t长度不同，程序运行终止；检查Hydro_load_timehistory函数输出结果Ftx_1y和t');
    end
    [Ftx_1y_max, Fty_1y_max, Ftz_1y_max, Mtx_1y_max, Mtz_1y_max]=Hydro_load_max(Ftx_1y, Fty_1y, Ftz_1y, Mtx_1y, Mtz_1y);
    % 存储一年周期的荷载值
    F_1y_all(i)=DAF1*Ftx_1y_max;
    M_1y_all(i)=DAF1*Mtz_1y_max;
   
    % 计算50年重现周期的水动力荷载
    Wave.T=Tm50;                                            %50年极端波高的周期
    Wave.h=Hm50;                                            %50年极端波高
    Wave.k=wave_number(Wave.T,Wave.h);                      %波数
    [Ftx_50y, Fty_50y, Ftz_50y, Mtx_50y, Mtz_50y,t] = Hydro_load_timehistory(t0, t1, dt, Num_bar_array, Y0_position(i));
    if size(Ftx_50y)~=size(t)
        error('致命错误：水动荷载Ftx_50y和时间序列t长度不同，程序运行终止；检查Hydro_load_timehistory函数输出结果Ftx_50y和t');
    end
    [Ftx_50y_max, Fty_50y_max, Ftz_50y_max, Mtx_50y_max, Mtz_50y_max] = Hydro_load_max(Ftx_50y, Fty_50y, Ftz_50y, Mtx_50y, Mtz_50y);
     % 存储五十年周期的荷载值
    F_50y_all(i)=DAF50*Ftx_50y_max;
    M_50y_all(i)=DAF50*Mtz_50y_max;
    fprintf('完成重现周期1年、50年波浪荷载计算;\n');
    
    % 计算leg承载力F_allowable_leg
    leg_id_i_floor=LegidPfloor(i,1);
    L_leg=Member.L(leg_id_i_floor);                         % Leg长度;
    D_leg=Member.D(leg_id_i_floor);
    t_leg=Member.t(leg_id_i_floor);
    k_leg=1.0;                                   % brace稳定分析的长度因数；
    A_leg=1/4*3.14*(D_leg^2-(D_leg-2*t_leg)^2);
    I_leg=1/64*3.14*(D_leg^4-(D_leg-2*t_leg)^4);
    ir_leg=sqrt(I_leg/A_leg);
	fprintf('Leg承载力计算;\n');
	F_allowable_leg=sigma_allowable(k_leg, L_leg, ir_leg, A_leg);%leg许用荷载
    % 计算brace承载力F_allowable_brace
    brace_id_i_floor=BraceidPfloor(i,1);
    
    L_brace=Member.L(brace_id_i_floor);              % Brace长度;
    
    D_brace=Member.D(brace_id_i_floor);
    t_brace=Member.t(brace_id_i_floor);
    k_brace=0.8;                                            % brace稳定分析的长度因数；
    A_brace=1/4*3.14*(D_brace^2-(D_brace-2*t_brace)^2);
    I_brace=1/64*3.14*(D_brace^4-(D_brace-2*t_brace)^4);
    ir_brace=sqrt(I_brace/A_brace);
    F_allowable_brace=sigma_allowable(k_brace, L_brace, ir_brace, A_brace);%brace许用荷载

    fprintf('L_brace等于%f；\n',L_brace);
    fprintf('A_brace等于%f；\n',A_brace);
    fprintf('k_brace*L_brace/ir_brace等于%f；\n',k_brace*L_brace/ir_brace);
    fprintf('ir_brace等于%f；\n',ir_brace);
    fprintf('12*pi^2*210000/(23*(k_brace*L_brace/ir_brace)^2)等于%f；\n',12*pi^2*210000/(23*(k_brace*L_brace/ir_brace)^2));
    fprintf('L_leg等于%f；\n',L_leg);
    fprintf('A_leg等于%f；\n',A_leg);
    fprintf('k_leg*L_leg/ir_leg等于%f；\n',k_leg*L_leg/ir_leg);
    fprintf('ir_leg等于%f；\n',ir_leg);
    fprintf('12*pi^2*210000/(23*(k_leg*L_leg/ir_leg)^2)等于%f；\n',12*pi^2*210000/(23*(k_leg*L_leg/ir_leg)^2));
    fprintf('brace最大轴向承载力F_allowable_brace等于%f；\n',F_allowable_brace);
    fprintf('完成leg和brace抗压承载力设计值计算:\n');
    % M_rna=350000;%转子及机舱质量Weight_jacket原来调用的变量错误
    W_jk=Weight_jacket(Num_bar_array,steel_density,Hydro.density,Y0_position(i));
    Wnet=W_jk+(Mtp+MTower+M_rna)*g;                         %整个结构的重力
    % Line 355的函数疑似有错误，待进一步核实
    [F1,M1,F50,M50,F2,M2]=Hydro_load_1and50yrs(Hm2, Tm2, DAF2, Hm50, Tm50, DAF50, Hm1, Tm1, DAF1, t0, t1, dt, Num_bar_array, Y0_position(i));
    % M = 1.3 * max(max(max(M_etm + M2, M_eog + M2), max(M_ewm_6_1 + M50, M_ewm_6_3 + M1)), [], 'all'); %不同工况组合下所受力矩的最大值
    M = 1.35 * max(max(M_etm + M2, M_eog + M2), max(M_ewm_6_1 + M50, M_ewm_6_3 + M1)); %不同工况组合下所受力矩的最大值
    V1=((1/Width(i))*(M/sqrt(2))+1.35*Wnet/4)/cosd(av);                 %腿1受的力，压力，用于leg截面设计
    fprintf('L367 M等于%f；\n',M);
    fprintf('L368 V1等于%f；\n',V1);
    fprintf('Width(i)等于%f；\n',Width(i));
    fprintf('Wnet等于%f；\n',Wnet);
    fprintf('F_etm等于%f；\n',F_etm);
    fprintf('F_eog等于%f；\n',F_eog);
    fprintf('F_ewm_6_1等于%f；\n',F_ewm_6_1);
    fprintf('F_ewm_6_3等于%f；\n',F_ewm_6_3);
    fprintf('M_etm等于%f；\n',M_etm);
    fprintf('M_eog等于%f；\n',M_eog);
    fprintf('M_ewm_6_1等于%f；\n',M_ewm_6_1);
    fprintf('M_ewm_6_3等于%f；\n',M_ewm_6_3);
    fprintf('F2等于%f；\n',F2);
    fprintf('F1等于%f；\n',F1);
    fprintf('F50等于%f；\n',F50);
    fprintf('M2等于%f；\n',M2);
    fprintf('L365 M1等于%f；\n',M1);
    fprintf('L365 M50等于%f；\n',M50);
    fprintf('leg最大轴向荷载V1等于%f；\n',V1);
    fprintf('leg最大轴向承载力F_allowable_leg等于%f；\n',F_allowable_leg);
    fprintf('M等于%f；\n',M);
    if i==4
        V4=((1/L_bottom)*(M/sqrt(2))-0.9*Wnet/4)/cosd(av);                 %腿4受的力，拉力，用于桩设计
    end
    label_bar1='leg';
    fprintf('完成%s轴力设计值计算;\n',label_bar1);
    H = 1.3 * max(max((F_etm + F2) / 4, (F_eog + F2) / 4), max((F_ewm_6_1 + F50) / 4, (F_ewm_6_3 + F1) / 4));%不同工况组合下,导管架单根肢所受最大水平荷载
    Fb=H/cos(sitah)/cosd(pesai);%支撑受的力
    fprintf('L_bottom等于%f；\n',L_bottom);
    fprintf('H等于%f；\n',H);
    fprintf('Fb等于%f；\n',Fb);
    label_bar2='brace';
    fprintf('完成%s轴力设计值计算;\n',label_bar2);
    count_leg=0;
    count_brace=0;
    if (V1 <= F_allowable_leg) && (Fb <= F_allowable_brace)
        fprintf('      %s直接满足承载能力极限状态要求，程序进入后续计算、校核;\n',label_bar1);
        fprintf('      %s直接满足承载能力极限状态要求，程序进入后续计算、校核;\n',label_bar2);
    else
        while (V1 > F_allowable_leg) || (Fb > F_allowable_brace)
            if V1>F_allowable_leg
                count_leg=count_leg+1;
                %D_leg=D_leg+0.18; %D_leg为导管架的直径,单位为米；
                %t_leg=D_leg/30; %厚度
                D_leg=1.4;
                t_leg=t_leg+0.01;
                A_leg=1/4*3.14*(D_leg^2-(D_leg-2*t_leg)^2);
                I_leg=1/64*3.14*(D_leg^4-(D_leg-2*t_leg)^4);
                ir_leg=sqrt(I_leg/A_leg);
                F_allowable_leg=sigma_allowable(k_leg,L_leg,ir_leg,A_leg);%腿许用荷载
                F_allowable_brace=sigma_allowable(k_brace, L_brace, ir_brace, A_brace);%支撑许用荷载
                Diameter_thickness_update(i,LegidPfloor, BraceidPfloor, D_leg, D_brace, t_leg, t_brace);
                %原来的数据参数有错误[F1,M1,F50,M50,F2,M2]=Hydro_load_1and50yrs(Hm2,Hm2,DAF2,Hm50, Tm50, DAF50, Hm1, Tm1, DAF1, t0, t1, dt, Num_bar_array, Y0_position(i));
                [F1,M1,F50,M50,F2,M2]=Hydro_load_1and50yrs(Hm2, Tm2, DAF2, Hm50, Tm50, DAF50, Hm1, Tm1, DAF1, t0, t1, dt, Num_bar_array, Y0_position(i));
				fprintf('      L422 Leg经过 %d次迭代，M1等于%f；\n',count_leg,M1);
                fprintf('      L423 Leg经过 %d次迭代，M50等于%f；\n',count_leg,M50);
                fprintf('      L421 M2等于%f；\n',M2);
				M = 1.35 * max(max(M_etm + M2, M_eog + M2), max(M_ewm_6_1 + M50, M_ewm_6_3 + M1));%不同工况组合下所受力矩的最大值
                W_jk=Weight_jacket(Num_bar_array,steel_density, Hydro.density,Y0_position(i));
                Wnet=W_jk+(Mtp+MTower+M_rna)*g;%整个结构的重力
                fprintf('      导管架%d 层构件设计的M等于%f；\n',i,M);
                V1=((1/Width(i))*(M/sqrt(2))+1.35*Wnet/4)/cosd(av);%腿1受的力
				fprintf('      L433 W_jk等于%f；\n',W_jk);
				fprintf('      L434 Wnet等于%f；\n',Wnet);
				fprintf('      L435 Width等于%f；\n',Width(i));
                fprintf('      Line436：Leg经过 %d次迭代，轴力为 %f,承载力为 %f要求\n',count_leg,V1,F_allowable_leg);
                if i==4
                    V4=((1/L_bottom)*(M/sqrt(2))-0.9*Wnet/4)/cosd(av);                 %腿4受的力，拉力，用于桩设计
                end
                H = 1.3 *max(max((F_etm + F2) / 4, (F_eog + F2) / 4), max((F_ewm_6_1 + F50) / 4, (F_ewm_6_3 + F1) / 4));%不同工况组合下,导管架单根肢所受最大水平荷载
                Fb=H/cos(sitah)/cosd(pesai);%支撑受到的荷载
            elseif Fb>F_allowable_brace
                count_brace=count_brace+1;
                %D_brace=D_brace+0.09;
                %t_brace=D_brace/30;
                D_brace=0.85;
                t_brace=t_brace+0.005;
                A_brace=1/4*3.14*(D_brace^2-(D_brace-2*t_brace)^2);
                I_brace=1/64*3.14*(D_brace^4-(D_brace-2*t_brace)^4);
                ir_brace=sqrt(I_brace/A_brace);
                F_allowable_leg=sigma_allowable(k_leg,L_leg,ir_leg,A_leg);%腿许用荷载
                F_allowable_brace=sigma_allowable(k_brace, L_brace, ir_brace, A_brace);%支撑许用荷载
                Diameter_thickness_update(i,LegidPfloor, BraceidPfloor, D_leg, D_brace, t_leg, t_brace);
                [F1,M1,F50,M50,F2,M2]=Hydro_load_1and50yrs(Hm2, Tm2, DAF2, Hm50, Tm50, DAF50, Hm1, Tm1, DAF1, t0, t1, dt, Num_bar_array, Y0_position(i));
                fprintf('      Brace经过 %d次迭代，M1等于%f；\n',count_brace,M1);
                fprintf('      Brace经过 %d次迭代，M50等于%f；\n',count_brace,M50);
                H = 1.3 * max(max((F_etm + F2) / 4, (F_eog + F2) / 4), max((F_ewm_6_1 + F50) / 4, (F_ewm_6_3 + F1) / 4));%不同工况组合下,导管架单根肢所受最大水平荷载
                Fb=H/cos(sitah)/cosd(pesai);%支撑受到的荷载
				fprintf('L453 F_allowable_brace等于%f；\n',F_allowable_brace);
				fprintf('L459 Fb等于%f；\n',Fb);
                M = 1.35 * max(max(M_etm + M2, M_eog + M2), max(M_ewm_6_1 + M50, M_ewm_6_3 + M1));%不同工况组合下所受力矩的最大值
                fprintf('      导管架%d 层构件设计的M等于%f；\n',i,M);
                W_jk=Weight_jacket(Num_bar_array,steel_density, Hydro.density,Y0_position(i));
                Wnet=W_jk+(Mtp+MTower+M_rna)*g;%整个结构的重力
				fprintf('L460 W_jk等于%f；\n',W_jk);
				fprintf('L461 Wnet等于%f；\n',Wnet);
				fprintf('L462 Width等于%f；\n',Width(i));
                V1=((1/Width(i))*(M/sqrt(2))+1.35*Wnet/4)/cosd(av);%腿1受的力
                fprintf('      Line464：Leg经过 %d次迭代，轴力为 %f,承载力为 %f要求\n',count_leg,V1,F_allowable_leg);
                if i==4
                    V4=((1/L_bottom)*(M/sqrt(2))-0.9*Wnet/4)/cosd(av);                 %腿4受的力，拉力，用于桩设计
                end
            else
                fprintf('      Leg和Brace直接满足承载能力极限状态要求，程序进入后续计算、校核;\n');
            end
        end
    end
    if F_allowable_leg>V1
        fprintf('      导管架%d 层构件设计的M_etm等于%f；\n',i,M_etm);
        fprintf('      导管架%d 层构件设计的M_eog等于%f；\n',i,M_eog);
        fprintf('      导管架%d 层构件设计的M等于%f；\n',i,M);
        fprintf('      经过%d 次迭代，导管架%d 层%s 满足承载力要求\n',count_leg,i,label_bar1);
        fprintf('      导管架%d 层%s 轴力为 %f,承载力为 %f要求\n',i,label_bar1,V1,F_allowable_leg);
    end
    if F_allowable_brace>Fb
        fprintf('      经过%d次迭代，导管架%d 层%s 满足承载力要求\n',count_brace,i,label_bar2);
        fprintf('      导管架%d 层%s 轴力为 %f,承载力为 %f要求\n',i,label_bar2,Fb,F_allowable_brace);
    end
    fprintf('      导管架%d 层Leg外直径为: %f m, 壁厚为 %f m; Brace外直径为 %f m, 壁厚为 %f m;\n',i,D_leg,t_leg,D_brace,t_brace);
    D_legs(i)=D_leg;
    t_legs(i)=t_leg;
    D_braces(i)=D_brace;
    t_braces(i)=t_brace;
end 
fprintf('"Step 5: 校核各构件承载力"已完成;\n\n');
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 6: 确定桩尺寸;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%本步骤根据承载能力极限状态要求，计算所需桩最小尺寸
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('程序进入"Step 6: 确定桩尺寸":\n');
interface_angle=29;
K0=1.0;
D_pile=Diameter_pile(V4,L_pile,wgh_soil,fs_limit,interface_angle,K0);
t_pile=D_pile*1000/100+6.35;
t_pile=ceil(t_pile)/1000;
fprintf('桩长度为: %f m, 桩直径为 %f m，桩厚度为 %f m;\n',L_pile,D_pile,t_pile);
fprintf('"Step 6: 确定桩尺寸"已完成;\n\n');
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 7: 校核系统自振频率;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%本步骤根据桩基础尺寸，重新校核系统自振频率
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('程序进入"Step 7: 校核系统自振频率":\n');
%%校验频率
% 获得导管架刚度EI_Jacket
Ac = zeros(4, 1);
for i=1:4
    Ac(i)=1/4*3.14*(D_legs(i)^2-(D_legs(i)-2*t_legs(i))^2);
end
Ac1=Ac(1);
Ac2=Ac(2);
Ac3=Ac(3);
Ac4=Ac(4);
EI_Jacket=-h_Jacket^3/(3*(h3 + h4)*((h_Jacket^2*(log(abs(L_bottom - ((h3 + h4)*(L_bottom - L_top))/h_Jacket)) + L_top/(L_bottom - ((h3 + h4)*(L_bottom - L_top))/h_Jacket)))/(Ac2*E*(L_bottom - L_top)^2) - (h_Jacket^2*(log(abs(L_bottom - ((h3 + h4)*(L_bottom - L_top))/h_Jacket)) + L_top/(L_bottom - ((h3 + h4)*(L_bottom - L_top))/h_Jacket)))/(Ac3*E*(L_bottom - L_top)^2)) + 3*((h_Jacket^2*(log(abs(L_bottom - ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket)) + L_top/(L_bottom - ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket)))/(Ac1*E*(L_bottom - L_top)^2) - (h_Jacket^2*(log(abs(L_bottom - ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket)) + L_top/(L_bottom - ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket)))/(Ac2*E*(L_bottom - L_top)^2))*(h2 + h3 + h4) + 3*h4*((h_Jacket^2*(log(abs(L_bottom - (h4*(L_bottom - L_top))/h_Jacket)) + L_top/(L_bottom - (h4*(L_bottom - L_top))/h_Jacket)))/(Ac3*E*(L_bottom - L_top)^2) - (h_Jacket^2*(log(abs(L_bottom - (h4*(L_bottom - L_top))/h_Jacket)) + L_top/(L_bottom - (h4*(L_bottom - L_top))/h_Jacket)))/(Ac4*E*(L_bottom - L_top)^2)) - 3*h_Jacket*((h_Jacket^2*(log(abs(L_bottom - ((h3 + h4)*(L_bottom - L_top))/h_Jacket)) + L_top/(L_bottom - ((h3 + h4)*(L_bottom - L_top))/h_Jacket)))/(Ac2*E*(L_bottom - L_top)^2) - (h_Jacket^2*(log(abs(L_bottom - ((h3 + h4)*(L_bottom - L_top))/h_Jacket)) + L_top/(L_bottom - ((h3 + h4)*(L_bottom - L_top))/h_Jacket)))/(Ac3*E*(L_bottom - L_top)^2) + (h_Jacket^2*(log(abs(L_bottom - (h4*(L_bottom - L_top))/h_Jacket)) + L_top/(L_bottom - (h4*(L_bottom - L_top))/h_Jacket)))/(Ac3*E*(L_bottom - L_top)^2) - (h_Jacket^2*(log(abs(L_bottom - (h4*(L_bottom - L_top))/h_Jacket)) + L_top/(L_bottom - (h4*(L_bottom - L_top))/h_Jacket)))/(Ac4*E*(L_bottom - L_top)^2) + (h_Jacket^2*(log(L_bottom) + L_top/L_bottom))/(Ac4*E*(L_bottom - L_top)^2) + (h_Jacket^2*(log(abs(L_bottom - ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket)) + L_top/(L_bottom - ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket)))/(Ac1*E*(L_bottom - L_top)^2) - (h_Jacket^2*(log(abs(L_bottom - ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket)) + L_top/(L_bottom - ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket)))/(Ac2*E*(L_bottom - L_top)^2)) + (3*h_Jacket^3*(log(abs(L_bottom - ((h3 + h4)*(L_bottom - L_top))/h_Jacket))*(L_bottom + L_top - ((h3 + h4)*(L_bottom - L_top))/h_Jacket) - L_bottom + ((h3 + h4)*(L_bottom - L_top))/h_Jacket))/(Ac2*E*(L_bottom - L_top)^3) - (3*h_Jacket^3*(log(abs(L_bottom - ((h3 + h4)*(L_bottom - L_top))/h_Jacket))*(L_bottom + L_top - ((h3 + h4)*(L_bottom - L_top))/h_Jacket) - L_bottom + ((h3 + h4)*(L_bottom - L_top))/h_Jacket))/(Ac3*E*(L_bottom - L_top)^3) + (3*h_Jacket^3*(log(abs(L_bottom - ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket))*(L_bottom + L_top - ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket) - L_bottom + ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket))/(Ac1*E*(L_bottom - L_top)^3) - (3*h_Jacket^3*(log(abs(L_bottom - ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket))*(L_bottom + L_top - ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket) - L_bottom + ((L_bottom - L_top)*(h2 + h3 + h4))/h_Jacket))/(Ac2*E*(L_bottom - L_top)^3) + (3*h_Jacket^3*(log(L_bottom - (h4*(L_bottom - L_top))/h_Jacket)*(L_bottom + L_top - (h4*(L_bottom - L_top))/h_Jacket) - L_bottom + (h4*(L_bottom - L_top))/h_Jacket))/(Ac3*E*(L_bottom - L_top)^3) - (3*h_Jacket^3*(log(L_bottom - (h4*(L_bottom - L_top))/h_Jacket)*(L_bottom + L_top - (h4*(L_bottom - L_top))/h_Jacket) - L_bottom + (h4*(L_bottom - L_top))/h_Jacket))/(Ac4*E*(L_bottom - L_top)^3) + (3*h_Jacket^3*(L_top - 2*L_top*log(abs(L_top))))/(Ac1*E*(L_bottom - L_top)^3) - (3*h_Jacket^3*(L_bottom - log(L_bottom)*(L_bottom + L_top)))/(Ac4*E*(L_bottom - L_top)^3));
 
% 获得塔刚度EI_tower:前文已求出塔筒等效刚度,此处不再赘述;
% 获得等效塔塔套刚度EI_JacketTower
kai=EI_tower/EI_Jacket;
EI_JacketTower=EI_tower*(1/(1+(1+fai)^3*kai-kai))*((h_Jacket+h_Tower)/h_Tower)^3;
% % 获得等效分布质量m_JT_eq
lamda1=1.8751;
beta1=-(cos(lamda1)+cosh(lamda1))/(sin(lamda1)+sinh(lamda1));
m_Jacket_eq=Distribute_mass_jacket(Num_bar,steel_density,h_Jacket);
m_JT_eq=(m_Jacket_eq*(intergral_mode_shape(h_Jacket,lamda1,h_Tower,h_Jacket)-intergral_mode_shape(0,lamda1,h_Tower,h_Jacket))+m_tower_eq*(intergral_mode_shape(h_Jacket+h_Tower,lamda1,h_Tower,h_Jacket)-intergral_mode_shape(h_Jacket,lamda1,h_Tower,h_Jacket)))/(intergral_mode_shape(h_Jacket+h_Tower,lamda1,h_Tower,h_Jacket)-intergral_mode_shape(0,lamda1,h_Tower,h_Jacket));
% 计算f_fb
f_fb=1/(2*3.14)*sqrt(3*EI_JacketTower/((0.243*m_JT_eq*h_total+M_rna)*(h_total)^3));
%土体剪切模量，变量；
Gs=15e6;
kexi=4;
k_pile=2*3.14*L_pile*Gs/kexi;
K_v=2*k_pile;
alpha=1;
K_R=K_v*L_bottom^2*(alpha/(1+alpha));
tao=K_R*h_total/EI_JacketTower;
C_J=sqrt(tao/(tao+3));
f_0=C_J*f_fb;
fprintf('考虑地基柔性后,系统基准频率为%f;\n',f_0);
fprintf('"Step 7: 校核系统自振频率"已完成;\n\n');
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 8: 校核系统自振频率变化特征;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%本步骤根据土体剪切模量变化，重新校核系统自振频率
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%土体剪切模量增大30%
fprintf('程序进入"Step 8: 校核系统自振频率变化特征":\n');
factor1=1.30;
Gs1=Gs*factor1;
k_pile1=2*3.14*L_pile*Gs1/kexi;
K_v1=2*k_pile1;
K_R1=K_v1*L_bottom^2*(1/(1+alpha));
tao1=K_R1*h_total/EI_JacketTower;
C_J1=sqrt(tao1/(tao1+3));
f_0_1=C_J1*f_fb;
fprintf('土体剪切模量为初始值 %f倍时,系统基准频率为 %f;\n',factor1,f_0_1);
%土体剪切模量减小30%
factor2=0.7;
Gs2=Gs*factor2;
k_pile2=2*3.14*L_pile*Gs2/kexi;
K_v2=2*k_pile2;
K_R2=K_v2*L_bottom^2*(1/(1+alpha));
tao2=K_R2*h_total/EI_JacketTower;
C_J2=sqrt(tao2/(tao2+3));
f_0_2=C_J2*f_fb;
fprintf('土体剪切模量为初始值 %f倍时,系统基准频率为 %f;\n',factor2,f_0_2);
fprintf('"Step 8: 校核系统自振频率变化特征"已完成;\n\n');
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 9: 校核塔顶位移;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%本步骤根据土体剪切模量变化，重新校核系统自振频率
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('程序进入"Step 9: 校核塔顶位移":\n');
% Current.U_ss0=0.0;
% Current.U_ns0=0.0;
Wave.T=Tm1;%一年极端波高的周期
Wave.h=Hm1;%一年极端波高
Wave.k=wave_number(Wave.T,Wave.h);%波数
[Ftx_1y_wav,Fty_1y_wav,Ftz_1y_wav,Mtx_1y_wav,Mtz_1y_wav,t]=Hydro_load_timehistory(t0, t1, dt, Num_bar_array,Y0_position(i));
[Ftx_1y_wav_max,Fty_1y_wav_max,Ftz_1y_wav_max,Mtx_1y_wav_max,Mtz_1y_wav_max]=Hydro_load_max(Ftx_1y_wav,Fty_1y_wav,Ftz_1y_wav,Mtx_1y_wav,Mtz_1y_wav);
F1_wav=Ftx_1y_wav_max;
M1_wav=Mtz_1y_wav_max;
a=h_total-M1_wav/F1_wav;
delt_wave=F1_wav*h_total*(h_total-a)/K_R+F1_wav/EI_Jacket*((h_total-a)^3/3-a*(h_total-a)^2/2);
sigmau_ntm=I_ref*(0.75*U_r+5.6); %标准差
sigmau_ntmfdayu1p=sigmau_ntm*sqrt(1/(((6*Lk*f1p_max)/U_r+1)^(2/3))); %大于1p频率的标准差
u_ntm=1.28*sigmau_ntmfdayu1p;%etm风况下的湍流分量
F_ntm=air_density*Ar*Ct*(U_r+u_ntm)^2/2;%etm风况下风机受力
delt_wind=F_ntm*h_total^2/K_R+F_ntm*h_total^3/(3*EI_JacketTower);
delt_towertop=delt_wind+delt_wave;
fprintf('ULS条件下,塔顶位移最大值为 %f;\n',delt_towertop);
fprintf('"Step 9: 校核塔顶位移"已完成;\n\n');

