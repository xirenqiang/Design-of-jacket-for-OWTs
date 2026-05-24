function [Num_bar]=Bar_num_determine(Num_floor,Num_pile)
% ����������ȷ�����ܼ��ܹ�������;
% ���������
% - Num_floor�����ܼܲ�����
% - Num_pile����׮���ܼ�׮����
% ���������
% - Num_bar�����ܼ��ܸ˼�����
% �����������
global debug;
if debug==1
    if Num_floor ~= 3 && Num_floor ~= 4
        error('34');
    end
    if Num_pile ~= 3 && Num_pile ~= 4
        error('34');
    end
end
% ������
% ���嵼�ܼܸ���leg����leg_num��
leg_num_per_floor = Num_pile;
% ���嵼�ܼܸ���brace����incli_brace_num��
brace_num_per_floor = 2*Num_pile;
% ���㵼�ܼ��ܸ˼�����
Num_bar= (leg_num_per_floor + brace_num_per_floor)*Num_floor;%������
end
