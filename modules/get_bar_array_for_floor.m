function [Num_bar_array] = get_bar_array_for_floor(i,legindex_per_floor,braceindex_per_floor)
% �ú�������ȷ�����ܼ�1~i����������и˼���ţ�
% ���������
% - i�����ܼܲ�ţ�
% - legindex_per_floor����ά���飬���ܼܸ���leg��ţ��б�Ϊ���ܼܲ������б�Ϊ���˼��ֲ���ţ�
% - braceindex_per_floor����ά���飬���ܼܸ���leg��ţ��б�Ϊ���ܼܲ������б�Ϊ���˼��ֲ���ţ�
rows_leg = size(legindex_per_floor,1);                          % ��ȡlegindex_per_floor���������������
rows_brace = size(braceindex_per_floor,1);                      % ��ȡbraceindex_per_floor���������������
global debug;
if debug==1
    if rows_leg<0
        error('rows_leg0get_bar_array_for_floorlegindex_per_floor');
    end
    if rows_leg~=rows_brace
        error('legindex_per_floorbraceindex_per_floorDiameter_thickness_inilegindex_per_floorbraceindex_per_floor');
    end
end
if rows_leg==4
    switch i
        case 1
            % ȷ����һ��������Num_bar_array
            Num_bar_array = [legindex_per_floor(1,:),braceindex_per_floor(1,:)];
        case 2
            % ȷ��ǰ����������Num_bar_array
            Num_bar_array = [get_bar_array_for_floor(1,legindex_per_floor,braceindex_per_floor),legindex_per_floor(2,:),braceindex_per_floor(2,:)];
        case 3
            % ȷ��ǰ����������Num_bar_array
            Num_bar_array = [get_bar_array_for_floor(2,legindex_per_floor,braceindex_per_floor),legindex_per_floor(3,:),braceindex_per_floor(3,:)];
        case 4
            % ȷ��ǰ�Ĳ�������Num_bar_array
            Num_bar_array = [get_bar_array_for_floor(3,legindex_per_floor,braceindex_per_floor),legindex_per_floor(4,:),braceindex_per_floor(4,:)];
        otherwise
            Num_bar_array = [];%���¥��ų�����Χ���򷵻ؿ�����
    end
elseif rows_leg==3
    switch i
        case 1
            % ȷ����һ��������Num_bar_array
            Num_bar_array = [legindex_per_floor(1,:),braceindex_per_floor(1,:)];%��1��Ĺ�����Ŵ�1��12
        case 2
            % ȷ��ǰ����������Num_bar_array
            Num_bar_array = [get_bar_array_for_floor(1,legindex_per_floor,braceindex_per_floor),legindex_per_floor(2,:),braceindex_per_floor(2,:)];%��2��Ĺ�����Ŵ�1��12��13��24
        case 3
            % ȷ��ǰ����������Num_bar_array
            Num_bar_array = [get_bar_array_for_floor(2,legindex_per_floor,braceindex_per_floor),legindex_per_floor(3,:),braceindex_per_floor(3,:)];%��3��Ĺ�����Ŵ�1��24��25��36
        otherwise
            Num_bar_array = [];%���¥��ų�����Χ���򷵻ؿ�����
    end
else
        error('34');
end
end
