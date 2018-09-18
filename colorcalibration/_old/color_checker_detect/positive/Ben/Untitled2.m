
clear all
%load ref.mat
load ref2.mat

clc

cam = webcam('Intel(R) RealSense(TM) 3D Camera (Front F200) RGB');
%cam = webcam('Intel(R) RealSense(TM) Camera SR300 RGB');
cam.Resolution = '640x480';
while 1
    img = cam.snapshot;
    clf
    subplot(1,2,1); imagesc(img); axis equal; axis tight
    points = detectSURFFeatures(rgb2gray(img),'NumOctaves',4);
    features = extractFeatures(rgb2gray(img),points);
    
    indexPairs = matchFeatures(features, featuresRef, 'Unique', true);
    %indexPairs = matchFeatures(features, featuresRef,'MaxRatio',0.6);
    numel(indexPairs)
    matchedPoints = points(indexPairs(:,1), :);
    matchedPointsPrev = pointsRef(indexPairs(:,2), :);

    if matchedPoints.Count < 20
        drawnow
        pause(0.2)
        continue;
    end
    
    tform = estimateGeometricTransform(matchedPoints, matchedPointsPrev,...
        'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);
    
    panoramaView = imref2d([480 640], [1,640], [1,480]);

    warpedImage = imwarp(img, tform, 'OutputView', panoramaView);
    subplot(1,2,2); imagesc(warpedImage); axis equal; axis tight
    
    drawnow
end
