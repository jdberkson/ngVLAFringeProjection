clc;clear all; close all;

p = 1.55;
Res_h = 4000;
Res_v = 3000;

detH = Res_h*p*10^-3/2;
detV = Res_v*p*10^-3/2;


% z = .5;
% f = .010;
% b = 2;
d = 1;
z = 1;
f = .012;
b = 6;

FOVh = atand(detH/f);
FOVv = atand(detV/f);

z_short = sqrt(z^2+(b/2-d/2)^2);
z_proj = sqrt(z^2+(b/2)^2);

theta = atand(z/(b/2));

x_short = 2*z_short*tand(FOVh)/1000
y = 2*z_proj*tand(FOVv)/cosd(theta)/1000

dz = z^2/(b*f)*p