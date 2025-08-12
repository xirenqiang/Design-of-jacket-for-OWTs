function [D_pile]=Diameter_pile(Load,L_pile,wgh_soil,fs_limit,interface_angle,K0)
D_pile0=2;
N=L_pile;
beta=K0*tand(interface_angle);
deep=zeros(N,1);
s_v=zeros(N,1);
f=zeros(N,1);
for j=1:200
    D_pile=D_pile0 + 0.1*j;
    R=0;
    for i=1:50
        deep(i)=(i-1)+0.5;
        s_v(i)=wgh_soil*deep(i);
        f(i)=beta*s_v(i);
        if f(i)>=fs_limit
            f(i)=fs_limit;
        elseif deep(i)<=1.25*D_pile
            f(i)=0;
        end
        R=(R+f(i)*3.142*D_pile);
    end
    R=R/1.25;
    if (R-Load)>0
        break
    end
end
end

