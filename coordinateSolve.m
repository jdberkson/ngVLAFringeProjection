function coordinateSolve(cam1H, cam1V, cam2H, cam2V)

%for debug purposes
% cam1H = unwrapped_row1_adj;
% cam1V = unwrapped_col1_adj;
% cam2H = unwrapped_row2_adj;
% cam2V = unwrapped_col2_adj;

%if any pixels are NaN, replace them and their corresponding pixel on the
%other camera with 0
phase_size = size(cam2H);
for i = 1:phase_size(1)
    for j = 1:phase_size(2)
        if isnan(cam1H(i,j))
            cam1H(i,j) = 0;
            cam2H(i,j) = 0;
        end
        if isnan(cam1V(i,j))
            cam1V(i,j) = 0;
            cam2V(i,j) = 0;
        end
        if isnan(cam2H(i,j))
            cam2H(i,j) = 0;
            cam1H(i,j) = 0;
        end
        if isnan(cam2V(i,j))
            cam2V(i,j) = 0;
            cam1V(i,j) = 0;
        end
    end
end

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


[M,N] = size(cam1H);
cam2H = round(cam2H,3);
cam2V = round(cam2V,3);


cam1H = round(cam1H,3);
cam1V = round(cam1V,3);

figure
imagesc(cam2H)
hold on

for i = 500:20:M-500
   
    for j = 500:20:N-500
        
        [indHx indHy] = find(cam2H == cam1H(i,j));
        [indVx indVy] = find(cam2V == cam1V(i,j));
      
        p1 = polyfit(indHy,indHx,3);
        p2 = polyfit(indVy,indVx,3);
        %calculate intersection
        x_intersect(i,j) = fzero(@(x) polyval(p1-p2,x),3);
        y_intersect(i,j) = polyval(p1,x_intersect(i,j));
        warning('off','last');
       
        
    end
end



 scatter(x_intersect(:),y_intersect(:),'*')

end
