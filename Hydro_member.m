function [Fx,Fy,Fz,Mx,Mz]=Hydro_member1(i,N,dt_L,t,pesai)
% 该函数用于计算水下杆件的水动力荷载时程;
% 输入参数：
% - i: 构件编号;
% - N: 结构物的单元数;
% - dt_L: 单元长度;
% - t: 当前时刻;
% - pesai: 结构绕竖直轴（本程序为y轴）整体转动角度，用于代表风-波浪方向不一致;
% 返回结果：
% - Fx: x方向动水力;
% - Fy: y方向动水力;
% - Fz: z方向动水力;
% - M: 力矩;
% 引用全局变量
global Member;
global Wave;
global Hydro;
global Current;
% 定义局部变量
x=zeros(N,1);
y=zeros(N,1);
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
Fx=0;
Fy=0;
Fz=0;
Mx=0;
Mz=0;
for j=1:N
    y(j)=Member.Y0(i)+(j-0.5)*dt_L*cosd(Member.fai_y(i));
%     x(j)=Member.X0(i)+(j-0.5)*dt_L*sind(Member.fai_y(i))*sind(Member.cita_x(i));
    A=[cosd(pesai),sind(pesai);-sind(pesai),cosd(pesai)]*[Member.X0(i)+(j-0.5)*dt_L*sind(Member.fai_y(i))*cosd(Member.cita_x(i));Member.Y0(i)+(j-0.5)*dt_L*sind(Member.fai_y(i))*sind(Member.cita_x(i))];
    x(j,1)=A(1,1);
    [ux(j),vy(j)]=Vel_fluid_particle(Wave.T,Wave.h,Wave.k,Wave.S,Current.Vc,x(j),y(j),t);
    [ax(j),ay(j)]=ACC_fluid_particle(Wave.T,Wave.h,Wave.k,Wave.S,x(j),y(j),t);
    [V(j),un(j),vn(j),wn(j)]=Vel_resolve(ux(j),vy(j),Member.cx(i),Member.cy(i),Member.cz(i));
    [anx(j),any(j),anz(j)]=ACC_resolve(ax(j),ay(j),Member.cx(i),Member.cy(i),Member.cz(i));
    Fjx=(0.5*Hydro.density*Member.D(i)*Hydro.cd*V(j)*un(j)+0.25*Hydro.density*pi*(Member.D(i))^2*Hydro.cm*anx(j))*dt_L; %
    Mjz=Fjx*y(j);
    Fjy=(0.5*Hydro.density*Member.D(i)*Hydro.cd*V(j)*vn(j)+0.25*Hydro.density*pi*(Member.D(i))^2*Hydro.cm*any(j))*dt_L; %
    Fjz=(0.5*Hydro.density*Member.D(i)*Hydro.cd*V(j)*wn(j)+0.25*Hydro.density*pi*(Member.D(i))^2*Hydro.cm*anz(j))*dt_L;
    Mjx=Fjz*y(j);
    
    Fx=Fx+Fjx;
	Fy=Fy+Fjy;
	Fz=Fz+Fjz;
    Mx=Mx+Mjx;
	Mz=Mz+Mjz;
end
end

