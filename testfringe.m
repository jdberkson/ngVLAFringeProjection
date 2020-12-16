
clear all; close all; clc;
ScreenPars = [];
ScreenPars.Height = 720;
ScreenPars.Width = 1280;

PatternPars = [];
PatternPars.RowPeriod = 10;
PatternPars.ColPeriod = 10;
PatternPars.Steps = 4;
PatternPars.ContrastScale = 1;
PatternPars.Average = 4;
PatternPars.Interval = 1;

FringePattern = phashiftimg(ScreenPars,PatternPars);

list = webcamlist;
camera = webcam(list{2});
out = imagecapture(camera,FringePattern,2,PatternPars);
