function [Fx, Fy, Fz, Mx, Mz]=Hydro_member1(i, N, dt_L, t)
% 该函数用于计算水下杆件i的水动力荷载时程;
% 输入参数：
% - i: 构件编号;
% - N: 杆件的单元数;
% - dt_L: 单元长度;
% - t: 当前时刻;
% - pesai: 结构绕竖直轴（本程序为y轴）整体转动角度，用于代表风-波浪方向不一致;
% 输出参数：
% - Fx: x方向动水力;
% - Fy: y方向动水力;
% - Fz: z方向动水力;
% - Mx: 力矩;
% - Mz: 力矩;
% 输入参数检验：
global debug;
if debug==1
    if i < 0
        error('致命错误：构件编号i小于0，程序运行终止；请检查Hydro_member1函数的输入参数i');
    end
    if N < 0
        error('致命错误：构件单元数量N小于0，程序运行终止；请检查Hydro_member1函数的输入参数N');
    end
    if dt_L < 0
        error('致命错误：构件单元长度dt_L小于0，程序运行终止；请检查Hydro_member1函数的输入参数dt_L');
    end
    if t < 0
        error('致命错误：当前时刻t小于0，程序运行终止；请检查Hydro_member1函数的输入时间参数t');
    end
end
% 函数初始化：
% 引用全局变量：
global Member;
global Wave;
global Hydro;
global Current;
global Discrete;
% 初始化输出变量；
Fx=0;
Fy=0;
Fz=0;
Mx=0;
Mz=0;
% 初始化局部变量；
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
% 函数主程序；
w=2*3.14/Wave.T;                                        %波浪角频率；
% 计算构件各单元的x、y和z坐标增量(采用等长度单元)；
dx=(Member.Xt(i)-Member.X0(i))/Discrete.Num_ele(i);     %构件i各单元x坐标增量
dy=(Member.Yt(i)-Member.Y0(i))/Discrete.Num_ele(i);     %构件i各单元y坐标增量
dz=(Member.Zt(i)-Member.Z0(i))/Discrete.Num_ele(i);     %构件i各单元z坐标增量
for j=1:N                                               %对时间步j进行循环;
    % 计算j单元中点x、y和z坐标：
    x(j)=Member.X0(i)+(j-0.5)*dx;                       %j单元中点处x坐标
    y(j)=Member.Y0(i)+(j-0.5)*dy;                       %j单元中点处y坐标
    z(j)=Member.Z0(i)+(j-0.5)*dz;                       %j单元中点处z坐标
    % 计算t时刻，x(j,1)位置处自由水面高度(相对于平均水面位置)；
    h_surface=surface_elevation(Wave.h,Wave.k,x(j,1),t,w);
    % 计算j单元动水压力，并平移至构件起始节点处；
    if y(j)<=(Wave.S+h_surface)
        % 水质点运动学参数计算：
        % 计算t时刻，y(j)深度处(相对于海床)水流速度；
        Vc=Current_vel(Current.U_ss0,Current.U_ns0,y(j),Wave.S,Current.h_ref);
        % 当前时刻t，x(j)、y(j)位置处，水质点总速度；
        [ux(j),vy(j)]=Vel_fluid_particle(Wave.T,Wave.h,Wave.k,Wave.S,Vc,x(j),y(j),t);
        % 当前时刻t，x(j)、y(j)位置处，水质点总加速度；
        [ax(j),ay(j)]=ACC_fluid_particle(Wave.T,Wave.h,Wave.k,Wave.S,x(j),y(j),t);
        % 速度矢量分解；
        [V(j),un(j),vn(j),wn(j)]=Vel_resolve(ux(j),vy(j),Member.cx(i),Member.cy(i),Member.cz(i));
        % 加速度矢量分解；
        [anx(j),any(j),anz(j)]=ACC_resolve(ax(j),ay(j),Member.cx(i),Member.cy(i),Member.cz(i));
        % 采用Morison公式计算水动力荷载：
        % 当前单元x方向水动荷载；
        Fjx=(0.5*Hydro.density*Member.D(i)*Hydro.cd*V(j)*un(j)+0.25*Hydro.density*pi*(Member.D(i))^2*Hydro.cm*anx(j))*dt_L;
        % 当前单元x方向水动荷载对y轴之矩；
        Mjz=Fjx*(j-0.5)*dy;
        % 当前单元y方向水动荷载；
        Fjy=(0.5*Hydro.density*Member.D(i)*Hydro.cd*V(j)*vn(j)+0.25*Hydro.density*pi*(Member.D(i))^2*Hydro.cm*any(j))*dt_L; %
        % 当前单元z方向水动荷载；
        Fjz=(0.5*Hydro.density*Member.D(i)*Hydro.cd*V(j)*wn(j)+0.25*Hydro.density*pi*(Member.D(i))^2*Hydro.cm*anz(j))*dt_L; %
        % 当前单元z方向水动荷载对x轴之矩；
        Mjx=Fjz*(j-0.5)*dy;
    else
        Fjx=0;
        Mjz=0;
        Fjy=0;
        Fjz=0;
        Mjx=0;
    end
    %将j单元的水动力荷载添加至前j-1个单元的水动荷载；
    Fx=Fx+Fjx;
	Fy=Fy+Fjy;
	Fz=Fz+Fjz;
    Mx=Mx+Mjx;
	Mz=Mz+Mjz;
end
end
