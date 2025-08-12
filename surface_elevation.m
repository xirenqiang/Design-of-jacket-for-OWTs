function [y] = surface_elevation(H,k,x,t,w)
%函数surface_elevation用于计算波浪的表面高程；
% 输入参数：
% - H：浪高；
% - x：波浪的横坐标值；
% - k：波数；
% - t：时间；
% - w：圆频率；
% 输入参数判别：
global debug;
if debug==1
    if H<0
        error('致命错误：参数H小于0，程序终止运行；检查surface_elevation函数输入参数H的取值');
    end
    if k<0
        error('致命错误：参数k小于0，程序终止运行；检查surface_elevation函数输入参数k的取值');
    end
    if t<0
        error('致命错误：参数t小于起始时间0，程序终止运行；检查surface_elevation函数输入参数t的取值');
    end
    if w<0
        error('致命错误：参数w小于0，程序终止运行；检查surface_elevation函数输入参数w的取值');
    end
end
% 主函数：
y=H/2*cos(k*x-w*t);
end
