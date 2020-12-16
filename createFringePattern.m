% Generate the phase shifted images
% Author: Hyukmo Kang
% Email: hkang@optics.arizona.edu
% Edit Log
% 4/8/20, First draft, Hyukmo Kang


function out = phashiftimg(ProjPars,PatternPars)
%This function simply calculates and returns the Phase shifted patterns for
%horizontal and vertical images.
    k = 1;
    PhaseShiftedArray = zeros(ProjPars.Height,ProjPars.Width,2*PatternPars.Steps);
    
    % Horizontal fringe pattern     
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
    
    out = PhaseShiftedArray;
    
end