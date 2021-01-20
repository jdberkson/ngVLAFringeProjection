function [ImageStack1, ImageStack2] = ProjectFringesAndCenterline(RowPeriod,ColumnPeriod)

    ProjPars = [];
    ProjPars.Height = 1080;
    ProjPars.Width = 1920;
    PatternPars = [];
    PatternPars.RowPeriod = RowPeriod;
    PatternPars.ColPeriod = ColumnPeriod;
    PatternPars.Steps = 8;
    PatternPars.ContrastScale = 1;
    PatternPars.Average = 5;
    PatternPars.Interval = 4;

    FringePattern = createFringePattern(ProjPars,PatternPars);
  
    vid1 = webcam(1);
    vid2 = webcam(2);
    vid1.Resolution = '3264x2448';
    vid2.Resolution = '3264x2448';
    vid1.Gain = 50;
    vid2.Gain = 50;
    vid1.Brightness = 45;
    vid2.Brightness = 45;
    [ImageStack1, ImageStack2] = captureImages(vid1,vid2,FringePattern,2,PatternPars);
    
end
