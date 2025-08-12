function y_position = get_center_hydro_load_for_floor_3f(h2,h3,i)
% 根据楼层i初始化Num_bar_array
switch i
    case 3
        y_position = 0;%第2层的构件编号从1到12和13到24
    case 2
        y_position = h3;%第3层的构件编号从1到24和25到36
    case 1
        y_position = h3+h2;%第4层的构件编号从1到36和37到48
    otherwise
        error('致命错误：楼层号超出范围，检验get_center_hydro_load_for_floor_3f的第3个输入变量');
end
end
