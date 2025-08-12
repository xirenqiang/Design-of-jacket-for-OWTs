function [anx,any,anz]=ACC_resolve(ax,ay,cx,cy,cz) 
%根据流体质点x、y方向加速度分量，计算垂直于杆件方向的加速度矢量在x、y、z方向的分量;
%输入变量:ax、ay分别为流体质点x、y方向加速度分量，cx、cy、cz分别为杆件单位法向量在x、y、z方向的投影;
%输出变量:anx、any和anz分别为流体质点垂直于杆件方向的加速度矢量在x、y、z方向的投影;
anx=ax-cx*(cx*ax+cy*ay);
any=ay-cy*(cx*ax+cy*ay);
anz=-cz*(cx*ax+cy*ay);
end