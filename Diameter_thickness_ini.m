function [D, t]=Diameter_thickness_ini(legindex_per_floor, braceindex_per_floor, D_leg, D_brace, t_leg, t_brace)
% 该函数用于初始化导管架各杆件直径、壁厚；该代码更新导管架所有杆件的截面尺寸；
% 输入变量：
% - legindex_per_floor：二维数组，导管架各层leg编号，行标为导管架层数，列标为各杆件局部编号；
% - braceindex_per_floor：二维数组，导管架各层leg编号，行标为导管架层数，列标为各杆件局部编号；
% - D_leg：导管架leg初始直径；
% - D_brace：导管架brace初始直径；
% - t_leg：导管架leg初始壁厚；
% - t_brace：导管架brace初始壁厚；
% 输出变量：
% - D：导管架各杆件直径；
% - t：导管架各杆件壁厚；
% 检验输入变量：
global debug;
if debug==1
    if D_leg<0
        error('致命错误：参数D_leg小于0，程序终止运行；检查Diameter_thickness_ini函数输入参数D_leg的取值');
    end
    if D_brace<0
        error('致命错误：参数D_brace小于0，程序终止运行；检查Diameter_thickness_ini函数输入参数D_brace的取值');
    end
    if t_leg<0
        error('致命错误：参数t_leg小于0，程序终止运行；检查Diameter_thickness_ini函数输入参数t_leg的取值');
    end
    if t_brace<0
        error('致命错误：参数t_brace小于0，程序终止运行；检查Diameter_thickness_ini函数输入参数t_brace的取值');
    end
end
% 主函数：
[rows_leg, cols_leg] = size(legindex_per_floor);                            % 获取legindex_per_floor矩阵的行数和列数
[rows_brace, cols_brace] = size(braceindex_per_floor);                      % 获取braceindex_per_floor矩阵的行数和列数
if debug==1
    if rows_leg<0
        error('致命错误：参数rows_leg小于0，程序终止运行；检查Diameter_thickness_ini函数输入矩阵legindex_per_floor的行数');
    end
    if cols_leg<0
        error('致命错误：参数cols_leg小于0，程序终止运行；检查Diameter_thickness_ini函数输入矩阵legindex_per_floor的列数');
    end
    if rows_brace<0
        error('致命错误：参数rows_brace小于0，程序终止运行；检查Diameter_thickness_ini函数输入矩阵braceindex_per_floor的行数');
    end
    if cols_brace<0
        error('致命错误：参数cols_brace小于0，程序终止运行；检查Diameter_thickness_ini函数输入矩阵braceindex_per_floor的列数');
    end
end
% 初始化输出变量D和t，
Number_of_member=rows_leg*cols_leg+rows_brace*cols_brace;
%D=zeros(Number_of_member,1);
%t=zeros(Number_of_member,1);
D=zeros(1,Number_of_member);
t=zeros(1,Number_of_member);
% 为所有leg截面尺寸赋值，
for i=1:rows_leg
    for j=1:cols_leg
        D(legindex_per_floor(i,j))=D_leg;
        t(legindex_per_floor(i,j))=t_leg;
    end
end
% 为所有brace截面尺寸赋值，
for i=1:rows_brace
    for j=1:cols_brace
        D(braceindex_per_floor(i,j))=D_brace;
        t(braceindex_per_floor(i,j))=t_brace;
    end
end
end
