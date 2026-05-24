function [L]=Member_length(x0,y0,z0,xt,yt,zt)
%�ú������ڼ���˼��ܳ���;
%�������:x0,y0,z0�ֱ�Ϊ�˼��������ֵ;xt,yt,zt�ֱ�Ϊ�˼��յ�����ֵ;
L=sqrt((xt-x0)^2+(yt-y0)^2+(zt-z0)^2);%��������
end
