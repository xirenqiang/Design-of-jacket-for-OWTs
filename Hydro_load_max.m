function [Fxmax, Fymax, Fzmax, Mxmax, Mzmax]=Hydro_load_max(Fxt, Fyt, Fzt, Mxt, Mzt)
% 该函数根据水动荷载时程，计算结构水动荷载最大值；
% 输入变量：
% - Fxt：导管架x方向水动力时程；
% - Fyt：导管架y方向水动力时程；
% - Fzt：导管架z方向水动力时程；
% - Mxt：导管架关于x轴的水动力弯矩时程；
% - Mzt：导管架关于z轴的水动力弯矩时程;
% 输出变量:
% - Fxmax：x方向最大荷载
% - Fymax：y方向最大荷载
% - Fzmax：z方向最大荷载
% - Mxmax：关于x轴最大力矩
% - Mzmax：关于z轴最大力矩
% 主函数：
% 计算在当前层级下的最大荷载值
% 计算x方向最大荷载
Fxmax = max(abs(Fxt));
% 计算y方向最大荷载
Fymax = max(abs(Fyt));
% 计算z方向最大荷载
Fzmax = max(abs(Fzt));
% 计算关于x轴最大力矩
Mxmax = max(abs(Mxt));
% 计算关于z轴最大力矩
Mzmax = max(abs(Mzt));
end
