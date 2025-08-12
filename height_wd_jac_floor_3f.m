function [h2,h3,l2,l3]=height_wd_jac_floor_3f(Num_floor,h1,l1,m)
% 该函数用于计算导管架各层高度及宽度;
% 输入参数:
% - Num_floor：导管架层数；
% - h1：导管架第一层高度；
% - l1：导管架第一层顶宽度；
% - m：导管架相邻两层高度比（下层高度除以上层高度，取值大于1）；
% 输出参数:
% - h2：导管架第二层高度；
% - h3：导管架第三层高度；
% - l2：导管架第二层顶宽度；
% - l3：导管架第三层顶宽度；
% - L_bottom：导管架第一层顶宽度；
global debug;
if debug==1
    if h1<0
        error('致命错误：参数h1小于0，程序终止运行；检查height_wd_jac_floor_3f函数参数h1');
    end
    if l1<0
        error('致命错误：参数l1小于0，程序终止运行；检查height_wd_jac_floor_3f函数参数l1的取值');
    end
    if m<0
        error('致命错误：参数m小于0，程序终止运行；检查height_wd_jac_floor_3f函数参数m的取值');
    end
end
if Num_floor==3
    % 计算导管架第二层高度h2，
    h2=m*h1;
    % 计算导管架第三层高度h3，
    h3=m*h2;
    % 计算导管架第二层顶宽度l2，
    l2=m*l1;
    % 计算导管架第三层顶宽度l2，
    l3=m*l2;
else
    error('致命错误：函数height_wd_jac_floor_3f用于计算三层导管架高度及宽度，输入参数Num_floor不等于3，错误调用');
end
end
