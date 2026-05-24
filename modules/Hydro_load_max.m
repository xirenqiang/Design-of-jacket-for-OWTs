function [Fxmax, Fymax, Fzmax, Mxmax, Mzmax]=Hydro_load_max(Fxt, Fyt, Fzt, Mxt, Mzt)
% �ú�������ˮ������ʱ�̣�����ṹˮ���������ֵ��
% ���������
% - Fxt�����ܼ�x����ˮ����ʱ�̣�
% - Fyt�����ܼ�y����ˮ����ʱ�̣�
% - Fzt�����ܼ�z����ˮ����ʱ�̣�
% - Mxt�����ܼܹ���x���ˮ�������ʱ�̣�
% - Mzt�����ܼܹ���z���ˮ�������ʱ��;
% �������:
% - Fxmax��x����������
% - Fymax��y����������
% - Fzmax��z����������
% - Mxmax������x���������
% - Mzmax������z���������
% ��������
% �����ڵ�ǰ�㼶�µ�������ֵ
% ����x����������
Fxmax = max(abs(Fxt));
% ����y����������
Fymax = max(abs(Fyt));
% ����z����������
Fzmax = max(abs(Fzt));
% �������x���������
Mxmax = max(abs(Mxt));
% �������z���������
Mzmax = max(abs(Mzt));
end
