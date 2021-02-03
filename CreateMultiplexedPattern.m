function CreateMultiplexedPattern(ProjPars,PatternPars)
    PatternPars.Steps = 3;
    PhaseShiftedArray = zeros(ProjPars.Height,ProjPars.Width,6);
    Horizontal = zeros(ProjPars.Height,ProjPars.Width,3);
    Vertical = zeros(ProjPars.Height,ProjPars.Width,3);
    Multiplexed = zeros(ProjPars.Height,ProjPars.Width,3);
    % Horizontal fringe pattern     
    k = 1;
    yc = 1:ProjPars.Height;
    for i=1:PatternPars.Steps                
        FringePatternLine = uint8(128+PatternPars.ContrastScale*128*...
            cos(2*pi*yc/PatternPars.RowPeriod+2*pi/PatternPars.Steps*i));
        FringePattern = repmat(FringePatternLine',[1,ProjPars.Width]);
        PhaseShiftedArray(:,:,k) = FringePattern;
        k = k+1;
    end

    % Vertical fringe pattern
    xc = 1:ProjPars.Width;    
    for i=1:PatternPars.Steps        
        FringePatternLine = uint8(128+PatternPars.ContrastScale*128*...
            cos(2*pi*xc/PatternPars.ColPeriod+2*pi/PatternPars.Steps*i));
        FringePattern = repmat(FringePatternLine,[ProjPars.Height,1]);
        PhaseShiftedArray(:,:,k) = FringePattern;
        k = k+1;
    end
    Horizontal(:,:,1) = PhaseShiftedArray(:,:,1);
    Horizontal(:,:,2) = PhaseShiftedArray(:,:,2);
    Horizontal(:,:,3) = PhaseShiftedArray(:,:,3);
    Vertical(:,:,1) = PhaseShiftedArray(:,:,4);
    Vertical(:,:,2) = PhaseShiftedArray(:,:,5);
    Vertical(:,:,3) = PhaseShiftedArray(:,:,6);
    Multiplexed = Vertical.*Horizontal/255;

    
    xi = [1 1 1920 1920];
    yi = [1 1080 1 1080];
    C = poly2mask(xi,yi,1080,1920);
    D(C == 0) = 1;
    D(C == 1) = 0;
    M = fft2(Multiplexed(:,:,1));
    M = fftshift(M);
    J = M.*C;
    K = ifft2(J);
    imagesc(abs(K))
end