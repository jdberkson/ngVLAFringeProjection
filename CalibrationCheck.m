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
newCalibrationImages = {1, 2};

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
    newCalibrationImages{1, 1} = char(filenameFinal1);
    I_cam2 = snapshot(vid2);
    imwrite(I_cam2,filenameFinal2);
    newCalibrationImages{1, 2} = char(filenameFinal2);
    elapsedTime = 0;
end

%obtain the old images from a previous calibration session
OGCalibrationSession = uigetfile('', 'Select a calibration session');
OGCalibrationImages = OGCalibratinSession.BoardSet.FullPathNames;

%add the new calibration picture set to the original calibration images
newCalibrationSet = cat(1, OGCalibrationImages, newCalibrationImages);

% Detect checkerboards in images
[imagePoints, boardSize, imagesUsed] = detectCheckerboardPoints(newCalibrationSet(1,:), newCalibrationSet(2,:));

% Generate world coordinates of the checkerboard keypoints
squareSize = currSquareSize;  % in units of 'millimeters'
worldPoints = generateCheckerboardPoints(boardSize, squareSize);

% Read one of the images from the first stereo pair
I1 = imread(newCalibrationSet{1});
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
I2 = imread(newCalibrationSet{1,2});
[J1, J2] = rectifyStereoImages(I1, I2, stereoParams);

% See additional examples of how to use the calibration data.  At the prompt type:
% showdemo('StereoCalibrationAndSceneReconstructionExample')
% showdemo('DepthEstimationFromStereoVideoExample')

%obtain the reprojection error of only the calibration check (CC) set of images
numImages = size(newCalibrationSet);
numImages = numImages(1);
CCReprojErrors = stereoParams.ReprojectionErrors(:, :, numImages);

%find the average Euclidean distance (AED) for the CC set
CCsize = size(CCReprojErrors);
AED = 0;

for i = 1:CCsize(1)
   ED = sqrt((CCReprojErrors(i, 1)^2) + (CCReprojErrors(i, 2)^2));
   AED = AED + ED;
end

AED = AED/CCsize(1);

%output the original reprojection error and the new error to the command
%window
OGReprojError = currStereoParams.MeanReprojectionError;

fprintf('Calibration Check Image Set Reprojection Error:    %6.4f\n', AED);
fprintf('Original Calibration Image Set Reprojection Error: %6.4f\n', OGReprojError);

end


