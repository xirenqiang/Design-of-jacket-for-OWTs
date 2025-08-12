function [Numberoftotalelement]=count_total_element(Numberofbar)
% 该函数用于计算导管架结构总单元数；
% 输入变量：
% - Numberofbar：结构杆件总数；
% 输出变量
% - Numberoftotalelement：导管架结构总单元数量；
% 检验输入变量
global debug;
if debug==1
    if Numberofbar<0
        error('致命错误：参数Numberofbar小于0，程序终止运行；检查count_total_element函数输入参数Numberofbar的取值');
    end
end
% 主函数：
% 引用全局变量Discrete，
global Discrete
% 计算结构的总单元数量Numberoftotalelement，
for i=1:Numberofbar                                             %对杆件编号进行循环
    % i杆件的单元数量Discrete.Num_ele(i)增加到Numberoftotalelement，
    Numberoftotalelement=Num_total_element+Discrete.Num_ele(i);
end
end
