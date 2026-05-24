function [h2,h3,l2,l3]=height_wd_jac_floor_3f(Num_floor,h1,l1,m)
% �ú������ڼ��㵼�ܼܸ���߶ȼ�����;
% �������:
% - Num_floor�����ܼܲ�����
% - h1�����ܼܵ�һ��߶ȣ�
% - l1�����ܼܵ�һ�㶥���ȣ�
% - m�����ܼ���������߶ȱȣ��²�߶ȳ����ϲ�߶ȣ�ȡֵ����1����
% �������:
% - h2�����ܼܵڶ���߶ȣ�
% - h3�����ܼܵ�����߶ȣ�
% - l2�����ܼܵڶ��㶥���ȣ�
% - l3�����ܼܵ����㶥���ȣ�
% - L_bottom�����ܼܵ�һ�㶥���ȣ�
global debug;
if debug==1
    if h1<0
        error('h10height_wd_jac_floor_3fh1');
    end
    if l1<0
        error('l10height_wd_jac_floor_3fl1');
    end
    if m<0
        error('m0height_wd_jac_floor_3fm');
    end
end
if Num_floor==3
    % ���㵼�ܼܵڶ���߶�h2��
    h2=m*h1;
    % ���㵼�ܼܵ�����߶�h3��
    h3=m*h2;
    % ���㵼�ܼܵڶ��㶥����l2��
    l2=m*l1;
    % ���㵼�ܼܵ����㶥����l2��
    l3=m*l2;
else
    error('height_wd_jac_floor_3fNum_floor3');
end
end
