function Diameter_thickness_update(index_floor,legindex_per_floor, braceindex_per_floor, D_leg, D_brace, t_leg, t_brace)
% 该函数用于初始化导管架各杆件直径、壁厚；与函数Diameter_thickness_ini的主要区别是：该代码仅更新index_floor层及以下层杆件的截面尺寸；
% 输入变量：
% - index_floor：当前层的编号；
% - legindex_per_floor：二维数组，导管架各层leg编号，行标为导管架层数，列标为各杆件局部编号；
% - braceindex_per_floor：二维数组，导管架各层leg编号，行标为导管架层数，列标为各杆件局部编号；
% - D_leg：当前层leg的最新直径；
% - D_brace：当前层brace的最新直径；
% - t_leg：当前层leg的最新壁厚；
% - t_brace：当前层brace的最新壁厚；
% 输出变量：该函数直接将执行结果传递给全局变量Member，无需输出变量；
global debug;
global Member;
if debug==1
    if index_floor<0
        error('致命错误：参数D_leg小于0，程序终止运行；检查Diameter_thickness_update函数输入参数index_floor的取值');
    end
    if D_leg<0
        error('致命错误：参数D_leg小于0，程序终止运行；检查Diameter_thickness_update函数输入参数D_leg的取值');
    end
    if D_brace<0
        error('致命错误：参数D_brace小于0，程序终止运行；检查Diameter_thickness_update函数输入参数D_brace的取值');
    end
    if t_leg<0
        error('致命错误：参数t_leg小于0，程序终止运行；检查Diameter_thickness_update函数输入参数t_leg的取值');
    end
    if t_brace<0
        error('致命错误：参数t_brace小于0，程序终止运行；检查Diameter_thickness_update函数输入参数t_brace的取值');
    end
end
% 主函数：
[rows_leg, cols_leg] = size(legindex_per_floor);                            % 获取legindex_per_floor矩阵的行数和列数
[rows_brace, cols_brace] = size(braceindex_per_floor);                      % 获取braceindex_per_floor矩阵的行数和列数
if debug==1
    if rows_leg<0
        error('致命错误：参数rows_leg小于0，程序终止运行；检查Diameter_thickness_update函数输入矩阵legindex_per_floor的行数');
    end
    if cols_leg<0
        error('致命错误：参数cols_leg小于0，程序终止运行；检查Diameter_thickness_update函数输入矩阵legindex_per_floor的列数');
    end
    if rows_brace<0
        error('致命错误：参数rows_brace小于0，程序终止运行；检查Diameter_thickness_update函数输入矩阵braceindex_per_floor的行数');
    end
    if cols_brace<0
        error('致命错误：参数cols_brace小于0，程序终止运行；检查Diameter_thickness_update函数输入矩阵braceindex_per_floor的列数');
    end
end
% 更新当前层(i)到最底层杆件直径Member.D和壁厚Member.t，
for i=index_floor:rows_leg
    % 更新i层所有leg截面尺寸，
    for j=1:cols_leg
        Member.D(legindex_per_floor(i,j))=D_leg;
        Member.t(legindex_per_floor(i,j))=t_leg;
    end
    % 更新i层所有brace截面尺寸，
    for j=1:cols_brace
        Member.D(braceindex_per_floor(i,j))=D_brace;
        Member.t(braceindex_per_floor(i,j))=t_brace;
    end
end
end
