function y_position = get_center_hydro_load_for_floor_4f(h2,h3,h4,i)
% ����¥��i��ʼ��Num_bar_array
switch i
    case 4
        y_position = 0;%��1��Ĺ�����Ŵ�1��12
    case 3
        y_position = h4;%��2��Ĺ�����Ŵ�1��12��13��24
    case 2
        y_position = h4+h3;%��3��Ĺ�����Ŵ�1��24��25��36
    case 1
        y_position = h4+h3+h2;%��4��Ĺ�����Ŵ�1��36��37��48
    otherwise
        error('get_center_hydro_load_for_floor_4f4');
end
end
