clc;clear all; close all;

detH = 6.18*10^-3/2;
detV = 5.85*10^-3/2;


% z = .5;
% f = .010;
% b = 2;
z = 1;
f = .010;
b = 6;

FOVh = atand(detH/f);
FOVv = atand(detV/f);

z_proj = sqrt(z^2+(b/2)^2);

theta = atand(z/(b/2));

x = 2*z_proj*tand(FOVh)
y = 2*z_proj*tand(FOVv)/cosd(theta)

dz = z^2/(b*f)*.0000014*10^6