function [Xi,Yi,Zi] = InterpolateXY(X,Y,Z,n,xmin,xmax,ymin,ymax)
%Joel Berkson: 1/31/2021
%This function takes X,Y, and Z coordinates, and uses a cubic interpolation
%to make a nxn grid of resampled points
   
    f = fit([X Y], Z,'cubicinterp');
    [Xi,Yi] = meshgrid(linspace(xmin,xmax,n),linspace(ymin,ymax,n));
    Zi = f(Xi,Yi);

end