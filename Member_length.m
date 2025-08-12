function [L]=Member_length(x0,y0,z0,xt,yt,zt)
%该函数用于计算杆件总长度;
%输入参数:x0,y0,z0分别为杆件起点坐标值;xt,yt,zt分别为杆件终点坐标值;
L=sqrt((xt-x0)^2+(yt-y0)^2+(zt-z0)^2);%构件长度
end
