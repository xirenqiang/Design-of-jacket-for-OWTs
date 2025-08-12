function mass = mass_steel_jac(density,L_arg,D_arg,t_arg)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
% Debug part
if size(L_arg,2)~=size(D_arg,2)
    error('Length of L_arg and D_arg is not the same, check the inpu of L_arg and D_arg');
end
if size(D_arg,2)~=size(t_arg,2)
    error('Length of D_arg and t_arg is not the same, check the inpu of D_arg and t_arg');
end
Num_bar=size(L_arg,2);
mass=0;
for i=1:Num_bar
    mass=mass+density*L_arg(i)*3.14*D_arg(i)*t_arg(i);
end

end

