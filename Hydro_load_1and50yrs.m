function [F1,M1,F50,M50,F2,M2]=Hydro_load_1and50yrs(Hm2,Tm2,DAF2,Hm50,Tm50,DAF50,Hm1,Tm1,DAF1,t0,t1,dt,Member_group,y0_position)
% 该函数用于计算导管架部分杆件受到的重现期为1year和50year的水动力荷载，该荷载向所考虑杆件集合(Member_group)的最下层中心处简化，用于确定该层杆件的内力；
% 输入变量：
% - Hm50：重现期50year波浪的最大波高；
% - Tm50：重现期50year波浪的周期；
% - DAF50：重现期50year波浪周期的结构动力放大系数；
% - Hm1：重现期1year的最大波高；
% - Tm1：重现期1year波浪的周期；
% - DAF1：重现期1year波浪周期的结构动力放大系数；
% - t0：计算起始时间；
% - t1：计算终止时间；
% - dt：时间步长；
% - Member_group：
% 输出变量：
% - F1：重现期1year波浪作用下最大荷载；
% - M1：重现期1year波浪作用下最大弯矩；
% - F50：重现期50year波浪作用下最大荷载；
% - M50：重现期50year波浪作用下最大弯矩；
% 输入参数检验：
global debug;
if debug==1
    if Hm2<0
        error('致命错误：参数Hm2小于0，程序终止运行；检查Hydro_load_1and50yrs函数输入参数Hm2的取值');
    end
    if Tm2<0
        error('致命错误：参数Tm2小于0，程序终止运行；检查Hydro_load_1and50yrs函数输入参数Tm2的取值');
    end
    if Hm50<0
        error('致命错误：参数Hm50小于0，程序终止运行；检查Hydro_load_1and50yrs函数输入参数Hm50的取值');
    end
    if Tm50<0
        error('致命错误：参数Tm50小于0，程序终止运行；检查Hydro_load_1and50yrs函数输入参数Tm50的取值');
    end
    if DAF50<0
        error('致命错误：参数DAF50小于0，程序终止运行；检查Hydro_load_1and50yrs函数输入参数DAF50的取值');
    end
    if Hm1<0
        error('致命错误：参数Hm1小于0，程序终止运行；检查Hydro_load_1and50yrs函数输入参数Hm1的取值');
    end
    if Tm1<0
        error('致命错误：参数Tm1小于0，程序终止运行；检查Hydro_load_1and50yrs函数输入参数Tm1的取值');
    end
    if DAF1<0
        error('致命错误：参数DAF1小于0，程序终止运行；检查Hydro_load_1and50yrs函数输入参数DAF1的取值');
    end
    if t0<0
        error('致命错误：参数t0小于0，程序终止运行；检查Hydro_load_1and50yrs函数输入参数t0的取值');
    end
    if t1<0
        error('致命错误：参数t1小于0，程序终止运行；检查Hydro_load_1and50yrs函数输入参数t1的取值');
    end
    if dt<0
        error('致命错误：参数dt小于0，程序终止运行；检查Hydro_load_1and50yrs函数输入参数dt的取值');
    end
    if Member_group<0
        error('致命错误：参数Member_group小于0，程序终止运行；检查Hydro_load_1and50yrs函数输入参数Member_group的取值');
    end
end
% 主函数：
% 引用全局变量：
global Wave;
Wave.T=Tm50;%50年极端波高的周期
Wave.h=Hm50;%50年极端波高
Wave.k=wave_number(Wave.T,Wave.h);%波数
[Ftx_50y,Fty_50y,Ftz_50y,Mtx_50y,Mtz_50y,t]=Hydro_load_timehistory(t0,t1,dt,Member_group,y0_position);
[Ftx_50y_max,Fty_50y_max,Ftz_50y_max,Mtx_50y_max,Mtz_50y_max]=Hydro_load_max(Ftx_50y,Fty_50y,Ftz_50y,Mtx_50y,Mtz_50y);
if debug==1
    if size(Ftx_50y)~=size(t)
        error('致命错误：水动荷载Ftx_50y和时间序列t长度不同，程序运行终止；检查Hydro_load_1and50yrs函数输出结果Ftx_50y和t');
    end
    if Fty_50y_max<0
        error('致命错误：参数Fty_50y_max小于0，程序终止运行；检查Hydro_load_1and50yrs函数参数Fty_50y_max');
    end
    if Ftz_50y_max<0
        error('致命错误：参数Ftz_50y_max小于0，程序终止运行；检查Hydro_load_1and50yrs函数参数Ftz_50y_max的取值');
    end
    if Mtx_50y_max<0
        error('致命错误：参数Mtx_50y_max小于0，程序终止运行；检查Hydro_load_1and50yrs函数参数Mtx_50y_max的取值');
    end
