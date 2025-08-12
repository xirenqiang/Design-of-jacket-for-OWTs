function [Num_ele,dL]=Discrete_bar(L,dL_exp)
% 该函数根据杆件长度，确定单元数量及单元长度；
% 输入参数：
% - L：杆件长度；
% - dL_exp：单元长度目标值；
%输出参数:
% - Num_ele：杆件划分的单元数；
% - dL：单元长度；
% 输入参数判别
global debug;
if debug==1
    if L<0
        error('致命错误：参数L小于0，程序终止运行；检查Discrete_bar函数输入参数L的取值');
    end
    if dL_exp<0
        error('致命错误：参数dL_exp小于0，程序终止运行；检查Discrete_bar函数输入参数dL_exp的取值');
    end
end
% 主函数：
% 根据单元长度目标值，计算单元预期数量Num_ex，
Num_ex=L/dL_exp;
% 将单元预期数量Num_ex取整，得到实际单元数量Num_ele，
Num_ele=ceil(Num_ex);
% 根据单元长度，计算实际单元长度，
dL=L/Num_ele;
end
