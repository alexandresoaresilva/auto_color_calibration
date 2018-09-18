%wrapper for correctcolor, calibratecolor that corrects image and displays
%percent error

%image = imread('manuallyalignedreferencetopcam.png');

image = double(imread('color1.png'));
imagegray = double(imread('color0.png'));
%image = double(image) ./ double(imagegray);
imageforcorrection = double(imread('nonuniform_3.png'));
% imageforcorrection = image;
%imageforcorrection = imread('imageforcorrectionexampletopcam.png');
load('colorcoords.mat');
load('RGBreference.mat');

%sample colors from pic
RGB = zeros(24, 3);

for i = 1:24 % image(pixel_vertical,pixel_horizontal,[R G B])
%	RGB(i, :) = image(colorcoords(i, 1), colorcoords(i, 2), :);
    RGB(i, :) = floor(mean([...
        image(colorcoords(i, 1), colorcoords(i, 2), :);... %1st row
        image(colorcoords(i, 1) + 5, colorcoords(i, 2), :); ...
        image(colorcoords(i, 1), colorcoords(i, 2) + 5, :); ...
        image(colorcoords(i, 1) - 5, colorcoords(i, 2), :); ...
        image(colorcoords(i, 1), colorcoords(i, 2) - 5, :)...
        ], 1)...
        );
end

%load('RGBtopcam2.mat');
calcos = calibratecolor(RGBREF, RGB);

imagecor = correctcolor(calcos, image);
imagecorrected = correctcolor(calcos, imageforcorrection);
RGBCOR = correctcolor(calcos, RGB);

errormatrix = abs(RGBREF - RGB);
figure(1)
barcolorm = [1 0 0; 0 1 0; 0 0 1];
b = bar(errormatrix,'FaceColor','flat');
index = 1;

for k = 1:size(errormatrix)*size(errormatrix,2)
    if index == 4
        index = 1;
    end
    
    %b.CData = barcolorm(index, :)
    index = index+1;
end

errorig = sum(abs(RGBREF(:) - RGB(:))) / (3 * 24);
errcor = sum(abs(RGBREF(:) - RGBCOR(:))) / (3 * 24);
fprintf('Percent error in original: %d\n', errorig);
fprintf('Percent error in correction: %d\n', errcor);

image = uint8(image);
height = size(image, 1);
width = size(image, 2);
imagecor = uint8(reshape(imagecor(:), height, width, 3));
height = size(imageforcorrection, 1);
width = size(imageforcorrection, 2);
imagecorrected = uint8(reshape(imagecorrected(:), height, width, 3));
figure(2)
imshow(imagecor);
figure(3)
imshow(image);
figure(4)
imshow(imagecorrected);
imwrite(imagecorrected, 'imagecorrected.png');
