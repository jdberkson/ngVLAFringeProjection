function [matchedPoints1 matchedPoints2] = coordinateSolve(cam1H, cam1V, cam2H, cam2V,debugON)

%for debug purposes
% cam1H = unwrapped_row1_adj;
% cam1V = unwrapped_col1_adj;
% cam2H = unwrapped_row2_adj;
% cam2V = unwrapped_col2_adj;
warning('off','all')
%if any pixels are NaN, replace them and their corresponding pixel on the
%other camera with 0


% %make a poly22 fit for the phases from camera 2
% [phase_Y, phase_X] = ndgrid(1:phase_size(1), 1:phase_size(2));
% [M,N] = size(cam2H);
% phase_Y = 1:N;
% phase_X = 1:M;
% [phase_Y, phase_X] = meshgrid(phase_Y,phase_X);
% phaseFitH = fit([phase_X(:) phase_Y(:)], cam2H(:), 'poly22', 'Exclude',...
%     cam2H(:) == 0);
% phaseFitV = fit([phase_X(:) phase_Y(:)], cam2V(:), 'poly22', 'Exclude',...
%     cam2V(:) == 0);
% % plot(phaseFitH);
% % plot(phaseFitV);
% 
% %obtain the coefficient values
% coeffValsH = coeffvalues(phaseFitH);
% coeffValsV = coeffvalues(phaseFitV);
% 
% %Create coefficient matrix
% coeffM = [coeffValsH; coeffValsV];
% 
% coeffMinv = pinv(coeffM);
% 
% PhaseM = [cam1H(:) cam1V(:)];
% 
% Coords = coeffMinv*PhaseM';
% X = Coords(2,:);
% Y = Coords(3,:);

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


for i = 1:10:M
    
    for j = 1:10:N
        if ~isnan(cam1H(i,j)) %Check for valid point
            %store sampled point on camera 1
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
            %not extrapolated
            try
            if y_intersecttemp > 0 && x_intersecttemp > xlims(1) && y_intersecttemp < M*scale && x_intersecttemp < xlims(2) && ~isnan(cam2H(round(y_intersecttemp),round(x_intersecttemp)))
                x_intersect = [x_intersect x_intersecttemp/scale];
                y_intersect = [y_intersect y_intersecttemp/scale];
            else
                matchedPointsX(end) = [];
                matchedPointsY(end) = [];
            end
            catch
                matchedPointsX(end) = [];
                matchedPointsY(end) = [];
            end
           
            
%             x_intersecttemp = roots(p1-p2);
%             y_intersecttemp = polyval(p1,x_intersecttemp);
%             root_ind = find(y_intesecttemp > miny & y_intersecttemp < maxy & x_intesecttemp > minx & x_intersecttemp < maxx);
%             x_intersecttemp = x_intersecttemp(root_ind(1));
%             y_intersecttemp = y_intersecttemp(root_ind(1));
            if debugON

                imagesc(imresize(cam2H,1/scale)); hold on;
                scatter(indHy/scale,indHx/scale)
                scatter(indVy/scale,indVx/scale)
                scatter(x_intersecttemp/scale,y_intersecttemp/scale,'*','k','LineWidth',10)
                hold off
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
