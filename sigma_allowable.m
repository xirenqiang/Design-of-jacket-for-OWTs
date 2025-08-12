function [F] = sigma_allowable(k,L,r,A)
pi=3.1415926; %常数π;
%k为长细比参数，L为长度，r为回转半径
fy=355;
E=2.1*10^5;
Cc=sqrt(2*pi*pi*E/fy);
if k*L/r<Cc
    a=(1-(k*L/(sqrt(2)*r*Cc))^2)*fy/(5/3+3*k*L/(8*r*Cc)-(k*L/(Cc*r))^3/8);
	fprintf('short member;\n');
else
    a=12*pi^2*E/(23*(k*L/r)^2);
	fprintf('long member;\n');
end
F=(a*A)/1.15*1e6;
end

