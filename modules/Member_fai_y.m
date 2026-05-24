function [fai_y]=Member_fai_y(x0,y0,z0,xt,yt,zt)
% �ú������ڼ���˼���y������ļн�;
% ���������
% - x0���˼����x����ֵ��
% - y0���˼����y����ֵ��
% - z0���˼����z����ֵ��
% - xt���˼��յ�x����ֵ��
% - yt���˼��յ�y����ֵ��
% - zt���˼��յ�z����ֵ��
% ���������
% - fai_y���˼���y������ļнǣ�
% �����������
global debug;
Length=sqrt((xt-x0)^2+(yt-y0)^2+(zt-z0)^2);
if debug==1
    if Length==0
        error('Member_fai_y');
    end
end
% ��������
if abs(yt-y0)<=1e-6                                         % �˼���xzƽ��ƽ��
    % �˼���y�ᴹֱ�����߼н�fai_yΪ90�ȣ�
    fai_y=90;
else
    % �˼���y��б�����������߼н�fai_y��
    fai_y=atand(sqrt((xt-x0)^2+(zt-z0)^2)/(yt-y0));
end
end
