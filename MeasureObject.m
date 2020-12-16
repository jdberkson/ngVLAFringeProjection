function worldPoints = MeasureObject(cameraParams, projectorParams, stereoParams)

    ImageStack = ProjectFringesAndCenterline(40,40);
    
    [M,N] = size(I(:,:,1));
    I_row = zeros(M,N,4);
    I_column = zeros(M,N,4);
    for i = 1:4
        I_row(:,:,i) = I(:,:,i);
        I_column(:,:,i) = I(:,:,i+4);    
    end
    [wrappedPhase_row,modulation_row] = Equal_step(I_row); 
    [wrappedPhase_column,modulation_column] = Equal_step(I_column);

    modulationThreshold = 0.05;
    % Combine the two modulation data sets to create a mask
    mask = modulation_row+modulation_column;
    % Normalize the data
    mask = mask./max(mask(:));
    % Apply modulation threshold
    mask(mask<modulationThreshold) = 0;
    % Create a mask of 1's and 0's
    mask(mask>(modulationThreshold-0.01)) = 1;

    mask = imfill(mask,'holes');

    mask = double(bwareaopen(mask,1000));

    mask(mask==0) = NaN;

    %Phase Unwrapping
    unwrapped_row = unwrap_phase(wrappedPhase_row.*mask);
    unwrapped_col = unwrap_phase(wrappedPhase_column.*mask);

    %Find the points that lie on the Vertical and Horizontal Line and
    %subtract average phase
    VerticalLine = I(:,:,9).*mask;
    imagesc(VerticalLine)
    title('Select brightest point in background')
    [x,y] = ginput(1);
    x = round(x); y = round(y);
    BackgroundValue = VerticalLine(y,x);
    VerticalLine(VerticalLine<=BackgroundValue+20) = 0;
    VerticalLine(VerticalLine>BackgroundValue) = 1;
    imagesc(VerticalLine)
    PhaseOffsetVert = mean(unwrapped_col(VerticalLine==1));
    unwrapped_col_adj = unwrapped_col-PhaseOffsetVert;

    HorizontalLine = I(:,:,10).*mask;
    imagesc(HorizontalLine)
    title('Select brightest point in background')
    [x,y] = ginput(1);
    x = round(x); y = round(y);
    BackgroundValue = HorizontalLine(y,x);
    HorizontalLine(HorizontalLine<=BackgroundValue+20) = 0;
    HorizontalLine(HorizontalLine>BackgroundValue) = 1;
    imagesc(HorizontalLine)
    PhaseOffsetHoriz = mean(unwrapped_row(HorizontalLine==1));
    unwrapped_row_adj = unwrapped_row-PhaseOffsetHoriz;

    xlocpix = -unwrapped_col_adj*40/(2*pi)+960;
    ylocpix = -unwrapped_row_adj*40/(2*pi)+540;
    
    xlocpix = xlocpix(:);
    ylocpix = ylocpix(:);
    [Xc, Yc] = meshgrid(1:M,1:N);
    Xc = Xc(:);
    Yc = Yc(:);
    Xc = Xc(~isnan(xlocpix));
    Yc = Yc(~isnan(ylocpix));
    xlocpix = xlocpix(~isnan(xlocpix));
    ylocpix = ylocpix(~isnan(ylocpix));
    
    undistortedPointsProj = undistortPoints([xlocpix(:) ;ylocpix(:)]',projectorParams);
    undistortedPointsCam = undistortPoints([Xc ;Yc]',cameraParams);
    
    worldPoints = triangulate(undistortedPointsCam,undistortedPointsProj,stereoParams);

end