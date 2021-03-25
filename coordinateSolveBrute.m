function [matchedPoints1 matchedPoints2] = coordinateSolveBrute(cam1H, cam1V, cam2H, cam2V,debugON)

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

scale = 2;
cam2H = imresize(cam2H,scale);
cam2V = imresize(cam2V,scale);

[M,N] = size(cam1H);
cam2H = round(cam2H,2);
cam2V = round(cam2V,2);


cam1H = round(cam1H,2);
cam1V = round(cam1V,2);

figure
imagesc(cam1H)
hold on

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

% x = [1305;1588;1430;1438];
% % 
% y = [738;726;688;763];

for i = 1:50:M
    
    for j = 1:50:N
        if ~isnan(cam1H(i,j)) 
            matchedPointsX = [matchedPointsX j];
            matchedPointsY = [matchedPointsY i];
            [row,col] = find(cam2H == cam1H(i,j) & cam2V == cam1V(i,j));
            if ~isempty(row)
                row = mean(row); col = mean(col);
                x_intersect = [x_intersect col/scale];
                y_intersect = [y_intersect row/scale];
            else
                [indHx indHy] = find(cam2H == cam1H(i,j));
                [indVx indVy] = find(cam2V == cam1V(i,j));
                p1 = polyfit(indHy,indHx,7);
                p2 = polyfit(indVy,indVx,7);

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
                try
                stpt = mean(xlims);


                x_intersecttemp = fzero(@(x) polyval(p1-p2,x),stpt);
                y_intersecttemp = polyval(p1,x_intersecttemp);
                catch
                end
                if y_intersecttemp > 0 && x_intersecttemp > 0 && y_intersecttemp < M*scale && x_intersecttemp < N*scale && ~isnan(cam2H(round(y_intersecttemp),round(x_intersecttemp)))
                    x_intersect = [x_intersect x_intersecttemp/scale];
                    y_intersect = [y_intersect y_intersecttemp/scale];
                else
                    matchedPointsX(end) = [];
                    matchedPointsY(end) = [];
                end
            end
           
            
%             x_intersecttemp = roots(p1-p2);
%             y_intersecttemp = polyval(p1,x_intersecttemp);
%             root_ind = find(y_intesecttemp > miny & y_intersecttemp < maxy & x_intesecttemp > minx & x_intersecttemp < maxx);
%             x_intersecttemp = x_intersecttemp(root_ind(1));
%             y_intersecttemp = y_intersecttemp(root_ind(1));
            if debugON

                imagesc(imresize(cam2H,1/scale)); hold on;
               
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