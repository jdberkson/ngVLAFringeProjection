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
scale = 5;
cam2H = imresize(cam2H,scale);
cam2V = imresize(cam2V,scale);

[M,N] = size(cam1H);
cam2H = round(cam2H,4);
cam2V = round(cam2V,4);


cam1H = round(cam1H,4);
cam1V = round(cam1V,4);

figure
imagesc(cam1H)
hold on

matchedPointsX = [];
matchedPointsY = [];
x_intersect = [];
y_intersect = [];
close all;
figure
imagesc(cam1H)
title('Select min x and max x, then min y and max y')
[x,y] = ginput(4);

x = round(x); y=round(y);


figure
subplot(1,2,1)
imagesc(cam1H); hold on;
subplot(1,2,2)
imagesc(imresize(cam2H,1/scale)); hold on;
f = figure;
for i = y(3):100:y(4)
   
    for j = x(1):100:x(2)
        matchedPointsX = [matchedPointsX j];
        matchedPointsY = [matchedPointsY i];
        [indHx indHy] = find(cam2H == cam1H(i,j));
        [indVx indVy] = find(cam2V == cam1V(i,j));
      
        p1 = polyfit(indHy,indHx,5);
        p2 = polyfit(indVy,indVx,5);

        %calculate intersection
        x_intersecttemp = fzero(@(x) polyval(p1-p2,x),0);
        y_intersecttemp = polyval(p1,x_intersecttemp);
        if x_intersecttemp > 0 && y_intersecttemp > 0
            x_intersect = [x_intersect x_intersecttemp/scale];
            y_intersect = [y_intersect y_intersecttemp/scale];
        else
            matchedPointsX(end) = [];
            matchedPointsY(end) = [];
        end
        if debugON
            close(f)
            f = figure;
            imagesc(imresize(cam2H,1/scale)); hold on;
            scatter(indHy/scale,indHx/scale)
            scatter(indVy/scale,indVx/scale)
            scatter(x_intersecttemp/scale,y_intersecttemp/scale)
        end
       
    end
end

subplot(1,2,1)
scatter(matchedPointsX,matchedPointsY);
subplot(1,2,2)
 scatter(x_intersect,y_intersect,'*')
 
 matchedPoints1 = [matchedPointsX;matchedPointsY];
 matchedPoints2 = [x_intersect;y_intersect];
 
warning('on','all')

end
