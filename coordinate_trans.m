function [xg,yg,zg]=coordinate_trans(xb,yb,zb,pesai)
% 该函数将原坐标系内一点绕y轴旋转pesai；
% 输入参数：
% - xb：变换前的x坐标值；
% - yb：变换前的y坐标值；
% - zb：变换前的z坐标值；
% 输出参数：
% - xg：变换后的x坐标值；
% - yg：变换后的y坐标值；
% - zg：变换后的z坐标值；
% 主函数：
% 初始化坐标转换矩阵，
A=zeros(2,2);
% 计算坐标转换矩阵A，
A=[cosd(pesai),sind(pesai);-sind(pesai),cosd(pesai)];
% 计算变换后的x、z轴坐标向量coor_xz，
coor_xz=A*[xb;zb];
% 将坐标向量coor_xz的第一个值赋给变换后的x坐标xg，
xg=coor_xz(1);
% 将坐标向量coor_xz的第二个值赋给变换后的z坐标zg，
zg=coor_xz(2);
% 确定变换后的y坐标yg，
yg=yb;
end
