clc; clear all; close all;
[I1, I2] = ProjectFringesAndCenterline(10,40);
[M,N] = size(I1(:,:,1));
I_row1 = zeros(M,N,8);
I_column1 = zeros(M,N,8);
I_row2 = zeros(M,N,8);
I_column2 = zeros(M,N,8);
for i = 1:8
    I_row1(:,:,i) = I1(:,:,i);
    I_column1(:,:,i) = I1(:,:,i+8);    

    I_row2(:,:,i) = I2(:,:,i);
    I_column2(:,:,i) = I2(:,:,i+8);
end

[wrappedPhase_row1,modulation_row1] = Equal_step(I_row1); 
[wrappedPhase_column1,modulation_column1] = Equal_step(I_column1);
[wrappedPhase_row2,modulation_row2] = Equal_step(I_row2); 
[wrappedPhase_column2,modulation_column2] = Equal_step(I_column2);


% modulationThreshold = 0.3;
% % Combine the two modulation data sets to create a mask
% mask1 = modulation_row1+modulation_column1;
% % Normalize the data
% mask1 = mask1./max(mask1(:));
% % Apply modulation threshold
% mask1(mask1<modulationThreshold) = 0;
% % Create a mask of 1's and 0's
% mask1(mask1>(modulationThreshold-0.01)) = 1;
% mask1(isnan(mask1)) = 0;
% mask1 = imfill(mask1,'holes');
% mask1 = double(bwareaopen(mask1,1000));
% mask1(mask1==0) = NaN;
% 
% % Combine the two modulation data sets to create a mask
% mask2 = modulation_row2+modulation_column2;
% % Normalize the data
% mask2 = mask2./max(mask2(:));
% % Apply modulation threshold
% mask2(mask2<modulationThreshold) = 0;
% % Create a mask of 1's and 0's
% mask2(mask2>(modulationThreshold-0.01)) = 1;
% mask2(isnan(mask2)) = 0;
% mask2 = imfill(mask2,'holes');
% mask2 = double(bwareaopen(mask2,1000));
% mask2(mask2==0) = NaN;
figure
imagesc(wrappedPhase_row1)
[x,y] = ginput(4);
mask1 = poly2mask(x,y,2448,3264);

mask1 = double(mask1);
mask1(mask1==0) = NaN;
imagesc(wrappedPhase_row2)
[x,y] = ginput(4);
mask2 = poly2mask(x,y,2448,3264);
mask2 = double(mask2);
mask2(mask2==0) = NaN;


%Unwrap Data
unwrapped_row1 = unwrap_phase(wrappedPhase_row1.*mask1);
unwrapped_col1 = unwrap_phase(wrappedPhase_column1.*mask1);
unwrapped_row2 = unwrap_phase(wrappedPhase_row2.*mask2);
unwrapped_col2 = unwrap_phase(wrappedPhase_column2.*mask2);
figure
sgtitle('Y phase')
subplot(1,2,1)
imagesc(unwrapped_row1);colorbar;
title('Camera 1')
subplot(1,2,2)
imagesc(unwrapped_row2);colorbar;
title('Camera 2')
figure
sgtitle('X Phase')
subplot(1,2,1)
imagesc(unwrapped_col1);colorbar;
title('Camera 1')
subplot(1,2,2)
imagesc(unwrapped_col2);colorbar;
title('Camera 2')

figure
VerticalLine = I1(:,:,17).*mask1;
imagesc(VerticalLine)
title('Select brightest point in background')
[x,y] = ginput(1);
x = round(x); y = round(y);
BackgroundValue = VerticalLine(y,x);
VerticalLine(VerticalLine<=BackgroundValue+20) = 0;
VerticalLine(VerticalLine>BackgroundValue) = 1;
imagesc(VerticalLine)
PhaseOffsetVert1 = mean(unwrapped_col1(VerticalLine==1));
unwrapped_col1_adj = unwrapped_col1-PhaseOffsetVert1;

VerticalLine = I2(:,:,17).*mask2;
imagesc(VerticalLine)
title('Select brightest point in background')
[x,y] = ginput(1);
x = round(x); y = round(y);
BackgroundValue = VerticalLine(y,x);
VerticalLine(VerticalLine<=BackgroundValue+20) = 0;
VerticalLine(VerticalLine>BackgroundValue) = 1;
imagesc(VerticalLine)
PhaseOffsetVert2 = mean(unwrapped_col2(VerticalLine==1));
unwrapped_col2_adj = unwrapped_col2-PhaseOffsetVert2;

