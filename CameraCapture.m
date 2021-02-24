clc;
clear all;
close all;
% %this acquires the camera and sets some settings
% vid = videoinput('pointgrey', 1, 'F7_Mono16_1280x1024_Mode0');
% src = getselectedsource(vid);
% vid.FramesPerTrigger = 1;

vid1 = webcam(1);
vid2 = webcam(2);
vid1.Resolution = '3264x2448';
vid2.Resolution = '3264x2448';

%these are the settings for the countdown window
countdownfig = figure('numbertitle','off','name','COUNTDOWN',...
    'color','w','menubar','none','toolbar','none',...
    'pos',[0 0 300 400]);
edtpos = [0.1 0.1 0.8 0.8];
edtbox = uicontrol('style','edit','string','STARTING','units','normalized',...
    'position',edtpos,'fontsize',62,'foregroundcolor','r');

%variables
secs = 20;
numImages = 10;
min = 0;
elapsedTime = 0;
squareSize = 20; %in mm

%Setting up the address for the images to be saved was a bit tricky, I
%needed to divide it up into 4 seperate variables.
%Change finenameAddress to the location you'd like to save all your
%pictures.
%Change filenameName to what you'd like to name all the pictures and the
%file type you'd like to save it as.
filenameAddress_cam1 = "C:\Users\OASIS_Deflectometry\Documents\MATLAB\ngVLA\ngVLA\FringeProjection\FringeProjection\Data_cam1\";
filenameAddress_cam2 = "C:\Users\OASIS_Deflectometry\Documents\MATLAB\ngVLA\ngVLA\FringeProjection\FringeProjection\Data_cam2\";
filenameName = "picture_%d.png";

%first loop is the number of pictures, second loop is the number of
%seconds between each picture
for j = 1:numImages
    preview(vid1);
    preview(vid2);
    pause(5)
    
    filenameFinalName = sprintf(filenameName, j);
    filenameFinal_cam1 = strcat(filenameAddress_cam1, filenameFinalName);
    filenameFinal_cam2 = strcat(filenameAddress_cam2, filenameFinalName);

    for k = 1:secs
        elapsedTime = elapsedTime + 1;
        set(edtbox,'string',...
                datestr([2003  10  24  12  min secs-elapsedTime],'MM:SS'));
        pause(1);
    end
    if elapsedTime >= secs

        I_cam1 = snapshot(vid1);
        imwrite(I_cam1,filenameFinal_cam1);
        I_cam2 = snapshot(vid2);
        imwrite(I_cam2,filenameFinal_cam2);
        elapsedTime = 0;
    end
end



% cameraCalibrator;
% cameraCalibrator('C:\Users\rona5\Documents\SOSL files\Checkerboard Pics\', ...
%     squareSize);
% 
% % Define images to process
% imageFileNames = {'C:\Users\15204\Documents\LOFT\ngVLA\FringeProjection\Datapicture_1.png',...
%     'C:\Users\15204\Documents\LOFT\ngVLA\FringeProjection\Data\picture_2.png',...
%     'C:\Users\15204\Documents\LOFT\ngVLA\FringeProjection\Data\picture_3.png',...
%     'C:\Users\15204\Documents\LOFT\ngVLA\FringeProjection\Data\picture_4.png',...
%     'C:\Users\15204\Documents\LOFT\ngVLA\FringeProjection\Data\picture_5.png',...
%     'C:\Users\15204\Documents\LOFT\ngVLA\FringeProjection\Data\picture_6.png',...
%     'C:\Users\15204\Documents\LOFT\ngVLA\FringeProjection\Data\picture_7.png',...
%     'C:\Users\15204\Documents\LOFT\ngVLA\FringeProjection\Data\picture_8.png',...
%     'C:\Users\15204\Documents\LOFT\ngVLA\FringeProjection\Data\picture_9.png',...
%     'C:\Users\15204\Documents\LOFT\ngVLA\FringeProjection\Data\picture_10.png',...
%     'C:\Users\15204\Documents\LOFT\ngVLA\FringeProjection\Data\picture_11.png',...
%     'C:\Users\15204\Documents\LOFT\ngVLA\FringeProjection\Data\picture_12.png',...
%     };
% % Detect checkerboards in images
% [imagePoints, boardSize, imagesUsed] = detectCheckerboardPoints(imageFileNames);
% imageFileNames = imageFileNames(imagesUsed);
% 
% % Read the first image to obtain image size
% originalImage = imread(imageFileNames{1});
% [mrows, ncols, ~] = size(originalImage);
% 
% % Generate world coordinates of the corners of the squares
% worldPoints = generateCheckerboardPoints(boardSize, squareSize);
% 
% % Calibrate the camera
% [cameraParams, imagesUsed, estimationErrors] = estimateCameraParameters(imagePoints, worldPoints, ...
%     'EstimateSkew', false, 'EstimateTangentialDistortion', false, ...
%     'NumRadialDistortionCoefficients', 2, 'WorldUnits', 'mm', ...
%     'InitialIntrinsicMatrix', [], 'InitialRadialDistortion', [], ...
%     'ImageSize', [mrows, ncols]);
% 
% % View reprojection errors
% h1=figure; showReprojectionErrors(cameraParams);
% 
% % Visualize pattern locations
% h2=figure; showExtrinsics(cameraParams, 'CameraCentric');
% 
% % Display parameter estimation errors
% displayErrors(estimationErrors, cameraParams);
% 
% % For example, you can use the calibration data to remove effects of lens distortion.
% undistortedImage = undistortImage(originalImage, cameraParams);
% 
% cameraParams
% estimationErrors
