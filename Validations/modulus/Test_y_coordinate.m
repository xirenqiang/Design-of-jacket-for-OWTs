%% Validation path setup
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(projectRoot);
addpath(fullfile(projectRoot, 'modules'));

    x=zeros(100,52);
    y=zeros(100,52);
    z=zeros(100,52);
for i=1:52
    dx=(Member.Xt(i)-Member.X0(i))/Discrete.Num_ele(i);
    dy=(Member.Yt(i)-Member.Y0(i))/Discrete.Num_ele(i);
    dz=(Member.Zt(i)-Member.Z0(i))/Discrete.Num_ele(i);
    for j=1:Discrete.Num_ele(i)
        x(j,i)=Member.X0(i)+(j-0.5)*dx;
        y(j,i)=Member.Y0(i)+(j-0.5)*dy;
        z(j,i)=Member.Z0(i)+(j-0.5)*dz;
    end
end
