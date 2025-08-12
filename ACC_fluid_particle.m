function [ax,ay]=ACC_fluid_particle(TT,h,k,S,x,y,t)
% 该函数采用规则波模型，根据波浪周期、波高、波数、水深以及流速，计算t时刻x、y位置的流体质点加速度;
% 输入参数：
% - TT：波浪周期；
% - h：波浪高度；
% - k：波数；
% - S：平均水深；
% - x：水平坐标；
% - y：竖向坐标；
% - t：时刻；
% 输出参数：
% - ax：流体质点沿x方向速度；
% - ay：流体质点沿y方向速度；
% 输入参数判别
global debug;
if debug==1
    if TT<0
        error('致命错误：参数TT小于0，程序终止运行；检查ACC_fluid_particle函数输入参数TT的取值');
    end
    if h<0
        error('致命错误：参数h小于0，程序终止运行；检查ACC_fluid_particle函数输入参数h的取值');
    end
    if k<0
        error('致命错误：参数k小于0，程序终止运行；检查ACC_fluid_particle函数输入参数k的取值');
    end
    if S<0
        error('致命错误：参数S小于0，程序终止运行；检查ACC_fluid_particle函数输入参数S的取值');
    end
    if t<0
        error('致命错误：参数t小于0，程序终止运行；检查ACC_fluid_particle函数输入参数t的取值');
    end
end
% 主函数：
% 定义常数pi，即为圆周率，
pi=3.1415926;
% 计算圆频率omiga，
omiga=2*pi/TT;
% 计算流体质点沿x方向加速度ax，
ax=(omiga^2)*(h/2)*cosh(k*y)/sinh(k*S)*sin(k*x-omiga*t);
% 计算流体质点沿y方向加速度ay，
ay=-(omiga^2)*(h/2)*sinh(k*y)/sinh(k*S)*cos(k*x-omiga*t);                   
end
