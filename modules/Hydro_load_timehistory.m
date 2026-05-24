function [Ftx, Fty, Ftz, Mtx, Mtz, t]=Hydro_load_timehistory(t0, t1, dt, Num_bar_array, y0_position)
%�ú������ڼ���һ��ʱ���ڸ˼�����Num_bar_array�ܵ���ˮ�����غ�����
%���������
% - t0����ʼʱ�̣�
% - t1������ʱ�̣�
% - dt��ʱ������
% - Num_bar_array���˼����ϣ��ü����ǵ�ǰ����ˮ�������漰���ĸ˼����ϣ�
%���������
% - Ftx�����ܼܸ˼��������ܲ��˺�����x����ĺ���ʱ�̣�
% - Fty�����ܼܸ˼��������ܲ��˺�����y����ĺ���ʱ�̣�
% - Ftz�����ܼܸ˼��������ܲ��˺�����z����ĺ���ʱ�̣�
% - Mtx�����ܼܸ˼��������ܲ��˺��ض�x��֮�أ�
% - Mtz�����ܼܸ˼��������ܲ��˺�����x��֮�أ�
% - t��ʱ�����У�
global debug;
if debug==1
    if t1 < t0
        error('Hydro_load_timehistoryt0t1');
    end
    if dt < 0
        error('dt0Hydro_load_timehistorydt');
    end
end
% ��������
% ����ʱ�䲽��N��
N=(t1-t0)/dt+1;
% ��ʼ�����������
t=zeros(N,1);                                       %ʱ�����У�
Ftx=zeros(N,1);                                     %ˮ�����غ�����x���������
Fty=zeros(N,1);                                     %ˮ�����غ�����y���������
Ftz=zeros(N,1);                                     %ˮ�����غ�����z���������
Mtx=zeros(N,1);                                     %ˮ�����غ�����x��֮�أ�
Mtz=zeros(N,1);                                     %ˮ�����غ�����y��֮�أ�
for i=1:N                                           %��ʱ�䲽i����ѭ��;
    % ���㵱ǰʱ�̣�
    t(i)=(i-1)*dt;
    if debug==1
        % ��鵱ǰʱ����Ƿ�С�� t0��
        if t(i) < t0
            fprintf('(t(%d) = %f) \n', i, t(i));
            error('Runtime validation failed.')
            % ��鵱ǰʱ����Ƿ���� t1
        elseif t(i) > t1
            fprintf('(t(%d) = %f) \n', i, t(i));
            error('Runtime validation failed.')
        end
    end
    %����Hydro_structure����������t(i)ʱ�̵��ܼ��ܵ���ˮ��������
    [Ftx(i),Fty(i),Ftz(i),Mtx(i),Mtz(i)]=Hydro_structure(Num_bar_array,t(i),y0_position);%�˴���Ҫ����ˮ�����ؼ�������еĺ��ؼ������������ꣻ
end
end
