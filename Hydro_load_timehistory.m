function [Ftx, Fty, Ftz, Mtx, Mtz, t]=Hydro_load_timehistory(t0, t1, dt, Num_bar_array, y0_position)
%该函数用于计算一段时间内杆件集合Num_bar_array受到的水动荷载合力；
%输入变量：
% - t0：开始时刻；
% - t1：结束时刻；
% - dt：时间间隔；
% - Num_bar_array：杆件集合，该集合是当前计算水动荷载涉及到的杆件集合；
%输出变量：
% - Ftx：导管架杆件集合所受波浪荷载沿x方向的合力时程；
% - Fty：导管架杆件集合所受波浪荷载沿y方向的合力时程；
% - Ftz：导管架杆件集合所受波浪荷载沿z方向的合力时程；
% - Mtx：导管架杆件集合所受波浪荷载对x轴之矩；
% - Mtz：导管架杆件集合所受波浪荷载沿x轴之矩；
% - t：时间序列；
global debug;
if debug==1
    if t1 < t0
        error('致命错误：计算的终止时间早于开始时间，程序运行终止；请检查Hydro_load_timehistory函数的输入时间参数t0和t1');
    end
    if dt < 0
        error('致命错误：计算的时间步长dt小于0，程序运行终止；请检查Hydro_load_timehistory函数的输入时间参数dt');
    end
end
% 主函数：
% 计算时间步数N，
N=(t1-t0)/dt+1;
% 初始化输出变量，
t=zeros(N,1);                                       %时间序列；
Ftx=zeros(N,1);                                     %水动荷载合力的x方向分量；
Fty=zeros(N,1);                                     %水动荷载合力的y方向分量；
Ftz=zeros(N,1);                                     %水动荷载合力的z方向分量；
Mtx=zeros(N,1);                                     %水动荷载合力对x轴之矩；
Mtz=zeros(N,1);                                     %水动荷载合力对y轴之矩；
for i=1:N                                           %对时间步i进行循环;
    % 计算当前时刻；
    t(i)=(i-1)*dt;
    if debug==1
        % 检查当前时间点是否小于 t0；
        if t(i) < t0
            fprintf('当前计算时刻 (t(%d) = %f) 具有致命错误\n', i, t(i));
            error('当前时刻小于初始时刻，请检查输入时间参数')
            % 检查当前时间点是否大于 t1
        elseif t(i) > t1
            fprintf('当前计算时刻 (t(%d) = %f) 具有致命错误\n', i, t(i));
            error('当前时刻大于结束时刻，请检查输入时间参数')
        end
    end
    %调用Hydro_structure函数，计算t(i)时刻导管架受到的水动力荷载
    [Ftx(i),Fty(i),Ftz(i),Mtx(i),Mtz(i)]=Hydro_structure(Num_bar_array,t(i),y0_position);%此处需要插入水动荷载计算过程中的荷载简化中心竖向坐标；
end
end
