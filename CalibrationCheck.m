function newReprojError = CalibrationCheck(currStereoParams, currSquareSize)
%this acquires the camera and sets some settings
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

%start image accquisition, set some variables, name the calibration check
%picture
preview(vid1);
preview(vid2);
min = 0;
secs = 10;
elapsedTime = 0;
filenameFinal1 = strcat(pwd, '\', 'calibration_check_pic1.png');
filenameFinal2 = strcat(pwd, '\', 'calibration_check_pic2.png');

%countdown for 1 image
%NOTE: edit this for two cameras. You'll also need to change the camera
%settings at the beginning. Just use Joel's code from github
for k = 1:secs
    elapsedTime = elapsedTime + 1;
    set(edtbox,'string',...
        datestr([2003  10  24  12  min secs-elapsedTime],'MM:SS'));
    pause(1);
end
if elapsedTime >= secs
    I_cam1 = snapshot(vid1);
    imwrite(I_cam1,filenameFinal1);
    I_cam2 = snapshot(vid2);
    imwrite(I_cam2,filenameFinal2);
    elapsedTime = 0;
end

%ask for the folders for camera 1 pictures, THEN camera 2 pictures
cameraDir1 = uigetdir;
cameraDir2 = uigetdir;
CameraDirContents1 = dir(fullfile(cameraDir1, '*.png'));
CameraDirContents2 = dir(fullfile(cameraDir2, '*.png'));

%find the number of sets of pictures
numImages = size(CameraDirContents1);
imageFileNames1 = {1, numImages + 1};
imageFileNames2 = {1, numImages + 1};

%obtain the names for the pictures
for i = 1:numImages(1)
    filenameFinal = strcat(cameraDir1, '\', CameraDirContents1(1).name);
    imageFileNames1{1, i} = char(filenameFinal);
    filenameFinal = strcat(cameraDir2, '\', CameraDirContents2(1).name);
    imageFileNames2{1, i} = char(filenameFinal);
end

%add the new calibration picture set to the original calibration images
imageFileNames1(1, numImages + 1) = filenameFinal1;
imageFileNames2(1, numImages + 1) = filenameFinal2;

%obtain the original reprojection error
reprojErrors = currStereoParams.ReprojectionErrors;

% Detect checkerboards in images
[imagePoints, boardSize, imagesUsed] = detectCheckerboardPoints(imageFileNames1, imageFileNames2);

% Generate world coordinates of the checkerboard keypoints
squareSize = currSquareSize;  % in units of 'millimeters'
worldPoints = generateCheckerboardPoints(boardSize, squareSize);

% Read one of the images from the first stereo pair
I1 = imread(imageFileNames1{1});
[mrows, ncols, ~] = size(I1);

% Calibrate the camera
[stereoParams, pairsUsed, estimationErrors] = estimateCameraParameters(imagePoints, worldPoints, ...
    'EstimateSkew', false, 'EstimateTangentialDistortion', false, ...
    'NumRadialDistortionCoefficients', 2, 'WorldUnits', 'millimeters', ...
    'InitialIntrinsicMatrix', [], 'InitialRadialDistortion', [], ...
    'ImageSize', [mrows, ncols]);

% View reprojection errors
h1=figure; showReprojectionErrors(stereoParams);

% Visualize pattern locations
h2=figure; showExtrinsics(stereoParams, 'CameraCentric');

% Display parameter estimation errors
displayErrors(estimationErrors, stereoParams);

% You can use the calibration data to rectify stereo images.
I2 = imread(imageFileNames2{1});
[J1, J2] = rectifyStereoImages(I1, I2, stereoParams);

% See additional examples of how to use the calibration data.  At the prompt type:
% showdemo('StereoCalibrationAndSceneReconstructionExample')
% showdemo('DepthEstimationFromStereoVideoExample')

%obtain the reprojection error of only the calibration check (CC) set of images
CCReprojErrors = stereoParams.ReprojectionErrors(:, :, numImages + 1);

%find the average Euclidean distance for the CC set
CCsize = size(CCreprojErrors);
AED = 0;

for i = 1:CCsize(1)
   ED = sqrt((CCReprojErrors(i, 1)^2) + (CCReprojErrors(i, 2)^2));
   AED = AED + ED;
end

AED = AED/CCsize(1);

OGReprojError = currStereoParams.MeanReprojectionError;

fprintf('Calibration Check Image Set Reprojection Error:    %6.4f\n', AED);
fprintf('Original Calibration Image Set Reprojection Error: %6.4f\n', OGReprojError);

end


