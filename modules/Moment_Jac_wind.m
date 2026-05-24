function [M]=Moment_Jac_wind(Fw,h_tower,h_jacket,y_position)
% �ú������ڼ��������ڵ��ܼ����������أ�
% ���������
% - Fw������غ�����
% - h_tower�����ܸ߶ȣ�
% - h_jacket�����ܼܸ߶ȣ�
% - y_position�������������߶ȣ�
% ���������
% - M������ض�y_positionλ��֮�أ�
% ��������
global debug;
if debug==1
    if Fw<0
        error('Fw0Moment_Jac_windFw');
    end
    if h_tower<0
        error('h_tower0Moment_Jac_windh_tower');
    end
    if h_jacket<0
        error('h_jacket0Moment_Jac_windh_jacket');
    end
    if y_position<0
        error('y_position0Moment_Jac_windy_position');
    end
end
% ��������
M=Fw*(h_tower+h_jacket-y_position);
end
