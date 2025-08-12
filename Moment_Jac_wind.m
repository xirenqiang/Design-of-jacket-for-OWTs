function [M]=Moment_Jac_wind(Fw,height_hub,depth_water,y_position)
% 该函数用于计算风荷载在导管架中引起的弯矩；
% 输入参数：
% - Fw：风荷载合力；
% - height_hub：轮毂相对于平面海平面高度；
% - depth_water：平均海水深度；
% - y_position：矩心相对泥面高度；
% 输出参数：
% - M：风荷载对y_position位置之矩；
% 主函数：
global debug;
if debug==1
    if Fw<0
        error('致命错误：风荷载Fw小于0，程序运行终止；检查Moment_Jac_wind函数输入参数Fw');
    end
    if h_tower<0
        error('致命错误：塔架高度h_tower小于0，程序运行终止；检查Moment_Jac_wind函数输入参数h_tower');
    end
    if h_jacket<0
        error('致命错误：风荷载h_jacket小于0，程序运行终止；检查Moment_Jac_wind函数输入参数h_jacket');
    end
    if y_position<0
        error('致命错误：风荷载y_position小于0，程序运行终止；检查Moment_Jac_wind函数输入参数y_position');
    end
end
% 主函数：
M=Fw*(height_hub+depth_water-y_position);
end
