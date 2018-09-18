



clear all
load ref.mat
clc

img = cam.snapshot;
clf
subplot(1,2,1); imagesc(img); axis equal; axis tight
points = detectSURFFeatures(rgb2gray(img));
features = extractFeatures(rgb2gray(img),points);

indexPairs = matchFeatures(features, featuresRef, 'Unique', true);
numel(indexPairs)
matchedPoints = points(indexPairs(:,1), :);
matchedPointsPrev = pointsRef(indexPairs(:,2), :);
% 
% if matchedPoints.Count < 50
%  %   drawnow
%     continue;
% end

tform = estimateGeometricTransform(matchedPoints, matchedPointsPrev,...
    'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);

panoramaView = imref2d([480 640], [1,640], [1,480]);

warpedImage = imwarp(img, tform, 'OutputView', panoramaView);
subplot(1,2,2); imagesc(warpedImage); axis equal; axis tight

%drawnow