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

%make a poly22 fit for the phases from camera 2
[phase_Y, phase_X] = ndgrid(1:phase_size(1), 1:phase_size(2));
phaseFitH = fit([phase_X(:) phase_Y(:)], cam2H(:), 'poly33', 'Exclude',...
    cam2H(:) == 0);
phaseFitV = fit([phase_X(:) phase_Y(:)], cam2V(:), 'poly33', 'Exclude',...
    cam2V(:) == 0);
% plot(phaseFitH);
% plot(phaseFitV);

%obtain the coefficient values
coeffValsH = coeffvalues(phaseFitH);
coeffValsV = coeffvalues(phaseFitV);

%Create coefficient matrix
coeffM = [coeffValsH; coeffValsV];

coeffMinv = pinv(coeffM);

PhaseM = [cam1H(:) cam1V(:)];

Coords = coeffMinv*PhaseM';

X = Coords(2,:);
Y = Coords(3,:);
scatter(X,Y);

end
