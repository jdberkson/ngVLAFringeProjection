% Capture image from the camera
% Author: Hyukmo Kang, Joel Berkson
% Email: hkang@optics.arizona.edu, joelsteraz@email.arizona.edu
% Edit Log
% 4/8/20, First draft, Hyukmo Kang
% 8/10/20, Second draft, Joel Berkson

function [out1, out2] = captureImages(vidobj1,vidobj2,FringePattern,ScreenNum,PatternPars)% ;,CameraPars)
    %This function outputs an image stack of the captured images of each
    %phase step of the fringe pattern as seen through the UUT reflection
    %Create videoinput object
    monitor_info = get(0,'MonitorPosition');
%     VideoResolution =  get(vidobj, 'VideoResolution');  
    try 
        testim = getsnapshot(vidobj1);
        vidobj1.FramesPerTrigger = 1;
        vidobj2.FramesPerTrigger = 1;
        src1 = getselectedsource(vidobj1);
        src2 = getselectedsource(vidobj2);
        src1.ExposureAuto = 'Off';
        src2.ExposureAuto = 'Off';
        src1.GainAuto = 'Off';
        src2.GainAuto = 'Off';
        src1.Gamma = 1;
        src2.Gamma = 1;
        src1.Gain = 25;
        src2.Gain = 25;
        src1.ExposureTime = 50000;
        src2.ExposureTime = 50000;

        vidobj1.ROIPosition = [0 0 5472 3648];
        vidobj2.ROIPosition = [0 0 5472 3648];
    catch
        testim = snapshot(vidobj1);
        vidobj1.Exposure = -4;
        vidobj2.Exposure = -4;
        vidobj1.Gain = 0;
        vidobj2.Gain = 0;
    end

