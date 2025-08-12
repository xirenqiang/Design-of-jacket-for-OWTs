function [cx,cy,cz]=Direction_bar(fai_y,cita_x)
% 计算杆件单位方向向量;
% 输入参数：
% - fai_y：杆件与y轴正向的夹角；
% - cita_x：构件在xz平面内投影与x轴正向的夹角；
% 输出参数：
% - cx：杆件单位法向量在x方向的投影；
% - cy：杆件单位法向量在y方向的投影；
% - cz：杆件单位法向量在z方向的投影；
% 主函数：
% 计算杆件单位法向量在x方向的投影cx，
cx=sind(fai_y)*cosd(cita_x);
% 计算杆件单位法向量在y方向的投影cy，
cy=cosd(fai_y);
% 计算杆件单位法向量在z方向的投影cz，
cz=sind(fai_y)*sind(cita_x);
end
