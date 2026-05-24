function [Fx, Fy, Fz, Mx, Mz]=Hydro_member1(i, N, dt_L, t)
% �ú������ڼ���ˮ�¸˼�i��ˮ��������ʱ��;
% ���������
% - i: �������;
% - N: �˼��ĵ�Ԫ��;
% - dt_L: ��Ԫ����;
% - t: ��ǰʱ��;
% - pesai: �ṹ����ֱ�ᣨ������Ϊy�ᣩ����ת���Ƕȣ����ڴ�����-���˷���һ��;
% ���������
% - Fx: x����ˮ��;
% - Fy: y����ˮ��;
% - Fz: z����ˮ��;
% - Mx: ����;
% - Mz: ����;
% ����������飺
global debug;
if debug==1
    if i < 0
        error('i0Hydro_member1i');
    end
    if N < 0
        error('N0Hydro_member1N');
    end
    if dt_L < 0
        error('dt_L0Hydro_member1dt_L');
    end
    if t < 0
        error('t0Hydro_member1t');
    end
end
% ������ʼ����
% ����ȫ�ֱ�����
global Member;
global Wave;
global Hydro;
global Current;
global Discrete;
% ��ʼ�����������
Fx=0;
Fy=0;
Fz=0;
Mx=0;
Mz=0;
% ��ʼ���ֲ�������
pi=3.14;
x=zeros(N,1);
y=zeros(N,1);
z=zeros(N,1);
ux=zeros(N,1);
vy=zeros(N,1);
V=zeros(N,1);
un=zeros(N,1);
vn=zeros(N,1);
wn=zeros(N,1);
ax=zeros(N,1);
ay=zeros(N,1);
anx=zeros(N,1);
any=zeros(N,1); 
anz=zeros(N,1);
% ����������
w=2*3.14/Wave.T;                                        % angular frequency
beta_wave = resolve_wave_beta_propagation();
% ���㹹������Ԫ��x��y��z��������(���õȳ��ȵ�Ԫ)��
dx=(Member.Xt(i)-Member.X0(i))/Discrete.Num_ele(i);     %����i����Ԫx��������
dy=(Member.Yt(i)-Member.Y0(i))/Discrete.Num_ele(i);     %����i����Ԫy��������
dz=(Member.Zt(i)-Member.Z0(i))/Discrete.Num_ele(i);     %����i����Ԫz��������
for j=1:N                                               %��ʱ�䲽j����ѭ��;
    % ����j��Ԫ�е�x��y��z���꣺
    x(j)=Member.X0(i)+(j-0.5)*dx;                       %j��Ԫ�е㴦x����
    y(j)=Member.Y0(i)+(j-0.5)*dy;                       %j��Ԫ�е㴦y����
    z(j)=Member.Z0(i)+(j-0.5)*dz;                       %j��Ԫ�е㴦z����
    % ����tʱ�̣�x(j,1)λ�ô�����ˮ��߶�(�����ƽ��ˮ��λ��)��
    h_surface=surface_elevation(Wave.h,Wave.k,x(j),t,w,z(j),beta_wave);
    % ����j��Ԫ��ˮѹ������ƽ����������ʼ�ڵ㴦��
    if y(j)<=(Wave.S+h_surface)
        % ˮ�ʵ��˶�ѧ�������㣺
        % ����tʱ�̣�y(j)��ȴ�(����ں���)ˮ���ٶȣ�
        Vc=Current_vel(Current.U_ss0,Current.U_ns0,y(j),Wave.S,Current.h_ref);
        % ��ǰʱ��t��x(j)��y(j)λ�ô���ˮ�ʵ����ٶȣ�
        [ux(j),vy(j)]=Vel_fluid_particle(Wave.T,Wave.h,Wave.k,Wave.S,Vc,x(j),y(j),t,z(j),beta_wave);
        [ax(j),ay(j)]=ACC_fluid_particle(Wave.T,Wave.h,Wave.k,Wave.S,x(j),y(j),t,z(j),beta_wave);
        % �ٶ�ʸ���ֽ⣻
        [V(j),un(j),vn(j),wn(j)]=Vel_resolve(ux(j),vy(j),Member.cx(i),Member.cy(i),Member.cz(i));
        % ���ٶ�ʸ���ֽ⣻
        [anx(j),any(j),anz(j)]=ACC_resolve(ax(j),ay(j),Member.cx(i),Member.cy(i),Member.cz(i));
        % ����Morison��ʽ����ˮ�������أ�
        % ��ǰ��Ԫx����ˮ�����أ�
        Fjx=(0.5*Hydro.density*Member.D(i)*Hydro.cd*V(j)*un(j)+0.25*Hydro.density*pi*(Member.D(i))^2*Hydro.cm*anx(j))*dt_L;
        % ��ǰ��Ԫx����ˮ�����ض�y��֮�أ�
        Mjz=Fjx*(j-0.5)*dy;
        % ��ǰ��Ԫy����ˮ�����أ�
        Fjy=(0.5*Hydro.density*Member.D(i)*Hydro.cd*V(j)*vn(j)+0.25*Hydro.density*pi*(Member.D(i))^2*Hydro.cm*any(j))*dt_L; %
        % ��ǰ��Ԫz����ˮ�����أ�
        Fjz=(0.5*Hydro.density*Member.D(i)*Hydro.cd*V(j)*wn(j)+0.25*Hydro.density*pi*(Member.D(i))^2*Hydro.cm*anz(j))*dt_L; %
        % ��ǰ��Ԫz����ˮ�����ض�x��֮�أ�
        Mjx=Fjz*(j-0.5)*dy;
    else
        Fjx=0;
        Mjz=0;
        Fjy=0;
        Fjz=0;
        Mjx=0;
    end
    %��j��Ԫ��ˮ��������������ǰj-1����Ԫ��ˮ�����أ�
    Fx=Fx+Fjx;
	Fy=Fy+Fjy;
	Fz=Fz+Fjz;
    Mx=Mx+Mjx;
	Mz=Mz+Mjz;
end
end
