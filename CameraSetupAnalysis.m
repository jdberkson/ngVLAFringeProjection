clc;clear all; close all;

detH = 6.18*10^-3;
detV = 5.85*10^-3;


% z = .5;
% f = .010;
% b = 2;
z = 1.5;
f = .05;
b = 1;

FOVh = atand(detH/f);
FOVv = atand(detV/f);

z_proj = sqrt(z^2+b/2^2);

theta = atand(z/(b/2));

x = 2*z_proj*tand(FOVh)
y = 2*z_proj*tand(FOVv)/cosd(theta)

dz = z^2/(b*f)*.000016*10^6*.25;