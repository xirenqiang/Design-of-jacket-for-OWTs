clc
clear all;
Num_bar=52;
steel_density=7850;
D_leg=4;
t_leg=0.17;
A_leg=3.14*D_leg*t_leg;
L_top=8;
L_bottom=12.0941;
m_tower_eq=3730;
clc;
clear all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 1: 确定海洋气象参数%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 本步骤根据海洋气象条件，确定必要的风速场、波浪场参数;(需开展工作：梳理程序所有输入参数，对于变量，考虑通过文件读入)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('程序进入"Step 1: 确定海洋气象参数":\n');
k_weibull=11.75;            %Weibull规模参数
s_weibull=2.04;             %Weibull形状参数，这两个参数可以参考upwind文献
n_min=6.9;                  %风轮运行的最小转速
n_max=12.1;                 %风轮运行的最大转速
M_rna=350000;               %风轮-机舱组合的总质量，单位为kg
D_Tower_top=4;              %塔筒顶部直径
D_Tower_bottom=5.6;         %塔筒底部直径
m_t=261100;                 %塔筒总质量
h_Tower=70;                 %塔筒的高度，单位为米
av=1.75;                    %导管架主肢倾斜角，单位为度
Num_floor=4;                %导管架分层数
L_top=8;                    %导管架上平台宽度
water_depth=50;             %水深
Hs50=8.24;                  %50年特征波高
Hm50=15.33;                 %50年极端波高
steel_density=7850;         %塔筒的密度
E=2.1*10^11;                %塔筒材料杨氏模量
m_tower_eq=m_t/h_Tower;     %单位长度塔筒质量
fprintf('"Step 1: 输入计算参数"已完成;\n\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 2: 确定导管架整体几何参数%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 本步骤依据设计经验，确定导管架整体几何参数;(需开展工作：确定各层高度时，就分为三层、四层两种情况，考虑去掉水平支撑后的杆件数确定(Num_bar
% )，当前代码在导管架为三层时，疑似有bug，例如：L_bottom计算公式错误
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('程序进入"Step 2: 确定导管架整体几何参数":\n');
% 参数av、Num_floor和L_top需要依据经验确定,已归入Step 1输入%%%%%%%%%%%
Zplatform=water_depth+Hm50+0.2*Hs50;                        %平台总高度
h_Jacket=ceil(Zplatform);                                   %平台总高度取整
L_bottom=L_top+2*h_Jacket*tand(av);                         %导管架泥线处宽带
m=(L_bottom/L_top)^(1/Num_floor);                           %比例系数
h1=h_Jacket*((m-1)/(m^Num_floor-1));                        %第一层高度
%建议此处(40~46行)增加一个if语句，根据层数，设定各层高度及宽度参数
h2=m*h1;                                                    %第二层的高度
h3=m*h2;                                                    %第三层的高度
h4=m*h3;                                                    %第四层的高度
l1=m*L_top;                                                 %第一层宽度
l2=m*l1;                                                    %第二层宽度
l3=m*l2;                                                    %第三层宽度
L_bottom=m*l3;                                              %泥面处宽度

