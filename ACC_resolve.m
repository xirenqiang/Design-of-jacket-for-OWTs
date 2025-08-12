function [anx, any, anz]=ACC_resolve(ax, ay, cx, cy, cz) 
%根据流体质点x、y方向加速度分量，计算垂直于杆件方向的加速度矢量在x、y、z方向的分量;
%输入变量:ax、ay分别为流体质点x、y方向加速度分量，cx、cy、cz分别为杆件单位法向量在x、y、z方向的投影;
%输出变量:anx、any和anz分别为流体质点垂直于杆件方向的加速度矢量在x、y、z方向的投影;
% 输入变量：
% - ax：流体质点x方向加速度分量；
% - ay：流体质点y方向加速度分量；
% - cx：杆件单位法向量在x方向的投影;
% - cy：杆件单位法向量在y方向的投影;
% - cz：杆件单位法向量在z方向的投影;
% 输出变量：
% - un：流体质点垂直于杆件方向的速度矢量在x方向的投影;
% - vn：流体质点垂直于杆件方向的速度矢量在y方向的投影;
% - wn：流体质点垂直于杆件方向的速度矢量在z方向的投影;
% 内部变量：
% - a：流体质点垂直于杆件方向的加速度矢量大小；
global debug;
% 输入参数判别
lgth_normal_vector=sqrt(cx^2+cy^2+cz^2);
if debug==1
    if lgth_normal_vector<0.98
        error('致命错误：杆件单位法向量模不等于1，程序终止运行；检查Vel_resolve函数输入参数cx,cy,cz的值');
    end
end
a=sqrt(ax^2+ay^2);
if debug==1
    if a<0
        error('致命错误：流体质点沿法向加速度的模分量小于0，程序终止运行；检查Vel_resolve函数输入参数ax,ay的值');
    end
end
% 主函数：
% 计算流体质点垂直于杆件方向的加速度矢量在x方向的投影anx，
anx=ax-cx*(cx*ax+cy*ay);
% 计算流体质点垂直于杆件方向的加速度矢量在y方向的投影any，
any=ay-cy*(cx*ax+cy*ay);
% 计算流体质点垂直于杆件方向的加速度矢量在z方向的投影anz，
anz=-cz*(cx*ax+cy*ay);
end

