function [ax,ay]=ACC_fluid_particle(T,h,k,S,x,y,t)
%根据波浪周期、波高、波数、水深，计算t时刻x、y位置的流体质点加速度;
%输入参数:T为波浪周期、h为波浪高度、k为波数、S为平均水深，Vc为流速，t为时刻，x、y为位置坐标;
%输出参数:ax、ay分别为流体质点沿x、y方向加速度;
pi=3.1415926; %常数π;
omiga=2*pi/T; %圆频率;
ax=(omiga^2)*(h/2)*cosh(k*y)/sinh(k*S)*sin(k*x-omiga*t);
ay=-(omiga^2)*(h/2)*sinh(k*y)/sinh(k*S)*cos(k*x-omiga*t);
end