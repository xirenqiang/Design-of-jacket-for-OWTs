function Coord_trans_bar_discrete(pesai, Num_bar)
% 本函数用于导管架节点坐标变换、杆件离散；
% 输入参数：
% - pesai：导管架绕竖直轴y整体旋转角度；
% - Num_bar：导管架杆件数量；
% 输出参数：本函数执行的操作均针对全局变量，无需显式的输出变量；
% 引用全局变量：
global Member;
global Discrete;
global dL_ele_target;
global debug;
if debug==1
    if pesai<0
        error('致命错误：参数pesai小于0，程序终止运行；检查Coord_trans_bar_discrete函数参数pesai');
    end
    if Num_bar<0
        error('致命错误：参数Num_bar小于0，程序终止运行；检查Coord_trans_bar_discrete函数参数Num_bar的取值');
    end
end
% 主函数：
for i=1:Num_bar                                                            %对杆件编号进行循环
    % 对杆件i起点进行坐标变换，
    [Member.X0(i),Member.Y0(i),Member.Z0(i)]=coordinate_trans(Member.X0(i),Member.Y0(i),Member.Z0(i),pesai);
    % 对杆件i终点进行坐标变换，
    [Member.Xt(i),Member.Yt(i),Member.Zt(i)]=coordinate_trans(Member.Xt(i),Member.Yt(i),Member.Zt(i),pesai);
    % 计算杆件i长度，
    Member.L(i)=Member_length(Member.X0(i),Member.Y0(i),Member.Z0(i),Member.Xt(i),Member.Yt(i),Member.Zt(i));
    if Member.L(i)<0
        error('致命错误：杆件长度0，程序终止运行；检查Coord_trans_bar_discrete函数得到的杆件坐标值');
    end
    % 计算杆件i与y轴正向的夹角Member.fai_y(i)，
    Member.fai_y(i)=Member_fai_y(Member.X0(i),Member.Y0(i),Member.Z0(i),Member.Xt(i),Member.Yt(i),Member.Zt(i));
    % 计算杆件i构件在xz平面内投影与x轴正向的夹角Member.cita_x(i)，
    [Member.cita_x(i)]=Member_cita_x(Member.X0(i),Member.Y0(i),Member.Z0(i),Member.Xt(i),Member.Yt(i),Member.Zt(i));
    % 计算杆件i单位法向量在x、y和z方向的投影Member.cx(i)、Member.cy(i)和Member.cz(i)，
    [Member.cx(i),Member.cy(i),Member.cz(i)]=Direction_bar(Member.fai_y(i),Member.cita_x(i));
    % 根据单元目标长度，离散化杆件，计算单元数量Discrete.Num_ele(i)、单元长度Discrete.dL(i)，
    [Discrete.Num_ele(i),Discrete.dL(i)]=Discrete_bar(Member.L(i),dL_ele_target);
end
end
