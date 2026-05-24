function [Ftx, Fty, Ftz, Mtx, Mtz] = Hydro_structure(Num_bar_array, t, Y_position)
% �ú������ڼ��㵼�ܼܲ��ֹ�����ˮ�����غ�������ϵ������λ�ڸǲ�˼��ײ�ƽ�����������߽��㴦��
% ���������
% - Num_bar_array��Ϊ�ò���structureˮ�������ؼ����漰���ĸ˼����ϣ��������Ԫ��Ϊ�˼���ţ�
% - tΪ��ǰʱ�̣�
% - Y_positionΪˮ�������ؼ���������Ժ����߶ȣ�
% ���������
% - FtxΪˮ�����ص�x���������
% - FtyΪˮ�����ص�y���������
% - FtzΪˮ�����ص�z�������;
% - MtxΪˮ�����ضԼ�����֮��ʸ��x���������
% - MtzΪˮ�����ضԼ�����֮��ʸ��z�������;
% ����������飺
global debug;
if debug==1
    if t < 0
        error('t0Hydro_structuret');
    end
    if Y_position < 0
        error('Y_positionHydro_structureY_position');
    end
end
% ��������
% ����ȫ�ֱ�����
global Discrete;
global Member;
% ��ʼ�����������
Ftx = 0;                                %ˮ�����غ�����x���������
Fty = 0;                                %ˮ�����غ�����y���������
Ftz = 0;                                %ˮ�����غ�����z���������
Mtx = 0;                                %ˮ�����غ�����x֮�أ�
Mtz = 0;                                %ˮ�����غ�����z֮�أ�
% ��ʼ���ڲ�������
m=length(Num_bar_array);                %�˼�����
F_brax = zeros(m, 1);                   %���˼�ˮ�����ص�x���������
F_bray = zeros(m, 1);                   %���˼�ˮ�����ص�y���������
F_braz = zeros(m, 1);                   %���˼�ˮ�����ص�z���������
M_brx = zeros(m, 1);                    %���˼�ˮ�����ض�x֮�أ�
M_brz = zeros(m, 1);                    %���˼�ˮ�����ض�z֮�أ�
% �����׼����Ĵ���ˮ�����غ�����
for jbrace=1:m
    % ȷ���˼�jbrace�������ţ�
    j = Num_bar_array(jbrace);
    % ����˼�jbrace��ˮ������(���صľ���Ϊ�ø˼��¶˶˵�)��
    [F_brax(jbrace), F_bray(jbrace), F_braz(jbrace), M_brx(jbrace), M_brz(jbrace)] = Hydro_member1(j, Discrete.Num_ele(j), Discrete.dL(j), t);
    % ����˼�j_brace���¶˶˵�y���꣬
    Yb = Member.Y0(j);   
    % ��������ƽ�ƶ�����������j_brace����ӦIDΪj����ˮ�����ء�����ƽ�Ƶ���ϵ�����ģ�
    Ftx = Ftx + F_brax(jbrace);
    Fty = Fty + F_bray(jbrace);
    Ftz = Ftz + F_braz(jbrace);
    Mtx = Mtx + M_brx(jbrace) + F_braz(jbrace)*(Yb-Y_position);
    Mtz = Mtz + M_brz(jbrace) + F_brax(jbrace)*(Yb-Y_position); 
end
end