sitah=atan(h1/(l1-h1*tand(av)));                            %sitah为支撑的夹角；
global Member;                                              %定义全局变量
%建议此处(51~52行)，改动原有的杆件数及编号规则：每层leg、brace均独立编号、设计，删掉每层的水平支撑；
Num_bar=Bar_num_determine(Num_floor);                       %Num_bar为导管架总构件数量;
Geometry_jacket(Num_floor,L_bottom,L_top,h_Jacket,h4,m);	%确定导管架各构件起点、终点坐标;
fprintf('"Step 2: 确定导管架整体几何参数"已完成;\n\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 3: 初始化导管架各构件截面尺寸%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 本步骤基于固有频率目标值，初步确定各杆件截面尺寸；
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('程序进入"Step 3: 初始化导管架各构件截面尺寸":\n');
f_3p_min=3*n_min*2*3.14/60*0.9/(2*3.14);
f_1p_max=n_max*2*3.14/60*1.1/(2*3.14);
f_fb_target=1/2*(f_1p_max+f_3p_min);                        %支撑结构的目标频率;
fprintf('系统基准频率目标值设定为:%fHz\n',f_fb_target);
m_JT_eq=m_tower_eq;                                         %m_JT_eq为导管架、塔筒等效分布质量，初始值取为塔筒等效分布质量m_tower_eq，单位为kg/m
fai=h_Jacket/h_Tower;                                       %导管架与塔筒的高度之比
Dt_Tower=(D_Tower_top+D_Tower_bottom)/2;                    %塔筒的平均直径
t_tower=(m_t/(steel_density*pi*h_Tower*Dt_Tower));          %塔筒的等效壁厚
h_total=h_Jacket+h_Tower;                                   %支撑结构的总高度(导管架高度与塔筒高度之和)
I_Tower_top=(pi*(D_Tower_top^3)*t_tower)/8;                 %塔筒的转动惯量
q=D_Tower_bottom/D_Tower_top;                               %塔筒下上直径之比
fq=((2*q^2*(q-1)^3)/(q^2*(2*log(q)-3)+4*q-1))/3;
EI_tower=E*I_Tower_top*fq;                                  %塔筒的等效刚度
EI_tj_target=(((f_fb_target*2*pi)^2)*((0.243*m_JT_eq*h_total+M_rna)*(h_total)^3))/3; %塔筒和导管架的目标等效刚度
kai=(1/(EI_tj_target/(((h_Jacket+h_Tower)/h_Tower)^3*EI_tower))-1)/((1+fai)^3-1); %kai为塔筒和导管架刚度之比；
EI_Jacket=EI_tower/kai;                                     %塔筒的等效刚度
m_BtoT=L_bottom/L_top;                                      %导管架底部宽度与顶部宽度之比
fm1=m_BtoT*(m_BtoT-1)^3/(m_BtoT^2-2*m_BtoT*log(m_BtoT)-1)/3;
Itopj=EI_Jacket/(fm1*E);                                    %导管架的等效刚度
Aleg=Itopj/(L_top)^2;                                       %Ac为导管架的横截面积；
Abrace=0.2*Aleg;                                            %Abrace为支撑的横截面积；
D_leg_ini=4*Aleg/(3.14*(1-23^2/25^2));                      %D_leg为导管架的直径,单位为米；
t_leg_ini=D_leg_ini/25;
fprintf('Leg初始外直径D_leg_ini = %f 壁厚t_leg_ini = %f\n',D_leg_ini,t_leg_ini);
prompt='请输入导管架Leg外直径初始值: D_leg = ';
D_leg=input(prompt);
prompt='请输入导管架Leg壁厚初始值: t_leg = ';
t_leg=input(prompt);
D_brace_ini=0.4*D_leg_ini;
t_brace_ini=Abrace/(3.14*D_brace_ini);
fprintf('支撑初始外直径D_brace_ini = %f 壁厚t_brace_ini = %f\n',D_brace_ini,t_brace_ini);
prompt='请输入导管架支撑外直径初始值: D_brace = ';
D_brace=input(prompt);
prompt='请输入导管架支撑壁厚初始值: t_brace = ';
t_brace=input(prompt);
[Member.D,Member.t]=Diameter_thickness(Num_bar,D_leg,D_brace,t_leg,t_brace); %为各构件截面尺寸赋值;
fprintf('"Step 3: 初始化导管架各构件截面尺寸"已完成;\n\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 4: 计算导管架所受极端风荷载和波浪荷载;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%本步骤针对极端风、波浪工况，计算导管架收到的荷载
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%计算风荷载: 1极端湍流模式
fprintf('程序进入"Step 4: 计算导管架所受极端风荷载和波浪荷载":\n');
U_r=11.4;%轮毂高度处的平均风速
Ar=12469;%叶片的扫掠面积
air_density=1.225;%空气的密度
Lk=340.2;%LK为积分长度尺度
Ct=3.5*(2*U_r+3.5)/U_r^2;%推力系数
f1p_max=n_max/60;%叶片旋转的频率
c=2; 
I_ref=0.18; %Iref为U_r=11.4 m/s时的参考湍流强度
sigmau_etm=c*I_ref*(0.072*(U_r/c+3)*(U_r/c-4)+10); %标准差
sigmau_etmfdayu1p=sigmau_etm*sqrt(1/(((6*Lk*f1p_max)/U_r+1)^(2/3))); %大于1p频率的标准差
u_etm=2*sigmau_etmfdayu1p;%etm风况下的湍流分量
F_etm=air_density*Ar*Ct*(U_r+u_etm)^2/2;%etm风况下风机受力
%M_etm为泥面位置处的总弯矩，为了单独设计各层leg和brace，还需要计算其它层底部位置处的弯矩；
M_etm=F_etm*(h_Jacket+h_Tower);%etm风况下风机所受转矩
%计算风荷载: 2极端阵风模式
D_rotor=sqrt(4*Ar/pi);%风轮平面的直径
% U10_50year=(-log(1-0.98^(1/52596)))^(1/s_weibull)*k_weibull;
% U10_1year=0.8*U10_50year;
U10_50year=40.2;
U10_1year=30;
sigma_Uc=0.08*U10_50year;
u_eog=min(1.35*(U10_1year-U_r),3.33*sigma_Uc/(1+0.8*D_rotor/Lk));%eog风况下的湍流分量
F_eog=air_density*Ar*Ct*(U_r+u_eog)^2/2;%eog风况下风机受力
%M_eog为泥面位置处的总弯矩，为了单独设计各层leg和brace，还需要计算其它层底部位置处的弯矩；
M_eog=F_eog*(h_Jacket+h_Tower);%eog风况下风机所受转矩
fprintf('完成1极端湍、2极端阵风工况气动荷载计算;\n');
%计算波浪力；
fprintf('开始重现周期1年、50年波浪荷载计算;\n');
%计算1年极端波高以及50年极端波高；
g=9.81;%重力加速度
Hs1=0.8*Hs50;%一年特征波高
Ts1=11.1*sqrt(Hs1/g);%一年特征波高的周期
N1=10800/(Ts1);
Hm1=Hs1*sqrt(log(N1)/2);%一年极端波高
Tm1=11.1*sqrt(Hm1/g);%一年极端波高的周期      
Tm50=11.1*sqrt(Hm50/g);%50年极端波高的周期
DAF1=1/(sqrt((1-1/(Tm1*f_fb_target)^2)^2+(2*0.05*1/(Tm1*f_fb_target))));%1年极端波高的动力放大系数；
DAF50=1/(sqrt((1-1/(Tm50*f_fb_target)^2)^2+(2*0.05*1/(Tm50*f_fb_target))));%50年极端波高的动力放大系数
pesai=45; %导管架方向角,
global Hydro;
global Wave;
global Current;
global Discrete;
Coord_trans_bar_discrete(pesai,Num_bar);
Hydro.density=1025;%海水密度
Hydro.cd=1.0;%阻力系数
Hydro.cm=2.0;%惯性系数
Wave.S=50;%水深
Current.U_ss0=0.6;
Current.U_w0=0.6;
t0=0;
t1=100;
dt=0.1;
Wave.T=Tm1;%一年极端波高的周期
Wave.h=Hm1;%一年极端波高
Wave.k=wave_number(Wave.T,Wave.h);%波数
%水动力荷载计算是你需要修改的第一个核心内容，此处仅针对最底层进行了计算，需要补充针对其它层的计算；
[Ftx_1y,Fty_1y,Ftz_1y,Mtx_1y,Mtz_1y,F_bracex_1y,M_bracez_1y,t]=Hydro_load_timehistory(t0,t1,dt,Num_bar);
[Ftx_1y_max,Fty_1y_max,Ftz_1y_max,Mtx_1y_max,Mtz_1y_max]=Hydro_load_max(Ftx_1y,Fty_1y,Ftz_1y,Mtx_1y,Mtz_1y);
F1ND=Ftx_1y_max;
M1ND=Mtz_1y_max;
F1=DAF1*F1ND;%基于动态放大系数，1年极端海况下导管架受的力
M1=DAF1*M1ND;%基于动态放大系数，1年极端海况下导管架受的力矩
Wave.T=Tm50;%50年极端波高的周期
Wave.h=Hm50;%50年极端波高
Wave.k=wave_number(Wave.T,Wave.h);%波数
[Ftx_50y,Fty_50y,Ftz_50y,Mtx_50y,Mtz_50y,F_bracex_50y,M_bracez_50y,t]=Hydro_load_timehistory(t0,t1,dt,Num_bar);
[Ftx_50y_max,Fty_50y_max,Ftz_50y_max,Mtx_50y_max,Mtz_50y_max]=Hydro_load_max(Ftx_50y,Fty_50y,Ftz_50y,Mtx_50y,Mtz_50y);
F50ND=Ftx_50y_max;
M50ND=Mtz_50y_max;
F50=DAF50*F50ND;%基于动态放大系数，50年极端海况下导管架受的力
M50=DAF50*M50ND;%基于动态放大系数，50年极端海况下导管架受的力矩
fprintf('完成重现周期1年、50年波浪荷载计算;\n');
fprintf('"Step 4: 计算导管架所受极端风荷载和波浪荷载"已完成;\n\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 5: 校核各构件承载力;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%本步骤针对极端风、波浪工况，计算导管架受到的荷载
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('程序进入"Step 5: 校核各构件承载力":\n');
L_leg=19.4;
k_leg=1.0;
A_leg=1/4*3.14*(D_leg^2-(D_leg-2*t_leg)^2);
I_leg=1/64*3.14*(D_leg^4-(D_leg-2*t_leg)^4);
ir_leg=sqrt(I_leg/A_leg);
L_brace=22.75;
k_brace=0.8;
A_brace=1/4*3.14*(D_brace^2-(D_brace-2*t_brace)^2);
I_brace=1/64*3.14*(D_brace^4-(D_brace-2*t_brace)^4);
ir_brace=sqrt(I_brace/A_brace);
F_allowable_leg=sigma_allowable(k_leg,L_leg,ir_leg,A_leg);%腿许用荷载
F_allowable_brace=sigma_allowable(k_brace,L_brace,ir_brace,A_brace);%支撑许用荷载
fprintf('完成构件抗压承载力设计值计算":\n');
Mtp=666000;%转换平台质量
MTower=h_Tower*3730;%塔筒质量
% M_rna=350000;%转子及机舱质量
W_jk=Weight_jacket(Num_bar,steel_density,Hydro.density);
Wnet=W_jk+(Mtp+MTower+M_rna)*g;%整个结构的重力
M=1.3*max(M_etm+M50,M1+M_eog);%不同工况组合下所受力矩的最大值
V1=(1/L_bottom)*(M/sqrt(2))+1.3*Wnet/4;%腿1受的力
V4=(1/L_bottom)*(M/sqrt(2))-0.9*Wnet/4;%腿4受的力
label_bar='leg';
fprintf('完成%s轴力设计值计算;\n',label_bar);
if V1<=F_allowable_leg
    fprintf('%s满足承载能力极限状态要求，程序进入后续计算、校核;\n',label_bar);
else
    fprintf('%s不满足承载能力极限状态要求；\n进入迭代计算步骤：增大%s直径、壁厚，重新校核强度，直至收敛;\n',label_bar,label_bar);
    count=0;
    while V1>=F_allowable_leg
        count=count+1;
%         D_leg=D_leg+0.1; %D_leg为导管架的直径,单位为米；
%         t_leg=t_leg+0.01;
%此处截面尺寸更新算法应改进，可考虑根据荷载V1、承载力F_allowable_leg的插值，按比例增大桩径和壁厚；
%         D_leg=ceil(1.2*D_leg*10)/10; %D_leg为导管架的直径,单位为米；
%         t_leg=ceil(1.2*t_leg*100)/100;
D_leg=ceil(V1/F_allowable_leg*D_leg*10)/10; %D_leg为导管架的直径,单位为米；
t_leg=ceil(V1/F_allowable_leg*t_leg*100)/100;
%         k_factor_leg=sqrt(abs(V1)/abs(F_allowable_leg));
%         D_leg=ceil(D_leg*k_factor_leg*10)/10; %D_leg为导管架的直径,单位为米；
%         t_leg=ceil((t_leg*k_factor_leg*1000)/5)*5/1000;
        A_leg=1/4*3.14*(D_leg^2-(D_leg-2*t_leg)^2);
        I_leg=1/64*3.14*(D_leg^4-(D_leg-2*t_leg)^4);
        ir_leg=sqrt(I_leg/A_leg);
        F_allowable_leg=sigma_allowable(k_leg,L_leg,ir_leg,A_leg);%腿许用荷载
        [Member.D,Member.t]=Diameter_thickness(Num_bar,D_leg,D_brace,t_leg,t_brace);
        [F1,M1,F50,M50]=Hydro_load_1and50yrs(Hm50,Tm50,DAF50,Hm1,Tm1,DAF1,t0,t1,dt,Num_bar);
        M=1.3*max(M_etm+M50,M1+M_eog);%不同工况组合下所受力矩的最大值
        W_jk=Weight_jacket(Num_bar,steel_density,Hydro.density);
        Wnet=W_jk+(Mtp+MTower+M_rna)*g;%整个结构的重力
        V1=(1/L_bottom)*(M/sqrt(2))+1.3*Wnet/4;%腿1受的力
    end
    fprintf('%d次迭代后，%s满足承载能力极限状态要求；\n程序进入后续计算、校核;\n',count,label_bar);
end
H=1.3*max((F_etm+F50)/4,(F_eog+F1)/4);%不同工况组合下,导管架单根肢所受最大水平荷载
Fb=H/cos(sitah);%支撑受的力
label_bar='brace';
fprintf('完成%s轴力设计值计算;\n',label_bar);
if Fb<=F_allowable_brace
    fprintf('%s满足承载能力极限状态要求，程序进入后续计算、校核;\n',label_bar);
else
    fprintf('%s不满足承载能力极限状态要求；\n进入迭代计算步骤：增大%s直径、壁厚，重新校核强度，直至收敛;\n',label_bar,label_bar);
    count=0;
    while Fb>=F_allowable_brace
        count=count+1;
%         D_brace=D_brace+0.1;
%         t_brace=t_brace+0.01;
        k_factor_b=abs(Fb)/abs(F_allowable_brace);
        D_brace=ceil(D_brace*k_factor_b*10)/10;
        t_brace=ceil(t_brace*k_factor_b*1000/5)*5/1000;
        A_brace=1/4*3.14*(D_brace^2-(D_brace-2*t_brace)^2);
        I_brace=1/64*3.14*(D_brace^4-(D_brace-2*t_brace)^4);
        ir_brace=sqrt(I_brace/A_brace);
        F_allowable_brace=sigma_allowable(k_brace,L_brace,ir_brace,A_brace);%支撑许用荷载
        [Member.D,Member.t]=Diameter_thickness(Num_bar,D_leg,D_brace,t_leg,t_brace);
        [F1,M1,F50,M50]=Hydro_load_1and50yrs(Hm50,Tm50,DAF50,Hm1,Tm1,DAF1,t0,t1,dt,Num_bar);
        H=1.3*max((F_etm+F50)/4,(F_eog+F1)/4);%不同工况组合下,导管架单根肢所受最大水平荷载
        Fb=H/cos(sitah);%支撑受到的荷载
    end
    fprintf('%d 次迭代后，%s 满足承载能力极限状态要求；\n程序进入后续计算、校核;\n',count,label_bar);
end
fprintf('导管架肢外直径为: %f m, 壁厚为 %f m; 支撑外直径为 %f m, 壁厚为 %f m;\n',D_leg,t_leg,D_brace,t_brace);
fprintf('"Step 5: 校核各构件承载力"已完成;\n\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 6: 确定桩尺寸;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%本步骤根据承载能力极限状态要求，计算所需桩最小尺寸
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('程序进入"Step 6: 确定桩尺寸":\n');
L_pile=50;
wgh_soil=10.0e3;
fs_limit=95.7e3;
interface_angle=29;
K0=1.0;
D_pile=Diameter_pile(V4,L_pile,wgh_soil,fs_limit,interface_angle,K0);
t_pile=D_pile*1000/100+6.35;
t_pile=ceil(t_pile)/1000;
fprintf('桩长度为: %f m, 桩直径为 %f m;\n',L_pile,D_pile);
fprintf('"Step 6: 确定桩尺寸"已完成;\n\n');
I_J_top=A_leg*L_top^2;
f_m=1/3*m_BtoT*(m_BtoT-1)^3/(m_BtoT^2-2*m_BtoT*log(m_BtoT)-1);
E=200e9;
EI_Jacket=E*I_J_top*f_m;
% 获得塔刚度EI_tower:前文已求出塔筒等效刚度,此处不再赘述;
% % 获得等效塔塔套刚度EI_JacketTower
EI_tower=3.568688065482946e+11;
kai=EI_tower/EI_Jacket;
h_Jacket=67;
h_Tower=70;
fai=h_Jacket/h_Tower;
EI_JacketTower=EI_tower*(1/(1+(1+fai)^3*kai-kai))*((h_Jacket+h_Tower)/h_Tower)^3;
% % 获得等效分布质量m_JT_eq
lamda1=1.8751;
beta1=-(cos(lamda1)+cosh(lamda1))/(sin(lamda1)+sinh(lamda1));
m_Jacket_eq=Distribute_mass_jacket(Num_bar,steel_density,h_Jacket);
m_JT_eq=(m_Jacket_eq*(intergral_mode_shape(h_Jacket,lamda1,h_Tower,h_Jacket)-intergral_mode_shape(0,lamda1,h_Tower,h_Jacket))+m_tower_eq*(intergral_mode_shape(h_Jacket+h_Tower,lamda1,h_Tower,h_Jacket)-intergral_mode_shape(h_Jacket,lamda1,h_Tower,h_Jacket)))/(intergral_mode_shape(h_Jacket+h_Tower,lamda1,h_Tower,h_Jacket)-intergral_mode_shape(0,lamda1,h_Tower,h_Jacket));
% % 计算f_fb
f_fb=1/(2*3.14)*sqrt(3*EI_JacketTower/((0.243*m_JT_eq*h_total+M_rna)*(h_total)^3));
