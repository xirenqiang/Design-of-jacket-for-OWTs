function [cita_x]=Member_cita_x(x0,y0,z0,xt,yt,zt)
% �ú������ڼ���˼���y������ļн�ֵ;
% �������:
% - x0���˼����x����ֵ��
% - y0���˼����y����ֵ��
% - z0���˼����z����ֵ��
% - xt���˼��յ�x����ֵ��
% - yt���˼��յ�y����ֵ��
% - zt���˼��յ�z����ֵ��
% ���������
% - cita_x��������xzƽ����ͶӰ��x������ļнǣ�
% �����������
global debug;
Length=sqrt((xt-x0)^2+(yt-y0)^2+(zt-z0)^2);
if debug==1
    if Length==0
        error('Member_fai_y');
    end
end
% ��������
if abs(xt-x0)<=1e-6                                     % �˼�ƽ����yzƽ��
    % �˼���xzƽ���ͶӰ��x�ᴹֱ�����߼н�cita_xΪ90�ȣ�
    cita_x=90*(zt-z0)/abs(zt-z0);
else
    % �˼���xzƽ���ͶӰ��x��б�����������߼н�cita_x��
    cita_x=atand((zt-z0)/(xt-x0));%������xzƽ����ͶӰ��x������ļн�
end
end
