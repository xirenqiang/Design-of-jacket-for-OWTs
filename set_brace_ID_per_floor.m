function [braceindex_per_floor]=set_brace_ID_per_floor(Num_of_floor,Num_of_pile)
% 该函数用于确定导管架各层leg编号；
% 输入参数：
% - Num_of_floor：导管架层数；
% - Num_of_pile：多桩导管架桩数；
% 输出参数：
% - braceindex_per_floor：二维数组，导管架各层leg编号，行标为导管架层数，列标为各杆件局部编号；
% 输入参数判别
global debug;
if debug==1
    if Num_of_floor<0
        error('致命错误：参数Num_of_floor小于0，程序终止运行；检查set_brace_ID_per_floor函数输入参数Num_of_floor的取值');
    end
    if Num_of_pile<0
        error('致命错误：参数Num_of_pile小于0，程序终止运行；检查set_brace_ID_per_floor函数输入参数Num_of_pile的取值');
    end
    if Num_of_pile ~= 4
        error('致命错误：导管架桩数不等于4，程序终止运行；本程序用于四桩导管架结构设计，请重新确定set_brace_ID_per_floor输入参数Num_of_floor');
    end
end
% 主函数：
brcnumPf=Num_of_pile*2;                                     %导管架各层支撑数量
braceindex_per_floor=zeros(Num_of_floor,brcnumPf);
for i=1:Num_of_floor
    for j=1:brcnumPf
        braceindex_per_floor(i,j)=Num_of_floor*Num_of_pile+(i-1)*Num_of_pile*2+j;		% 根据主肢杆件编号，往上叠加
    end
end
end
