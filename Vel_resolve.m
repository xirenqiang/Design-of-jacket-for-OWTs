function [V, un, vn, wn]=Vel_resolve(u, v, cx, cy, cz)
% 该函数根据流体质点x、y方向速度分量，计算垂直于杆件方向的速度矢量V大小及其在x、y、z方向的分量;
% 输入变量：
% - u：流体质点x方向速度分量；
% - v：流体质点y方向速度分量；
% - cx：杆件单位法向量在x方向的投影；
% - cy：杆件单位法向量在y方向的投影；
% - cz：杆件单位法向量在z方向的投影；
% 输出变量：
% - V：流体质点垂直于杆件方向的速度矢量大小；
% - un：流体质点垂直于杆件方向的速度矢量在x方向的投影；
% - vn：流体质点垂直于杆件方向的速度矢量在y方向的投影；
% - wn：流体质点垂直于杆件方向的速度矢量在z方向的投影；
% 输入参数判别
global debug;
lgth_normal_vector=sqrt(cx^2+cy^2+cz^2);
if debug==1
    if lgth_normal_vector<0.98
        error('致命错误：杆件单位法向量模不等于1，程序终止运行；检查Vel_resolve函数输入参数cx,cy,cz的值');
    end
end
% 主函数：
% 计算流体质点垂直于杆件方向的速度矢量大小V，
V=sqrt(u^2+v^2-(cx*u+cy*v)^2);
if debug==1
    if V<0
        error('致命错误：流体质点沿法向速度分量的模小于0，程序终止运行；检查Vel_resolve函数输入参数u,v的值');
    end
end
% 计算流体质点垂直于杆件方向的速度矢量在x方向的投影un，
un=u-cx*(cx*u+cy*v);
% 计算流体质点垂直于杆件方向的速度矢量在y方向的投影vn，
vn=v-cy*(cx*u+cy*v);
% 计算流体质点垂直于杆件方向的速度矢量在z方向的投影wn，
wn=-cz*(cx*u+cy*v);
end
