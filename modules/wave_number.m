function [k]=wave_number(T,S)
% ����ˮ��������ڣ�����Airy������k;
% ���������
% - T���������ڣ�
% - S��ƽ��ˮ�
% ���������
% - k��������
global debug;
if debug==1
    if T<0
        error('T0wave_numberT');
    end
    if S<0
        error('S0wave_numberS');
    end
end
% ������㳣����
pi=3.1415926;                                   %�����У�
g=9.8;                                          %�����������ٶȣ�
x0=1.0e-8;                                      %���������ʼֵ��
% �����ʼ����ֵx��
x=(4*pi*pi*S)/(g*T*T*tanh(x0));
i=0;
% ��ʼ��������
while abs(x-x0)>1.0e-8;
    x0=x;
    x=(4*pi*pi*S)/(g*T*T*tanh(x0));
	i=i+1;
end
L=2*pi*S/x;                                     %����;
k=2*pi/L;                                       %����;
end
