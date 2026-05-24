function [Width] = get_width_of_floor_3f(i,l1,l2,l3)
% �ú������ڷ��ص��ܼܵ�i��ײ����ȣ�
% ���������
% -i�����ܼܲ�ţ�
% -l1�����ܼܵ�һ��ײ����ȣ�
% -l2�����ܼܵڶ���ײ����ȣ�
% -l3�����ܼܵ�����ײ����ȣ�
% ���������
% -Width�����ܼ�i��ײ����ȣ�
switch i
    case 1
        Width = l1;                                     %���ܼܵ�1��ײ�����
    case 2
        Width = l2;                                     %���ܼܵ�2��ײ�����
    case 3
        Width = l3;                                     %���ܼܵ�3��ײ�����
    otherwise
        error('get_width_of_floor_3f1i');
end
end