%     figure;gca;
%     previewhandle1= image( zeros([3648,5472, 3], 'uint16') );
%     preview(vid1,previewhandle1)
    VideoResolution(1) = size(testim,2);
    VideoResolution(2) = size(testim,1);
    %Dispay initial pattern on screen
    fullscreen(FringePattern(:,:,1),ScreenNum)
    [Proj_H, Proj_W] = size(FringePattern(:,:,1));
    VerticalLine = zeros(Proj_H,Proj_W);
    VerticalLine(:,round(Proj_W/2)) = 255;
    HorizontalLine = zeros(Proj_H,Proj_W);
    HorizontalLine(round(Proj_H/2),:) = 255;
    BlackScreen = 255*zeros(Proj_H,Proj_W);
    WhiteScreen = 255*ones(Proj_H,Proj_W);

 
    RepNum = 2*PatternPars.Steps;
    %Preallocate Image arrays
    Snapshot1 = zeros(VideoResolution(2),VideoResolution(1),PatternPars.Average);
    Snapshot2 = zeros(VideoResolution(2),VideoResolution(1),PatternPars.Average);

    CapturedImage1 = zeros(VideoResolution(2),VideoResolution(1),RepNum);
    CapturedImage2 = zeros(VideoResolution(2),VideoResolution(1),RepNum);
    k = 1;
    figure; subplot(1,2,1);title('Camera 1');subplot(1,2,2); title('Camera 2')
    for i=1:RepNum
        
        fullscreen(uint8(FringePattern(:,:,i)),2)

        pause(PatternPars.Interval)

        %Capture images for number of averages requested
        for j=1:PatternPars.Average            
            try
                Snapshot1(:,:,j) = getsnapshot(vidobj1);
                Snapshot2(:,:,j) = getsnapshot(vidobj2);
            catch
                Snapshot1(:,:,j) = rgb2gray(snapshot(vidobj1));
                Snapshot2(:,:,j) = rgb2gray(snapshot(vidobj2));
            end
        end
        
        %Average the snapshot stack
        AvgSnapshot1 = sum(Snapshot1,3)/PatternPars.Average;   
        AvgSnapshot2 = sum(Snapshot2,3)/PatternPars.Average;
        %Append the image stack
        subplot(1,2,1); imagesc(AvgSnapshot1);
        subplot(1,2,2); imagesc(AvgSnapshot2); drawnow;
        CapturedImage1(:,:,k) = AvgSnapshot1;
        CapturedImage2(:,:,k) = AvgSnapshot2;
        k = k+1;
    end
    try
        src1.ExposureTime = 200000;
        src2.ExposureTime = 200000;
    catch
        vidobj1.Exposure = -2;
        vidobj2.Exposure = -2;
        vidobj1.Gain = 100;
        vidobj2.Gain = 100;
    end
            vidobj1.Exposure = -2;
        vidobj2.Exposure = -2;
        vidobj1.Gain = 100;
        vidobj2.Gain = 100;
    fullscreen(uint8(VerticalLine),2)
    pause(PatternPars.Interval)
    for j=1:PatternPars.Average            
        try
            Snapshot1(:,:,j) = getsnapshot(vidobj1);
            Snapshot2(:,:,j) = getsnapshot(vidobj2);
        catch
            Snapshot1(:,:,j) = rgb2gray(snapshot(vidobj1));
            Snapshot2(:,:,j) = rgb2gray(snapshot(vidobj2));
        end
    end
    %Average the snapshot stack
    AvgSnapshot1 = sum(Snapshot1,3)/PatternPars.Average;   
    AvgSnapshot2 = sum(Snapshot2,3)/PatternPars.Average;  
    subplot(1,2,1); imagesc(AvgSnapshot1);
    subplot(1,2,2); imagesc(AvgSnapshot2); drawnow;
    CapturedImage1(:,:,end+1) = AvgSnapshot1;
    CapturedImage2(:,:,end+1) = AvgSnapshot2;

    fullscreen(uint8(HorizontalLine),2)

    pause(PatternPars.Interval)
    for j=1:PatternPars.Average            
        try
            Snapshot1(:,:,j) = getsnapshot(vidobj1);
            Snapshot2(:,:,j) = getsnapshot(vidobj2);
        catch
            Snapshot1(:,:,j) = rgb2gray(snapshot(vidobj1));
            Snapshot2(:,:,j) = rgb2gray(snapshot(vidobj2));
        end
    end
    %Average the snapshot stack
    AvgSnapshot1 = sum(Snapshot1,3)/PatternPars.Average;   
    AvgSnapshot2 = sum(Snapshot2,3)/PatternPars.Average;  
    subplot(1,2,1); imagesc(AvgSnapshot1);
    subplot(1,2,2); imagesc(AvgSnapshot2); drawnow;
    CapturedImage1(:,:,end+1) = AvgSnapshot1;
    CapturedImage2(:,:,end+1) = AvgSnapshot2;
    
    fullscreen(uint8(BlackScreen),2)
    pause(PatternPars.Interval)
    for j=1:PatternPars.Average            
        try
            Snapshot1(:,:,j) = getsnapshot(vidobj1);
            Snapshot2(:,:,j) = getsnapshot(vidobj2);
        catch
            Snapshot1(:,:,j) = rgb2gray(snapshot(vidobj1));
            Snapshot2(:,:,j) = rgb2gray(snapshot(vidobj2));
        end
    end
    %Average the snapshot stack
    AvgSnapshot1 = sum(Snapshot1,3)/PatternPars.Average;   
    AvgSnapshot2 = sum(Snapshot2,3)/PatternPars.Average;  
    subplot(1,2,1); imagesc(AvgSnapshot1);
    subplot(1,2,2); imagesc(AvgSnapshot2); drawnow;
    CapturedImage1(:,:,end+1) = AvgSnapshot1;
    CapturedImage2(:,:,end+1) = AvgSnapshot2;
    
    fullscreen(uint8(WhiteScreen),2)
    vidobj1.Exposure = -6;
    vidobj2.Exposure = -6;
    pause(PatternPars.Interval)
    for j=1:PatternPars.Average            
        try
            Snapshot1(:,:,j) = getsnapshot(vidobj1);
            Snapshot2(:,:,j) = getsnapshot(vidobj2);
        catch
            Snapshot1(:,:,j) = rgb2gray(snapshot(vidobj1));
            Snapshot2(:,:,j) = rgb2gray(snapshot(vidobj2));
        end
    end
    %Average the snapshot stack
    AvgSnapshot1 = sum(Snapshot1,3)/PatternPars.Average;   
    AvgSnapshot2 = sum(Snapshot2,3)/PatternPars.Average;  
    subplot(1,2,1); imagesc(AvgSnapshot1);
    subplot(1,2,2); imagesc(AvgSnapshot2); drawnow;
    CapturedImage1(:,:,end+1) = AvgSnapshot1;
    CapturedImage2(:,:,end+1) = AvgSnapshot2;
    
    %Set output to image stack
    out1 = CapturedImage1-CapturedImage1(:,:,end-1);
    out2 = CapturedImage2-CapturedImage2(:,:,end-1);
    
end