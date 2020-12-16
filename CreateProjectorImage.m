function im = CreateProjectorImage()
    I = ProjectFringesAndCenterline(40,40);
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

    %Unwrap Data
    unwrapped_row = unwrap_phase(wrappedPhase_row.*mask);
    unwrapped_col = unwrap_phase(wrappedPhase_column.*mask);
    figure
    imagesc(unwrapped_row)
    figure
    imagesc(unwrapped_col)

    VerticalLine = I(:,:,9);
    imagesc(VerticalLine)
    title('Select brightest point in background')
    [x,y] = ginput(1);
    x = round(x); y = round(y);
    BackgroundValue = VerticalLine(y,x);
    VerticalLine(VerticalLine<=BackgroundValue+10) = 0;
    VerticalLine(VerticalLine>BackgroundValue) = 1;
    imagesc(VerticalLine)
    PhaseOffsetVert = mean(unwrapped_col(VerticalLine==1));
    unwrapped_col_adj = unwrapped_col-PhaseOffsetVert;

    xlocpix = round(-unwrapped_col_adj*40/(2*pi))+640;
    minx = min(min(xlocpix));
    maxx = max(max(xlocpix));

    HorizontalLine = I(:,:,10);
    imagesc(HorizontalLine)
    title('Select brightest point in background')
    [x,y] = ginput(1);
    x = round(x); y = round(y);
    BackgroundValue = HorizontalLine(y,x);
    HorizontalLine(HorizontalLine<=BackgroundValue+10) = 0;
    HorizontalLine(HorizontalLine>BackgroundValue) = 1;
    imagesc(HorizontalLine)
    PhaseOffsetHoriz = mean(unwrapped_row(HorizontalLine==1));
    unwrapped_row_adj = unwrapped_row-PhaseOffsetHoriz;

    ylocpix = round(-unwrapped_row_adj*40/(2*pi))+360;
    miny = min(min(ylocpix));
    maxy = max(max(ylocpix));
    im = zeros(720,1280);

    RedIm = I(:,:,11);
    % imagesc(RedIm)
    % title('Select Dark Square')
    % [xdark,ydark] = ginput(1);
    % title('Select bright Square')
    % [xbright,ybright] = ginput(1);

    % meanint = (RedIm(round(xbright),round(ybright))-RedIm(round(xdark),round(ydark)))/2;
    % BW = zeros(size(RedIm,1),size(RedIm,2));
    % BW(RedIm>meanint) = 1;
    % BW(RedIm<meanint) = 0;

    for i = 1:size(RedIm,1)
        for j = 1:size(RedIm,2)
            im(ylocpix(i,j),xlocpix(i,j)) = RedIm(i,j);

        end
    end
    close all;
    imagesc(im)
    fullscreen(uint8(im),2)
    pause(5)
    im = uint(im);
end
