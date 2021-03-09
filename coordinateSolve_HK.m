function [matchedPoints1 matchedPoints2] = coordinateSolve_HK(cam1H, cam1V, cam2H, cam2V,debugON)

% This function returns the XY coordinates of points between phases on
% Camera 1 and Camera 2. 
%Inputs
%   cam1H/cam1V: Horizontal and Vertical phase of Camera 1 image
%   cam2H/cam2V: Horizontal and Vertical phase of Camera 2 image
%   debugON: debug flag. 1 to view matching contour points and the
%   intersection point for each matched point. 0 to turn off
%Outputs
%   
warning('off','all')
%if any pixels are NaN, replace them and their corresponding pixel on the
%other camera with 0

scale = 1;

[M,N] = size(cam1H);
cam2H = round(cam2H,4);
cam2V = round(cam2V,4);


cam1H = round(cam1H,4);
cam1V = round(cam1V,4);

% cam1H = CropAperture(cam1H,10);
% cam1V = CropAperture(cam1V,10);


matchedPointsX = [];
matchedPointsY = [];
x_intersect = [];
y_intersect = [];

ref_col = cam1H;
ref_row = cam1V;
ref_col_v = reshape(ref_col,size(ref_col,1)*size(ref_col,2),1);
ref_row_v = reshape(ref_row,size(ref_row,1)*size(ref_row,2),1);
[colN,rowN] = meshgrid(1:3264,1:2448);
colN_v = reshape(colN,size(ref_row,1)*size(ref_row,2),1);
rowN_v = reshape(rowN,size(ref_row,1)*size(ref_row,2),1);
ref_col_v = round(ref_col_v,2);
ref_row_v = round(ref_row_v,2);
ref_pair = complex(ref_col_v,ref_row_v);
% a = length(ref_pair)
% b = length(unique(ref_pair))


pert_col = cam2H;
pert_row = cam2V;
pert_col_v = reshape(pert_col,size(pert_col,1)*size(pert_col,2),1);
pert_row_v = reshape(pert_row,size(pert_row,1)*size(pert_row,2),1);
pert_col_v = round(pert_col_v,2);
pert_row_v = round(pert_row_v,2);
pert_pair = complex(pert_col_v,pert_row_v);
% a = length(pert_pair)
% b = length(unique(pert_pair))

% isequal(a,b)
%

[C,ia,ib] = intersect(ref_pair,pert_pair,'row');

x = colN_v(ia);
y = rowN_v(ia);
matchedPoints1 = [x';y'];
x2 = colN_v(ib);
y2 = rowN_v(ib);
matchedPoints2 = [x2';y2'];


end
