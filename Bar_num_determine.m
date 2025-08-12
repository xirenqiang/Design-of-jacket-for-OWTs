function [Num_bar]=Bar_num_determine(Num_floor,Num_pile)
% 本函数用于确定导管架总构件数量;
% 输入参数：
% - Num_floor：导管架层数；
% - Num_pile：多桩导管架桩数；
% 输出参数：
% - Num_bar：导管架总杆件数；
% 输入参数检验
global debug;
if debug==1
    if Num_floor ~= 3 && Num_floor ~= 4
        error('致命错误：导管架层数不等于3或者4，程序终止运行。本程序用于三层、四层导管架结构设计，请重新确定输入参数。');
    end
    if Num_pile ~= 3 && Num_pile ~= 4
        error('致命错误：多桩导管架桩数不等于3或者4，程序终止运行。本程序用于三桩、四桩导管架结构设计，请重新确定输入参数。');
    end
end
% 主函数
% 定义导管架各层leg数量leg_num，
leg_num_per_floor = Num_pile;
% 定义导管架各层brace数量incli_brace_num，
brace_num_per_floor = 2*Num_pile;
% 计算导管架总杆件数，
Num_bar= (leg_num_per_floor + brace_num_per_floor)*Num_floor;%构件数
end

