function [Vc]=Current_vel(U_ss0, U_ns0, z, d, h_ref)
%该函数用于确定相对海床高度为z位置处的海流速度，此处竖向坐标轴为z轴，向上为正，原点在海床位置;
%输入变量：
% - U_ss0：海平面处的表层流速度；
% - U_w0：海平面处次表层流速度；
% - z：相对海床高度；
% - d：海水深度；
% - h_ref：表层流深度；
%输出变量：
% - Vc：海流总速度；
% 输入参数判别：
global debug;
if debug==1
    if U_ss0<0
        error('致命错误：参数U_ss0小于0，程序终止运行；检查Current_vel函数输入参数U_ss0的取值');
    end
    if U_ns0<0
        error('致命错误：参数U_ns0小于0，程序终止运行；检查Current_vel函数输入参数U_ns0的取值');
    end
    if z<0
        error('致命错误：参数z小于0，程序终止运行；检查Current_vel函数输入参数z的取值');
    end
    if d<0
        error('致命错误：参数d小于0，程序终止运行；检查Current_vel函数输入参数d的取值');
    end
end
% 主函数：
% Sub-surface current引起的流速U_ssz，
if z<=d
    U_ssz=U_ss0*(z/d)^(1/7);
else
    U_ssz=0;
end
% Near-surface current引起的流速U_wz，
if z>=(d-h_ref)
    U_wz=U_ns0*(1+(z-d)/h_ref);
else
    U_wz=0;
end
Vc=U_ssz+U_wz;
end
