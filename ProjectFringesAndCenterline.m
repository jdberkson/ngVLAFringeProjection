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
    PatternPars.Interval = 2;

    FringePattern = createFringePattern(ProjPars,PatternPars);
  
    vid1 = webcam(1);
    vid2 = webcam(2);
    vid1.Resolution = '3264x2448';
    vid2.Resolution = '3264x2448';
    vid1.Gain = 20;
    vid2.Gain = 20;
    vid1.Brightness = 30;
    vid2.Brightness = 30;
    [ImageStack1, ImageStack2] = captureImages(vid1,vid2,FringePattern,2,PatternPars);
    
end
