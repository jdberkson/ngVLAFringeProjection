function [ImageStack1, ImageStack2] = ProjectFringesAndCenterline(numsteps,RowPeriod,ColumnPeriod)

    ProjPars = [];
    ProjPars.Height = 1080;
    ProjPars.Width = 1920;
    PatternPars = [];
    PatternPars.RowPeriod = RowPeriod;
    PatternPars.ColPeriod = ColumnPeriod;
    PatternPars.Steps = numsteps;
    PatternPars.ContrastScale = 1;
    PatternPars.Average = 5;
    PatternPars.Interval = 2;


try
    vid1 = videoinput('mwspinnakerimaq', 1, 'Mono16');
    src1 = getselectedsource(vid1);
    set(src1,'BinningHorizontal',1)
    set(src1,'BinningVertical',1)
    vid1.ROIPosition = [0 0 5472 3648];
    
    vid2 = videoinput('mwspinnakerimaq', 2, 'Mono16');
    src2 = getselectedsource(vid2);
    src1 = getselectedsource(vid2);
    set(src2,'BinningHorizontal',1)
    set(src2,'BinningVertical',1)
    vid2.ROIPosition = [0 0 5472 3648];
catch
    try
        vid1 = webcam(1);
        vid2 = webcam(2);
        vid1.Resolution = '3264x2448';
        vid2.Resolution = '3264x2448';
        vid1.Gain = 100;
        vid2.Gain = 100;
        vid1.Brightness = 20;
        vid2.Brightness = 20;
        vid1.ExposureMode = 'manual';
        vid2.ExposureMode = 'manual';
        vid1.WhiteBalanceMode = 'auto';
        vid2.WhiteBalanceMode = 'auto';

        vid1.Exposure = -1;
        vid2.Exposure = -1;
    catch
        disp('Error connecting to cameras. Exitting')
        return
    end
end
    [ImageStack1, ImageStack2] = captureImages(vid1,vid2,FringePattern,2,PatternPars);
    
    
end
