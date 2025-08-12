function [k]=wave_number(T,S)
% 根据水深、波浪周期，计算Airy波波数k;
% 输入参数：
% - T：波浪周期；
% - S：平均水深；
% 输出参数：
% - k：波数；
global debug;
if debug==1
    if T<0
        error('致命错误：波浪周期T小于0，程序运行终止；检查wave_number函数输入参数T');
    end
    if S<0
        error('致命错误：平均水深S小于0，程序终止运行；检查wave_number函数输入参数S');
    end
end
% 定义计算常数，
pi=3.1415926;                                   %常数π；
g=9.8;                                          %常数重力加速度；
x0=1.0e-8;                                      %迭代运算初始值；
% 计算初始迭代值x，
x=(4*pi*pi*S)/(g*T*T*tanh(x0));
i=0;
% 开始迭代计算
while abs(x-x0)>1.0e-8;
    x0=x;
    x=(4*pi*pi*S)/(g*T*T*tanh(x0));
	i=i+1;
end
L=2*pi*S/x;                                     %波长;
k=2*pi/L;                                       %波数;
end
