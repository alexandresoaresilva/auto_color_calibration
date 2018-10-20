

clear all
% load
clc


imgRef = imread('refer_color_checkernewCheck_NOT_norm_1.png')
pointsRef = detectSURFFeatures(rgb2gray(imgRef));
%indexPairs = matchFeatures(features, featuresRef, 'Unique', true,'NumOctaves',4)

[~,roi] = imcrop(imgRef);
% close(gcf)

x = roi(1)+ [0,roi(3)];
y = roi(2)+ [0,roi(4)];

toRemove = pointsRef.Location(:,1)<x(1) | pointsRef.Location(:,1)>x(2) | ...
            pointsRef.Location(:,2)<y(1) | pointsRef.Location(:,2)>y(2); 

pointsRef(toRemove) = [];

featuresRef = extractFeatures(rgb2gray(imgRef),pointsRef);
save('ref2.mat','featuresRef','imgRef','pointsRef');

























