function [matchedPoints1 matchedPoints2] = coordinateSolve(cam1H, cam1V, cam2H, cam2V,debugON)

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
cam2H = round(cam2H,3);
cam2V = round(cam2V,3);


cam1H = round(cam1H,3);
cam1V = round(cam1V,3);

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

dx = 100;
dy = 100;

%Loop through each point
for i = 1:dx:M
    for j = 1:dy:N
        if ~isnan(cam1H(i,j)) %Check for valid point
            %store sampled point from camera 1
            matchedPointsX = [matchedPointsX j];
            matchedPointsY = [matchedPointsY i];
            
            %find where the phases of the current point occurs in camera 2
            [indHx, indHy] = find(cam2H == cam1H(i,j));
            [indVx, indVy] = find(cam2V == cam1V(i,j));
           
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
                %Remove Point from matched points if error
                matchedPointsX(end) = [];
                matchedPointsY(end) = [];
            end
            catch
                %Remove Point from matched points if error
                matchedPointsX(end) = [];
                matchedPointsY(end) = [];
            end

            if debugON

                imagesc(imresize(cam2H,1/scale)); hold on;
                scatter(indHy/scale,indHx/scale)
                scatter(indVy/scale,indVx/scale)
                scatter(x_intersecttemp/scale,y_intersecttemp/scale,'*','k','LineWidth',10)
                hold off
                waitforbuttonpress
            end
        
        end
    end
end

subplot(1,2,1)
imagesc(cam1H); hold on;
scatter(matchedPointsX,matchedPointsY);
subplot(1,2,2)
imagesc(imresize(cam2H,1/scale)); hold on;
scatter(x_intersect,y_intersect,'*')

matchedPoints1 = [matchedPointsX;matchedPointsY];
matchedPoints2 = [x_intersect;y_intersect];

warning('on','all')

end
