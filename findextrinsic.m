ProjPicsFilename = 'C:\Users\15204\Documents\LOFT\ngVLA\FringeProjection\FringeProjection\ProjPics';
CamPicsFilename = 'C:\Users\15204\Documents\LOFT\ngVLA\FringeProjection\FringeProjection\CamPics';

leftImages = imageDatastore(CamPicsFilename);
rightImages = imageDatastore(ProjPicsFilename);

[imagePoints,boardSize] = detectCheckerboardPoints(leftImages.Files,rightImages.Files);

squareSize = 108;
worldPoints = generateCheckerboardPoints(boardSize,squareSize);
params = estimateCameraParameters(imagePoints,worldPoints);