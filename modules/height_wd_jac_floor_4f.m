function [h2,h3,h4,l2,l3,l4]=height_wd_jac_floor_4f(Num_floor,h1,l1,m)
% �ú������ڼ��㵼�ܼܸ���߶ȼ����ȣ�
% �������:
% - Num_floor�����ܼܲ�����
% - h1�����ܼܵ�һ��߶ȣ�
% - l1�����ܼܵ�һ��ײ����ȣ�
% - m�����ܼ���������߶ȱȣ��²�߶ȳ����ϲ�߶ȣ�ȡֵ����1����
% �������:
% - h2�����ܼܵڶ���߶ȣ�
% - h3�����ܼܵ�����߶ȣ�
% - h4�����ܼܵ��Ĳ�߶ȣ�
% - l2�����ܼܵڶ���ײ����ȣ�
% - l3�����ܼܵ�����ײ����ȣ�
% - l4�����ܼܵ��Ĳ�ײ����ȣ�
global debug;
if debug==1
    if h1<0
        error('h10height_wd_jac_floor_4fh1');
    end
    if l1<0
        error('l10height_wd_jac_floor_4fl1');
    end
    if m<0
        error('m0height_wd_jac_floor_4fm');
    end
end
if Num_floor==4
    disp('4');
    % ���㵼�ܼܵڶ���߶�h2��
    h2=m*h1;
    % ���㵼�ܼܵ�����߶�h3��
    h3=m*h2;
    % ���㵼�ܼܵ��Ĳ�߶�h4��
    h4=m*h3;
    % ���㵼�ܼܵڶ���ײ�����l2��
    l2=m*l1;
    % ���㵼�ܼܵ�����ײ�����l3��
    l3=m*l2;
    % ���㵼�ܼܵ��Ĳ�ײ�����l4��
    l4=m*l3;
else
    error('height_wd_jac_floor_4fNum_floor4');
end
end

