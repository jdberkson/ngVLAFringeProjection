clear all
clc

%this acquires the camera and sets some settings
vid = videoinput('winvideo', 1, 'YUY2_1280x720');
src = getselectedsource(vid);
vid.FramesPerTrigger = 1;

%function to create dialog box to gather inputs
[squareSize, numImages, cameraType, folderName, secs] = inputDlg;

%if the folder does not exist, then create a new one
if not(exist(folderName,'dir'))
    mkdir(folderName)
end

%these are the settings for the countdown window
countdownfig = figure('numbertitle','off','name','COUNTDOWN',...
    'color','w','menubar','none','toolbar','none',...
    'pos',[0 0 300 400]);
edtpos = [0.1 0.1 0.8 0.8];
edtbox = uicontrol('style','edit','string','STARTING','units','normalized',...
    'position',edtpos,'fontsize',62,'foregroundcolor','r');

%variables
min = 0;
elapsedTime = 0;
imageFileNames = {1, numImages};

%name of pictures and their address using the value from the dialog box 
%address
filenameAddress = pwd;
filenameFolder = strcat(filenameAddress, '\', folderName, '\');
filenameName = "picture_%d.png";

%first loop is the number of pictures, second loop is the number of
%seconds between each picture
for j = 1:numImages
    preview(vid);
    
    %create address's for the individual pictures
    filenameFinalName = sprintf(filenameName, j);
    filenameFinal = strcat(filenameFolder, filenameFinalName);
    imageFileNames{1, j} = char(filenameFinal);
    
    %dialog box pauses operation, allowing the user to resize the window
    %before starting.
    if j == 1
        uiwait(msgbox('Please focus the camera. Press OK to continue.',...
            'modal'));
    end
    
    for k = 1:secs
        elapsedTime = elapsedTime + 1;
        set(edtbox,'string',...
                datestr([2003  10  24  12  min secs-elapsedTime],'MM:SS'));
        pause(1);
    end
    if elapsedTime >= secs
        start(vid);
        stoppreview(vid);
        imwrite(getdata(vid), filenameFinal);
        elapsedTime = 0;
    end
end

stoppreview(vid);

%start Camera Calibrator app
cameraCalibrator(filenameFolder, squareSize);

% Detect checkerboards in images
[imagePoints, boardSize, imagesUsed] = detectCheckerboardPoints(imageFileNames);
imageFileNames = imageFileNames(imagesUsed);

% Read the first image to obtain image size
originalImage = imread(imageFileNames{1});
[mrows, ncols, ~] = size(originalImage);

% Generate world coordinates of the corners of the squares
worldPoints = generateCheckerboardPoints(boardSize, squareSize);

% Calibrate the camera
if cameraType == "Standard"
    [cameraParams, imagesUsed, estimationErrors] = estimateCameraParameters(imagePoints, worldPoints, ...
        'EstimateSkew', false, 'EstimateTangentialDistortion', false, ...
        'NumRadialDistortionCoefficients', 2, 'WorldUnits', 'mm', ...
        'InitialIntrinsicMatrix', [], 'InitialRadialDistortion', [], ...
        'ImageSize', [mrows, ncols]);
elseif cameraType == "Fisheye"
    [cameraParams, imagesUsed, estimationErrors] = estimateFisheyeParameters(imagePoints, worldPoints, ...
    [mrows, ncols], ...
    'EstimateAlignment', false, ...
    'WorldUnits', 'millimeters');
end

% View reprojection errors
h1=figure; showReprojectionErrors(cameraParams);

% Visualize pattern locations
h2=figure; showExtrinsics(cameraParams, 'CameraCentric');

% Display parameter estimation errors
displayErrors(estimationErrors, cameraParams);

% For example, you can use the calibration data to remove effects of lens distortion.
if cameraType == "Standard"
    undistortedImage = undistortImage(originalImage, cameraParams);
elseif cameraType == "Fisheye"
    undistortedImage = undistortFisheyeImage(originalImage, cameraParams.Intrinsics);
end
    
cameraParams
estimationErrors

function [squareSize,numImages,cameraType,folderName,secs]=inputDlg
hfig=figure('CloseRequestFcn',@close_req_fun,'menu','none',...
    'pos', [500, 600, 350, 200],'numbertitle','off','name',...
    'Setup');
cameraType_list={'Standard','Fisheye'};
defaultSS='20';
defaultSecs='30';
folderNameInput='Checkerboard Pics';
%set defaults
squareSizeStr=defaultSS;
secsStr=defaultSecs;
cameraType=cameraType_list{1};
%create GUI
set(hfig,'menu','none')
field1=uicontrol('Style', 'Edit', 'String', squareSizeStr, ...
    'Parent',hfig,'Units','Normalized', ...
    'Position', [.45, .7, .2, .08]);
field2=uicontrol('Style', 'Edit', 'String', squareSizeStr, ...
    'Parent',hfig,'Units','Normalized', ...
    'Position', [.45, .6, .2, .08]);
dropdown=uicontrol('Style', 'popupmenu', 'String', cameraType_list, ...
    'Parent',hfig,'Units','Normalized', ...
    'Position', [.45, .5, .45, .08]);
field3=uicontrol('Style', 'Edit', 'String', folderNameInput, ...
    'Parent',hfig,'Units','Normalized', ...
    'Position', [.45, .4, .45, .08]);
field4=uicontrol('Style', 'Edit', 'String', secsStr, ...
    'Parent',hfig,'Units','Normalized', ...
    'Position', [.45, .3, .2, .08]);
uicontrol('Style', 'pushbutton', 'String', 'OK', ...
    'Parent',hfig,'Units','Normalized', ...
    'Position', [.35 .1 .13 .11],...
    'Callback','close(gcbf)');
cancel=uicontrol('Style', 'pushbutton', 'String', 'Cancel', ...
    'Parent',hfig,'Units','Normalized', ...
    'Position', [.55 .1 .13 .11],...
    'Tag','0','Callback',@cancelfun);
uicontrol('Style','text','String','Square size (mm):','Parent',hfig,...
    'Units','Normalized','Position',[.15 .7 .3 .08]);
uicontrol('Style','text','String','Number of images:','Parent',hfig,...
    'Units','Normalized','Position',[.14 .6 .3 .08]);
uicontrol('Style','text','String','Camera type:','Parent',hfig,...
    'Units','Normalized','Position',[.2 .5 .25 .08]);
uicontrol('Style','text','String','New folder name:','Parent',hfig,...
    'Units','Normalized','Position',[.145 .4 .3 .08]);
uicontrol('Style','text','String','Countdown (s):',...
    'Parent',hfig,'Units','Normalized','Position',[.19 .3 .25 .08]);
%wait for figure being closed (with OK button or window close)
uiwait(hfig)
%figure is now closing
if strcmp(cancel.Tag,'0')%not canceled, get actual inputs
    squareSizeStr=field1.String;
    squareSize = str2double(squareSizeStr);
    numImagesStr=field2.String;
    numImages = str2double(numImagesStr);
    cameraType=cameraType_list{dropdown.Value};
    folderName=field3.String;
    secsStr=field4.String;
    secs=str2double(secsStr);
end
%actually close the figure
delete(hfig)
end
function cancelfun(h,~)
set(h,'Tag','1')
uiresume
end
function close_req_fun(~,~)
uiresume
end