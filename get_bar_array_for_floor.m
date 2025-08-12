function [Num_bar_array] = get_bar_array_for_floor(i,legindex_per_floor,braceindex_per_floor)
% 该函数用于确定导管架1~i层包含的所有杆件编号；
% 输入参数：
% - i：导管架层号；
% - legindex_per_floor：二维数组，导管架各层leg编号，行标为导管架层数，列标为各杆件局部编号；
% - braceindex_per_floor：二维数组，导管架各层leg编号，行标为导管架层数，列标为各杆件局部编号；
rows_leg = size(legindex_per_floor,1);                          % 获取legindex_per_floor矩阵的行数和列数
rows_brace = size(braceindex_per_floor,1);                      % 获取braceindex_per_floor矩阵的行数和列数
global debug;
if debug==1
    if rows_leg<0
        error('致命错误：参数rows_leg小于0，程序终止运行；检查get_bar_array_for_floor函数输入矩阵legindex_per_floor的行数');
    end
    if rows_leg~=rows_brace
        error('致命错误：矩阵legindex_per_floor和braceindex_per_floor行数不同，程序终止运行；检查Diameter_thickness_ini函数输入参数legindex_per_floor和braceindex_per_floor');
    end
end
if rows_leg==4
    switch i
        case 1
            % 确定第一层编号数组Num_bar_array
            Num_bar_array = [legindex_per_floor(1,:),braceindex_per_floor(1,:)];
        case 2
            % 确定前两层编号数组Num_bar_array
            Num_bar_array = [get_bar_array_for_floor(1,legindex_per_floor,braceindex_per_floor),legindex_per_floor(2,:),braceindex_per_floor(2,:)];
        case 3
            % 确定前三层编号数组Num_bar_array
            Num_bar_array = [get_bar_array_for_floor(2,legindex_per_floor,braceindex_per_floor),legindex_per_floor(3,:),braceindex_per_floor(3,:)];
        case 4
            % 确定前四层编号数组Num_bar_array
            Num_bar_array = [get_bar_array_for_floor(3,legindex_per_floor,braceindex_per_floor),legindex_per_floor(4,:),braceindex_per_floor(4,:)];
        otherwise
            Num_bar_array = [];%如果楼层号超出范围，则返回空数组
    end
elseif rows_leg==3
    switch i
        case 1
            % 确定第一层编号数组Num_bar_array
            Num_bar_array = [legindex_per_floor(1,:),braceindex_per_floor(1,:)];%第1层的构件编号从1到12
        case 2
            % 确定前两层编号数组Num_bar_array
            Num_bar_array = [get_bar_array_for_floor(1,legindex_per_floor,braceindex_per_floor),legindex_per_floor(2,:),braceindex_per_floor(2,:)];%第2层的构件编号从1到12和13到24
        case 3
            % 确定前三层编号数组Num_bar_array
            Num_bar_array = [get_bar_array_for_floor(2,legindex_per_floor,braceindex_per_floor),legindex_per_floor(3,:),braceindex_per_floor(3,:)];%第3层的构件编号从1到24和25到36
        otherwise
            Num_bar_array = [];%如果楼层号超出范围，则返回空数组
    end
else
        error('致命错误：导管架层数不等于3或者4，运行终止；本软件用于三、四层导管架设计');
end
end
