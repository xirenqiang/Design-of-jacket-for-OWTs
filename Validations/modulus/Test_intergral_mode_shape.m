%% Validation path setup
thisFileDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFileDir));
addpath(projectRoot);
addpath(fullfile(projectRoot, 'modules'));

%test intergral mode shape function
clear all
clc
z(1)=0;
z(2)=70;
z(3)=140;
lamda1=1.8751;
ht=70;
hj=70;
y=zeros(3,1);
for i=1:3
    y(i)=intergral_mode_shape(z(i),lamda1,ht,hj);
end
