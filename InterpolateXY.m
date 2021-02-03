function [Xi,Yi,Zi] = InterpolateXY(X,Y,Z,n)
%Joel Berkson: 1/31/2021
%This function takes X,Y, and Z coordinates, and uses a cubic interpolation
%to make a nxn grid of resampled points
    xmax = max(max(X));
    xmin = min(min(X));
    ymin = min(min(Y));
    ymax = max(max(Y));
    
    f = fit([X Y], Z,'cubicinterp');
    [Xi,Yi] = meshgrid(linspace(xmin,xmax,n),linspace(ymin,ymax,n));
    Zi = f(Xi,Yi);

end