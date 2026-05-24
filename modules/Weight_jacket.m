function [Wg] = Weight_jacket(Num_bar_array, steel_density, water_density,y0)
% Effective jacket weight above y0 for members in Num_bar_array (buoyancy considered).
% Inputs: member IDs, steel_density, water_density, y0 (m).
global Member;
global Wave;
Wg = 0;
for i = 1:length(Num_bar_array)
    index = Num_bar_array(i);
    if index > length(Member.L)
        error('Member index out of range');
    end
    if Member.Yt(index)<y0
        w = 0;
    else
        if Member.Yt(index) <= Wave.S
            w = Member.L(index) * 0.25 * pi * ((Member.D(index))^2 - (Member.D(index) - 2 * Member.t(index))^2) * (steel_density - water_density) * 9.8;
        elseif Member.Y0(index) >= Wave.S
            w = Member.L(index) * 0.25 * pi * ((Member.D(index))^2 - (Member.D(index) - 2 * Member.t(index))^2) * steel_density * 9.8;
        else
            w = Member.L(index) * (Wave.S - Member.Y0(index)) / (Member.Yt(index) - Member.Y0(index)) * 0.25 * pi * ((Member.D(index))^2 - (Member.D(index) - 2 * Member.t(index))^2) * (steel_density - water_density) * 9.8 + ...
                Member.L(index) * (Member.Yt(index) - Wave.S) / (Member.Yt(index) - Member.Y0(index)) * 0.25 * pi * ((Member.D(index))^2 - (Member.D(index) - 2 * Member.t(index))^2) * steel_density * 9.8;
        end
    end
    Wg = Wg + w;
end
end
