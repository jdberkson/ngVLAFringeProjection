clc; clear all; close all;
[I1, I2] = ProjectFringesAndCenterline(40,40);
[M,N] = size(I1(:,:,1));
I_row1 = zeros(M,N,4);
I_column1 = zeros(M,N,4);
I_row2 = zeros(M,N,4);
I_column2 = zeros(M,N,4);
for i = 1:4
    I_row1(:,:,i) = I1(:,:,i);
    I_column1(:,:,i) = I1(:,:,i+4);    

    I_row2(:,:,i) = I2(:,:,i);
    I_column2(:,:,i) = I2(:,:,i+4);
end

[wrappedPhase_row1,modulation_row1] = Equal_step(I_row1); 
[wrappedPhase_column1,modulation_column1] = Equal_step(I_column1);
[wrappedPhase_row2,modulation_row2] = Equal_step(I_row2); 
[wrappedPhase_column2,modulation_column2] = Equal_step(I_column2);


modulationThreshold = 0.05;
% Combine the two modulation data sets to create a mask
mask1 = modulation_row1+modulation_column1;
% Normalize the data
mask1 = mask1./max(mask1(:));
% Apply modulation threshold
mask1(mask1<modulationThreshold) = 0;
% Create a mask of 1's and 0's
mask1(mask1>(modulationThreshold-0.01)) = 1;
mask1(isnan(mask1)) = 0;
mask1 = imfill(mask1,'holes');
mask1 = double(bwareaopen(mask1,1000));
mask1(mask1==0) = NaN;

% Combine the two modulation data sets to create a mask
mask2 = modulation_row2+modulation_column2;
% Normalize the data
mask2 = mask2./max(mask2(:));
% Apply modulation threshold
mask2(mask2<modulationThreshold) = 0;
% Create a mask of 1's and 0's
mask2(mask2>(modulationThreshold-0.01)) = 1;
mask2(isnan(mask2)) = 0;
mask2 = imfill(mask2,'holes');
mask2 = double(bwareaopen(mask2,1000));
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
VerticalLine = I1(:,:,9).*mask1;
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

VerticalLine = I2(:,:,9).*mask2;
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

HorizontalLine = I1(:,:,10).*mask1;
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

HorizontalLine = I2(:,:,10).*mask2;
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







