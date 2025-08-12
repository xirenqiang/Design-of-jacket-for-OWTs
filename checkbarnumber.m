function checkbarnumber(Numberofbar,Leg_index_Perfloor,Brace_index_Perfloor)
% 该函数用于判断Numberofbar是否等于Leg_index_Perfloor和Brace_index_Perfloor两个矩阵包含的杆件数量；
% 输入变量：
% - Numberofbar：结构总杆件数量；
% - Leg_index_Perfloor：二维数组，导管架各层leg编号，行标为导管架层数，列标为各杆件局部编号；
% - Brace_index_Perfloor：二维数组，导管架各层leg编号，行标为导管架层数，列标为各杆件局部编号；
% 主函数：
global debug;
[rows_leg, cols_leg] = size(Leg_index_Perfloor);                            % 获取Leg_index_Perfloor矩阵的行数和列数
[rows_brace, cols_brace] = size(Brace_index_Perfloor);                      % 获取Brace_index_Perfloor矩阵的行数和列数
if debug==1
    if Numberofbar<0
        error('致命错误：参数Numberofbar小于0，程序终止运行；检查checkbarnumber函数输入参数Numberofbar的取值');
    end
    if rows_leg<0
        error('致命错误：矩阵Leg_index_Perfloor的行数rows_leg小于0，程序终止运行；检查checkbarnumber函数输入矩阵Leg_index_Perfloor');
    end
    if cols_leg<0
        error('致命错误：矩阵Leg_index_Perfloor的行数cols_leg小于0，程序终止运行；检查checkbarnumber函数输入矩阵Leg_index_Perfloor');
    end
    if rows_brace<0
        error('致命错误：矩阵Brace_index_Perfloor的行数rows_brace小于0，程序终止运行；检查checkbarnumber函数输入矩阵Brace_index_Perfloor');
    end
    if cols_brace<0
        error('致命错误：矩阵Brace_index_Perfloor的行数cols_brace小于0，程序终止运行；检查checkbarnumber函数输入矩阵Brace_index_Perfloor');
    end
end
% 计算导管架leg杆件总数barnumber_leg，
barnumber_leg=rows_leg*cols_leg;
% 计算导管架brace杆件总数barnumber_brace，
barnumber_brace=rows_brace*cols_brace;
% 计算导管架总杆件总数barnumber_from_2_matrices，
barnumber_from_2_matrices=barnumber_leg+barnumber_brace;
% 判断两种方法得到的导管架总杆件数Numberofbar和barnumber_from_2_matrices是否相等，
if debug==1
    if Numberofbar~=barnumber_from_2_matrices
        error('致命错误：直接计算的结构杆件数量Num_bar与各层分别统计得到的杆件数量不相等，');
    end
end
end

