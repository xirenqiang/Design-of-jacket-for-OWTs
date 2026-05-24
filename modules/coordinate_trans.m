function [xg,yg,zg]=coordinate_trans(xb,yb,zb,pesai)
% Rotate (X,Z) in the code horizontal plane by pesai deg about vertical Y.
% Same convention as paper_code_mapping.rotation_matrix_code_xz (Step 3).
% �ú�����ԭ����ϵ��һ����y����תpesai��
% ���������
% - xb���任ǰ��x����ֵ��
% - yb���任ǰ��y����ֵ��
% - zb���任ǰ��z����ֵ��
% ���������
% - xg���任���x����ֵ��
% - yg���任���y����ֵ��
% - zg���任���z����ֵ��
% ��������
% ��ʼ������ת������
A=zeros(2,2);
% ��������ת������A��
A=[cosd(pesai),sind(pesai);-sind(pesai),cosd(pesai)];
% ����任���x��z����������coor_xz��
coor_xz=A*[xb;zb];
% ����������coor_xz�ĵ�һ��ֵ�����任���x����xg��
xg=coor_xz(1);
% ����������coor_xz�ĵڶ���ֵ�����任���z����zg��
zg=coor_xz(2);
% ȷ���任���y����yg��
yg=yb;
end
