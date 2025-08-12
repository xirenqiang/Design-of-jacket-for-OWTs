function [fai_y]=Member_fai_y(x0,y0,z0,xt,yt,zt)
% 该函数用于计算杆件与y轴正向的夹角;
% 输入参数：
% - x0：杆件起点x坐标值；
% - y0：杆件起点y坐标值；
% - z0：杆件起点z坐标值；
% - xt：杆件终点x坐标值；
% - yt：杆件终点y坐标值；
% - zt：杆件终点z坐标值；
% 输出参数：
% - fai_y：杆件与y轴正向的夹角；
% 输入参数检验
global debug;
Length=sqrt((xt-x0)^2+(yt-y0)^2+(zt-z0)^2);
if debug==1
    if Length==0
        error('致命错误：杆件起点、终点坐标重合，检查Member_fai_y函数输入参数的取值');
    end
end
% 主函数：
if abs(yt-y0)<=1e-6                                         % 杆件与xz平面平行
    % 杆件与y轴垂直，两者夹角fai_y为90度，
    fai_y=90;
else
    % 杆件与y轴斜交，计算两者夹角fai_y，
    fai_y=atand(sqrt((xt-x0)^2+(zt-z0)^2)/(yt-y0));
end
end
