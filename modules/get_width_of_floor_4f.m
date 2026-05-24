function [Width] = get_width_of_floor_4f(i,l1,l2,l3,l4)
% �ú������ڷ��ص��ܼܵ�i��ײ����ȣ�
% ���������
% -i�����ܼܲ�ţ�
% -l1�����ܼܵ�һ��ײ����ȣ�
% -l2�����ܼܵڶ���ײ����ȣ�
% -l3�����ܼܵ�����ײ����ȣ�
% -l4�����ܼܵ��Ĳ�ײ����ȣ�
% ���������
% -Width�����ܼ�i��ײ����ȣ�
switch i
    case 1
        Width = l1;                                     %���ܼܵ�1��ײ�����
    case 2
        Width = l2;                                     %���ܼܵ�2��ײ�����
    case 3
        Width = l3;                                     %���ܼܵ�3��ײ�����
    case 4
        Width = l4;                                     %���ܼܵ�4��ײ�����
    otherwise
        error('get_width_of_floor_4f1i');
end
end
