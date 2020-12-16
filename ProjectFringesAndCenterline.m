function [ImageStack1, ImageStack2] = ProjectFringesAndCenterline(RowPeriod,ColumnPeriod)

    ProjPars = [];
    ProjPars.Height = 720;
    ProjPars.Width = 1280;
    PatternPars = [];
    PatternPars.RowPeriod = RowPeriod;
    PatternPars.ColPeriod = ColumnPeriod;
    PatternPars.Steps = 4;
    PatternPars.ContrastScale = 1;
    PatternPars.Average = 10;
    PatternPars.Interval = 2;

    FringePattern = createFringePattern(ProjPars,PatternPars);
  
    vid1 = webcam(1);
    vid2 = webcam(3);
    
    [ImageStack1, ImageStack2] = captureImages(vid1,vid2,FringePattern,2,PatternPars);
    
end
