function [Width] = get_width_of_floor_3f(i,l1,l2,l3)
% 该函数用于返回导管架第i层底部宽度；
% 输入参数：
% -i：导管架层号；
% -l1：导管架第一层底部宽度；
% -l2：导管架第二层底部宽度；
% -l3：导管架第三层底部宽度；
% 输出参数：
% -Width：导管架i层底部宽度；
switch i
    case 1
        Width = l1;                                     %导管架第1层底部宽度
    case 2
        Width = l2;                                     %导管架第2层底部宽度
    case 3
        Width = l3;                                     %导管架第3层底部宽度
    otherwise
        error('致命错误：楼层号超出范围，检验get_width_of_floor_3f的第1个输入变量i');
end
end
