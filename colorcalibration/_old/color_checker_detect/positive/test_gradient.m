clear
close all
k = 10;
sigma1 =  0.5;
sigma2 = sigma1*k;
addpath('Sarraf_detect\checker_imgs');
I = imread('check8.png');

I = imresize(I,[480 640]);
gauss1 = imgaussfilt(I,sigma1);
gauss2 = imgaussfilt(I,sigma2);

figure
imshow([gauss1,gauss2]);
dogImg = gauss1 - gauss2;
dogImg = dogImg*10;
%dogImg(dogImg>10) =  255;

I_gray_gauss = rgb2gray(dogImg);

[Gmag,Gdir] = imgradient(I_gray_gauss);

Gmag = Gmag/max(max(Gmag));
Gmag=Gmag*255;
%Gdir(Gdir<0)=0;
Gdir = 255*Gdir/min(min(Gdir));
newIm = Gmag + Gdir
I_bw_gauss = imbinarize(dogImg);
figure
imshow([I_gray_gauss, Gmag, newIm])
title(['gray_gauss',...
    '            ----------------            ',...
    'Gmag',...
    '            ----------------            ',...
    'Gdir'])
% figure
% imshow(I_bw_gauss)
% title('gradient magnitude with binarized')