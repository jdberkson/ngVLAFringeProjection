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
    vidobj1.Resolution = '3264x2448';
    vidobj2.Resolution = '3264x2448';
    WebcamRes = get(vidobj1, 'Resolution');
    VideoResolution(1) = str2num(WebcamRes(1:4));
    VideoResolution(2) = str2num(WebcamRes(6:end));
    %Dispay initial pattern on screen
    fullscreen(FringePattern(:,:,1),ScreenNum)
    [Proj_H, Proj_W] = size(FringePattern(:,:,1));
    VerticalLine = zeros(Proj_H,Proj_W);
    VerticalLine(:,round(Proj_W/2):round(Proj_W/2)+1) = 255;
    HorizontalLine = zeros(Proj_H,Proj_W);
    HorizontalLine(round(Proj_H/2):round(Proj_H/2)+1,:) = 255;
 
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
            Snapshot1(:,:,j) = rgb2gray(snapshot(vidobj1));
            Snapshot2(:,:,j) = rgb2gray(snapshot(vidobj2));
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
    
    fullscreen(uint8(VerticalLine),2)
    pause(PatternPars.Interval)
    for j=1:PatternPars.Average            
        Snapshot1(:,:,j) = rgb2gray(snapshot(vidobj1));
        Snapshot2(:,:,j) = rgb2gray(snapshot(vidobj2));
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
        Snapshot1(:,:,j) = rgb2gray(snapshot(vidobj1));
        Snapshot2(:,:,j) = rgb2gray(snapshot(vidobj2));
    end
    %Average the snapshot stack
    AvgSnapshot1 = sum(Snapshot1,3)/PatternPars.Average;   
    AvgSnapshot2 = sum(Snapshot2,3)/PatternPars.Average;  
    subplot(1,2,1); imagesc(AvgSnapshot1);
    subplot(1,2,2); imagesc(AvgSnapshot2); drawnow;
    CapturedImage1(:,:,end+1) = AvgSnapshot1;
    CapturedImage2(:,:,end+1) = AvgSnapshot2;
    
    %Set output to image stack
    out1 = CapturedImage1;
    out2 = CapturedImage2;
    
end