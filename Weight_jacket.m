function [Wg] = Weight_jacket(Num_bar_array, steel_density, water_density,y0)
% 该函数用于计算导管架当前高度y0以上的有效总重量，逐层计算
% 输入变量:
% Num_bar_array:构件编号数组
% steel_density:钢材密度
% water_density:水的密度
% y0：当前位置（竖直方向）
global Member;
global Wave;
Wg = 0;
% 逐个计算每个杆件重量
for i = 1:length(Num_bar_array)
    index = Num_bar_array(i);
    if index > length(Member.L)
        error('构件编号超出范围');
    end
    if Member.Yt(i)<y0%计算杆件的重量
        w = 0;
    else
        if Member.Yt(i) <= Wave.S
            w = Member.L(i) * 0.25 * pi * ((Member.D(i))^2 - (Member.D(i) - 2 * Member.t(i))^2) * (steel_density - water_density) * 9.8;
        elseif Member.Y0(i) >= Wave.S
            w = Member.L(i) * 0.25 * pi * ((Member.D(i))^2 - (Member.D(i) - 2 * Member.t(i))^2) * steel_density * 9.8;
        else
            w = Member.L(i) * (Wave.S - Member.Y0(i)) / (Member.Yt(i) - Member.Y0(i)) * 0.25 * pi * ((Member.D(i))^2 - (Member.D(i) - 2 * Member.t(i))^2) * (steel_density - water_density) * 9.8 + ...
                Member.L(i) * (Member.Yt(i) - Wave.S) / (Member.Yt(i) - Member.Y0(i)) * 0.25 * pi * ((Member.D(i))^2 - (Member.D(i) - 2 * Member.t(i))^2) * steel_density * 9.8;
        end
        % 累加当前层的重量
    end
    Wg = Wg + w;
end
end

