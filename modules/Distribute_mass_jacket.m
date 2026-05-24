function [m_dis]=Distribute_mass_jacket(N,steel_density,hj)
%�ú������ڼ��㵼�ܼ�����;
%�������:���ܼ��ܸ˼���N
%�������
global Member;
M=0;
m=zeros(N,1);
for i=1:N
    m(i)=Member.L(i)*0.25*3.14*((Member.D(i))^2-(Member.D(i)-2*Member.t(i))^2)*steel_density;
    M=M+m(i);
end
m_dis=M/hj;
end
       