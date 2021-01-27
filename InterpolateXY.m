function [Xi,Yi,Zi] = InterpolateXY(X,Y,Z)
    xmax = max(max(X));
    xmin = min(min(X));
    ymin = min(min(Y));
    ymax = max(max(Y));
    F1 = scatteredInterpolant(X,Y,Z);
    [Xi,Yi] = meshgrid(linspace(xmin+10,xmax-10,1000),linspace(ymin+10,ymax-10,1000));
    Zi = F1(Xi,Yi);

end