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
[phase_X, phase_Y] = ndgrid(1:phase_size(1), 1:phase_size(2));
phaseFitH = fit([phase_X(:) phase_Y(:)], cam2H(:), 'poly22', 'Exclude',...
    cam2H(:) == 0);
phaseFitV = fit([phase_X(:) phase_Y(:)], cam2V(:), 'poly22', 'Exclude',...
    cam2V(:) == 0);
% plot(phaseFitH);
% plot(phaseFitV);

%replace x and y with arrays later
syms terms(x,y) 

%obtain the coefficient values
coeffValsH = coeffvalues(phaseFitH);
coeffValsV = coeffvalues(phaseFitV);

%create an array to hold the x and y terms
termsH = 1:size(coeffnames(phaseFitH));

%check each coefficient name to determine the exponent of x and y
for i = 1:size(coeffnames(phaseFitH))
    curCoeffName = char(coeffnames(phaseFitH));
    termsH(i) = x*curCoeffName(2)*y*curCoeffName(3);
end

%V and H should have the same number of terms
termsV = termsV;

end