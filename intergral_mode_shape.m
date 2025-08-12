function [y]=intergral_mode_shape(z,lamda1,ht,hj)
%计算悬臂梁振型函数平方的积分;
beta1=-(cos(lamda1)+cosh(lamda1))/(sin(lamda1)+sinh(lamda1));
C1=lamda1/(ht+hj);
y=z+(1-beta1^2)/(4*C1)*sin(2*C1*z)-beta1/(2*(C1))*cos(2*C1*z)+(1+beta1^2)/(4*C1)*sinh(2*C1*z)+beta1^2/(2*C1)*cosh(2*C1*z)-2*beta1/(C1)*sin(C1*z)*sinh(C1*z)-(1+beta1^2)/(C1)*sin(C1*z)*cosh(C1*z)-(1-beta1^2)/(C1)*cos(C1*z)*sinh(C1*z);
end