HorizontalLine = I1(:,:,18).*mask1;
imagesc(HorizontalLine)
title('Select brightest point in background')
[x,y] = ginput(1);
x = round(x); y = round(y);
BackgroundValue = HorizontalLine(y,x);
HorizontalLine(HorizontalLine<=BackgroundValue+20) = 0;
HorizontalLine(HorizontalLine>BackgroundValue) = 1;
imagesc(HorizontalLine)
PhaseOffsetHoriz1 = mean(unwrapped_row1(HorizontalLine==1));
unwrapped_row1_adj = unwrapped_row1-PhaseOffsetHoriz1;

HorizontalLine = I2(:,:,18).*mask2;
imagesc(HorizontalLine)
title('Select brightest point in background')
[x,y] = ginput(1);
x = round(x); y = round(y);
BackgroundValue = HorizontalLine(y,x);
HorizontalLine(HorizontalLine<=BackgroundValue+20) = 0;
HorizontalLine(HorizontalLine>BackgroundValue) = 1;
imagesc(HorizontalLine)
PhaseOffsetHoriz2 = mean(unwrapped_row2(HorizontalLine==1));
unwrapped_row2_adj = unwrapped_row2-PhaseOffsetHoriz2;


figure
sgtitle('Absolute Y phase')
subplot(1,2,1)
imagesc(unwrapped_row1_adj);colorbar;
title('Camera 1')
subplot(1,2,2)
imagesc(unwrapped_row2_adj);colorbar;
title('Camera 2')

figure
sgtitle('Absolute X Phase')
subplot(1,2,1)
imagesc(unwrapped_col1_adj);colorbar;
title('Camera 1')
subplot(1,2,2)
imagesc(unwrapped_col2_adj);colorbar;
title('Camera 2')

cam1H = imgaussfilt(unwrapped_row1_adj,10);
cam1V = imgaussfilt(unwrapped_col1_adj,10);
cam2H = imgaussfilt(unwrapped_row2_adj,10);
cam2V = imgaussfilt(unwrapped_col2_adj,10);
% cam1H = unwrapped_row1_adj;
% cam1V = unwrapped_col1_adj;
% cam2H = unwrapped_row2_adj;
% cam2V = unwrapped_col2_adj;

stereoCalFilename = uigetfile('*.mat');
load(stereoCalFilename);
cam1H = undistortImage(cam1H,stereoParams.CameraParameters1);
cam1V = undistortImage(cam1V,stereoParams.CameraParameters1);
cam2H = undistortImage(cam2H,stereoParams.CameraParameters2);
cam2V = undistortImage(cam2V,stereoParams.CameraParameters2);



[matchedPoints1, matchedPoints2] = coordinateSolve(cam1H, cam1V, cam2H, cam2V,1);

% matchedPoints1 = undistortPoints(matchedPoints1',stereoParams.CameraParameters2);
% matchedPoints2 = undistortPoints(matchedPoints2',stereoParams.CameraParameters1);
[worldPoints, reprojError] = triangulate(matchedPoints2',matchedPoints1',stereoParams);
worldPoints = rmoutliers(worldPoints);
X = worldPoints(:,1); Y = worldPoints(:,2); Z = worldPoints(:,3);

figure
scatter3(X,Y,Z,'.')

XYZ = [X Y Z];
ptc = pointCloud(XYZ);
figure
subplot(1,2,1)
pcshow(ptc,'MarkerSize',15)

xlabel('X');ylabel('Y');zlabel('Z')
planefit = pcfitplane(ptc,5);
n = planefit.Normal;
theta = -pi/2+atan(n(3)/n(2));
phi = -pi/2+atan(n(3)/n(1));
% zeta = atan(n(2)/n(1));

Rx = [1 0 0 0;0 cos(theta) -sin(theta) 0 ;0 sin(theta) cos(theta) 0; 0 0 0 1];
Ry = [cos(phi) 0 sin(phi) 0;0 1 0 0;-sin(phi) 0 cos(phi) 0; 0 0 0 1];
% Rz = [cos(zeta) -sin(zeta) 0 0; sin(zeta) cos(zeta) 0 0;0 0 1 0; 0 0 0 1];

Rx = affine3d(Rx);
Ry = affine3d(Ry);
% Rz = affine3d(Rz);

ptc = pctransform(ptc,Rx);
ptc = pctransform(ptc,Ry);
% % 
% ptc = pctransform(ptc,Rz);

subplot(1,2,2)
pcshow(ptc,'MarkerSize',50)

xlabel('X');ylabel('Y');zlabel('Z')

Xc = ptc.Location(:,1) - mean(ptc.Location(:,1));
Yc = ptc.Location(:,2) - mean(ptc.Location(:,2));
Zc = ptc.Location(:,3) - mean(ptc.Location(:,3));
XYZc = [Xc Yc Zc];
ptc = pointCloud(XYZc);
subplot(1,2,2)
pcshow(ptc,'MarkerSize',200)

xlabel('X');ylabel('Y');zlabel('Z')

zlim('manual')
zlim([-5,5]); axis square

