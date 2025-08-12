function [h2,h3,h4,l2,l3,l4]=height_wd_jac_floor_4f(Num_floor,h1,l1,m)
% 该函数用于计算导管架各层高度及宽度；
% 输入参数:
% - Num_floor：导管架层数；
% - h1：导管架第一层高度；
% - l1：导管架第一层底部宽度；
% - m：导管架相邻两层高度比（下层高度除以上层高度，取值大于1）；
% 输出参数:
% - h2：导管架第二层高度；
% - h3：导管架第三层高度；
% - h4：导管架第四层高度；
% - l2：导管架第二层底部宽度；
% - l3：导管架第三层底部宽度；
% - l4：导管架第四层底部宽度；
global debug;
if debug==1
    if h1<0
        error('致命错误：参数h1小于0，程序终止运行；检查height_wd_jac_floor_4f函数参数h1');
    end
    if l1<0
        error('致命错误：参数l1小于0，程序终止运行；检查height_wd_jac_floor_4f函数参数l1的取值');
    end
    if m<0
        error('致命错误：参数m小于0，程序终止运行；检查height_wd_jac_floor_4f函数参数m的取值');
    end
end
if Num_floor==4
    disp('本软件将用于设计4层导管架结构');
    % 计算导管架第二层高度h2，
    h2=m*h1;
    % 计算导管架第三层高度h3，
    h3=m*h2;
    % 计算导管架第四层高度h4，
    h4=m*h3;
    % 计算导管架第二层底部宽度l2，
    l2=m*l1;
    % 计算导管架第三层底部宽度l3，
    l3=m*l2;
    % 计算导管架第四层底部宽度l4，
    l4=m*l3;
else
    error('致命错误：函数height_wd_jac_floor_4f用于计算四层导管架高度及宽度，输入参数Num_floor不等于4，错误调用');
end
end