end
F50ND=Ftx_50y_max;
M50ND=Mtz_50y_max;
F50=DAF50*F50ND;%基于动态放大系数，50年极端海况下导管架受的力
M50=DAF50*M50ND;%基于动态放大系数，50年极端海况下导管架受的力矩

Wave.T=Tm1;%一年极端波高的周期
Wave.h=Hm1;%一年极端波高
Wave.k=wave_number(Wave.T,Wave.h);%波数
[Ftx_1y,Fty_1y,Ftz_1y,Mtx_1y,Mtz_1y,t]=Hydro_load_timehistory(t0,t1,dt,Member_group,y0_position);
[Ftx_1y_max,Fty_1y_max,Ftz_1y_max,Mtx_1y_max,Mtz_1y_max]=Hydro_load_max(Ftx_1y,Fty_1y,Ftz_1y,Mtx_1y,Mtz_1y);
if debug==1
    if size(Ftx_1y)~=size(t)
        error('致命错误：水动荷载Ftx_1y和时间序列t长度不同，程序运行终止；检查Hydro_load_1and50yrs函数输出结果Ftx_1y和t');
    end
    if Fty_1y_max<0
        error('致命错误：参数Fty_1y_max小于0，程序终止运行；检查Hydro_load_1and50yrs函数参数Fty_1y_max');
    end
    if Ftz_1y_max<0
        error('致命错误：参数Ftz_1y_max小于0，程序终止运行；检查Hydro_load_1and50yrs函数参数Ftz_1y_max的取值');
    end
    if Mtx_1y_max<0
        error('致命错误：参数Mtx_1y_max小于0，程序终止运行；检查Hydro_load_1and50yrs函数参数Mtx_1y_max的取值');
    end
end
F1ND=Ftx_1y_max;
M1ND=Mtz_1y_max;
F1=DAF1*F1ND;%基于动态放大系数，1年极端海况下导管架受的力
M1=DAF1*M1ND;%基于动态放大系数，1年极端海况下导管架受的力矩

% 应该先设定波浪参数、然后再计算荷载
Wave.T=Tm2;%极端波高的周期
Wave.h=Hm2;%极端波高
[Ftx_2,Fty_2,Ftz_2,Mtx_2,Mtz_2,t]=Hydro_load_timehistory(t0,t1,dt,Member_group,y0_position);
[Ftx_2_max,Fty_2_max,Ftz_2_max,Mtx_2_max,Mtz_2_max]=Hydro_load_max(Ftx_2,Fty_2,Ftz_2,Mtx_2,Mtz_2);
Wave.k=wave_number(Wave.T,Wave.h);%波数
if debug==1
    if size(Ftx_2)~=size(t)
        error('致命错误：水动荷载Ftx_2和时间序列t长度不同，程序运行终止；检查Hydro_load_1and50yrs函数输出结果Ftx_2和t');
    end
    if Fty_2_max<0
        error('致命错误：参数Fty_2_max小于0，程序终止运行；检查Hydro_load_1and50yrs函数参数Fty_2_max');
    end
    if Ftz_2_max<0
        error('致命错误：参数Ftz_2_max小于0，程序终止运行；检查Hydro_load_1and50yrs函数参数Ftz_2_max的取值');
    end
    if Mtx_2_max<0
        error('致命错误：参数Mtx_2_max小于0，程序终止运行；检查Hydro_load_1and50yrs函数参数Mtx_2_max的取值');
    end
end
F2ND=Ftx_2_max;
M2ND=Mtz_2_max;
F2=DAF2*F2ND;
M2=DAF2*M2ND;
end
