function [matchedPoints1 matchedPoints2] = coordinateSolvePar(cam1H, cam1V, cam2H, cam2V,debugON)

% This function returns the XY coordinates of points between phases on
% Camera 1 and Camera 2. 
%Inputs
%   cam1H/cam1V: Horizontal and Vertical phase of Camera 1 image
%   cam2H/cam2V: Horizontal and Vertical phase of Camera 2 image
%   debugON: debug flag. 1 to view matching contour points and the
%   intersection point for each matched point. 0 to turn off
%Outputs
%   
warning('off','all')
%if any pixels are NaN, replace them and their corresponding pixel on the
%other camera with 0

scale = 1;

[M,N] = size(cam1H);
cam2H = round(cam2H,2);
cam2V = round(cam2V,2);


cam1H = round(cam1H,2);
cam1V = round(cam1V,2);

% cam1H = CropAperture(cam1H,10);
% cam1V = CropAperture(cam1V,10);


matchedPointsX = [];
matchedPointsY = [];
x_intersect = [];
y_intersect = [];
close all;

figure
subplot(1,2,1)
imagesc(cam1H); hold on;
subplot(1,2,2)
imagesc(imresize(cam2H,1/scale)); hold on;
if debugON
    f = figure;
end

dx = 20;
dy = 20;


matchedPointsX = (1:floor(M/dx))*dx;
matchedPointsY = (1:floor(N/dy))*dy;
[matchedPointsX, matchedPointsY] = meshgrid(matchedPointsX, matchedPointsY);
matchedPointsX = matchedPointsX(:);
matchedPointsY = matchedPointsY(:);
%Loop through each point
parfor i = 1:floor(M/dx)
    for j = 1:floor(N/dy)
        try
        if ~isnan(cam1H(1+(i-1)*dx,1+(j-1)*dy)) %Check for valid point
            
            %store sampled point from camera 1

            
            %find where the phases of the current point occurs in camera 2
            [indHx, indHy] = find(cam2H == cam1H(1+(i-1)*dx,1+(j-1)*dy));
            [indVx, indVy] = find(cam2V == cam1V(1+(i-1)*dx,1+(j-1)*dy));
           
            %calculate intersection
            %find the boundaries of the intersection
            minxH = min(indHy);
            maxxH = max(indHy);
            minxV = min(indVy);
            maxxV = max(indVy);
            
            %Identify the limitations in the calculate intersection
            %location
            xlims = [minxH maxxH minxV maxxV];
            [m,Imin] = min(xlims);
            xlims(Imin) = [];
            [m,Imax] = max(xlims);
            xlims(Imax) = [];
            xlims = sort(xlims);
            try
            %Fit the matched phase points to curves
            Hcurve = fit(indHy,indHx,'fourier4');
            Vcurve = fit(indVy,indVx,'fourier4');
            
            %calculate the starting point for finding the intersection
            stpt = mean(xlims);
            
            %Calculate the x intersection and use it to find the y
            %intersection
            x_intersecttemp = fzero(@(x) Hcurve(x)-Vcurve(x),stpt);
            y_intersecttemp = Vcurve(x_intersecttemp);
            
            catch
            end
            
            %Make sure the calculated intersection point is reasonable, and
            %not extrapolated outside the edges of the data
            try
            if y_intersecttemp > 0 && x_intersecttemp > xlims(1) && y_intersecttemp < M*scale && x_intersecttemp < xlims(2) && ~isnan(cam2H(round(y_intersecttemp),round(x_intersecttemp)))
                x_intersect = [x_intersect x_intersecttemp/scale];
                y_intersect = [y_intersect y_intersecttemp/scale];
            else 
                x_intersect = [x_intersect 0];
                y_intersect = [y_intersect 0];
            end
            catch
                x_intersect = [x_intersect 0];
                y_intersect = [y_intersect 0];
            end

            if debugON

                imagesc(imresize(cam2H,1/scale)); hold on;
                scatter(indHy/scale,indHx/scale)
                scatter(indVy/scale,indVx/scale)
                scatter(x_intersecttemp/scale,y_intersecttemp/scale,'*','k','LineWidth',10)
                hold off
                waitforbuttonpress
            end
        else
            x_intersect = [x_intersect 0];
            y_intersect = [y_intersect 0];
        end
        catch
        end
    end
end

subplot(1,2,1)
imagesc(cam1H); hold on;
scatter(matchedPointsY,matchedPointsX);
subplot(1,2,2)
imagesc(imresize(cam2H,1/scale)); hold on;
scatter(x_intersect,y_intersect,'*')

matchedPoints1 = [matchedPointsX';matchedPointsY'];
matchedPoints2 = [x_intersect;y_intersect];

warning('on','all')

end
