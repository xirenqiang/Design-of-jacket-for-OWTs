function angle = get_hori_angle_of_brace_3f(i,ltop,l1,l2,l3,h1,h2,h3)
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
        angle = atan(sqrt(h1^2+((l1-ltop)/2)^2)/(ltop+(l1-ltop)/2));            %导管架第1层底部宽度
    case 2
        angle = atan(sqrt(h2^2+((l2-l1)/2)^2)/(l1+(l2-l1)/2));                  %导管架第2层底部宽度
    case 3
        angle = atan(sqrt(h3^2+((l3-l2)/2)^2)/(l2+(l3-l2)/2));                  %导管架第3层底部宽度
    otherwise
        error('致命错误：楼层号超出范围，检验get_width_of_floor_3f的第1个输入变量i');
end
end
