function [Ftx, Fty, Ftz, Mtx, Mtz] = Hydro_structure(Num_bar_array, t, Y_position)
% 该函数用于计算导管架部分构件的水动荷载合力，力系简化中心位于盖层杆件底部平面与塔架轴线交点处；
% 输入参数：
% - Num_bar_array：为该部分structure水动力荷载计算涉及到的杆件集合，该数组各元素为杆件编号；
% - t为当前时刻；
% - Y_position为水动力荷载计算中心相对海床高度；
% 输出参数：
% - Ftx为水动荷载的x方向分量；
% - Fty为水动荷载的y方向分量；
% - Ftz为水动荷载的z方向分量;
% - Mtx为水动荷载对简化中心之矩矢的x方向分量；
% - Mtz为水动荷载对简化中心之矩矢的z方向分量;
% 输入参数检验：
global debug;
if debug==1
    if t < 0
        error('致命错误：当前时刻t小于0，程序运行终止；请检查Hydro_structure函数的输入时间参数t');
    end
    if Y_position < 0
        error('致命错误：计算点位置Y_position低于海床平面，程序运行终止；请检查Hydro_structure函数的输入参数Y_position');
    end
end
% 主函数：
% 引用全局变量：
global Discrete;
global Member;
% 初始化输出变量，
Ftx = 0;                                %水动荷载合力的x方向分量；
Fty = 0;                                %水动荷载合力的y方向分量；
Ftz = 0;                                %水动荷载合力的z方向分量；
Mtx = 0;                                %水动荷载合力对x之矩；
Mtz = 0;                                %水动荷载合力对z之矩；
% 初始化内部变量，
m=length(Num_bar_array);                %杆件数量
F_brax = zeros(m, 1);                   %各杆件水动荷载的x方向分量；
F_bray = zeros(m, 1);                   %各杆件水动荷载的y方向分量；
F_braz = zeros(m, 1);                   %各杆件水动荷载的z方向分量；
M_brx = zeros(m, 1);                    %各杆件水动荷载对x之矩；
M_brz = zeros(m, 1);                    %各杆件水动荷载对z之矩；
% 计算层底简化中心处的水动荷载合力，
for jbrace=1:m
    % 确定杆件jbrace的整体编号，
    j = Num_bar_array(jbrace);
    % 计算杆件jbrace的水动荷载(力矩的矩心为该杆件下端端点)，
    [F_brax(jbrace), F_bray(jbrace), F_braz(jbrace), M_brx(jbrace), M_brz(jbrace)] = Hydro_member1(j, Discrete.Num_ele(j), Discrete.dL(j), t);
    % 计算杆件j_brace的下端端点y坐标，
    Yb = Member.Y0(j);   
    % 采用力的平移定理，将构件j_brace（对应ID为j）的水动荷载、力矩平移到力系简化中心；
    Ftx = Ftx + F_brax(jbrace);
    Fty = Fty + F_bray(jbrace);
    Ftz = Ftz + F_braz(jbrace);
    Mtx = Mtx + M_brx(jbrace) + F_braz(jbrace)*(Yb-Y_position);
    Mtz = Mtz + M_brz(jbrace) + F_brax(jbrace)*(Yb-Y_position); 
end
end
