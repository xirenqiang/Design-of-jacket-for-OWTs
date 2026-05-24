function [Num_ele,dL]=Discrete_bar(L,dL_exp)
% �ú������ݸ˼����ȣ�ȷ����Ԫ��������Ԫ���ȣ�
% ���������
% - L���˼����ȣ�
% - dL_exp����Ԫ����Ŀ��ֵ��
%�������:
% - Num_ele���˼����ֵĵ�Ԫ����
% - dL����Ԫ���ȣ�
% ��������б�
global debug;
if debug==1
    if L<0
        error('L0Discrete_barL');
    end
    if dL_exp<0
        error('dL_exp0Discrete_bardL_exp');
    end
end
% ��������
% ���ݵ�Ԫ����Ŀ��ֵ�����㵥ԪԤ������Num_ex��
Num_ex=L/dL_exp;
% ����ԪԤ������Num_exȡ�����õ�ʵ�ʵ�Ԫ����Num_ele��
Num_ele=ceil(Num_ex);
% ���ݵ�Ԫ���ȣ�����ʵ�ʵ�Ԫ���ȣ�
dL=L/Num_ele;
end
