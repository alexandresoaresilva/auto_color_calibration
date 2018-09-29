gray = imread('grayCheckerJun2018.png');
pic_size = size(gray );
RGB_pic = double(gray(191:373,371:543,:))
sizeChartRef = size(RGB_pic);
grayRef = zeros(sizeChartRef);


for i=1:3 % 3 rgb channels
    grayRef(:,:,i) = 119;
end
length_sample_list = sizeChartRef(1)*sizeChartRef(2);
grayRef_list = reshape(grayRef, [length_sample_list 3]);
RGB_pic_list = reshape(RGB_pic, [length_sample_list 3]);
%RGB_meanRGB = round(RGB_meanRGB);
%M = lsqminnorm(RGB_select,grayRef);
M = RGB_pic_list\grayRef_list;

gray_list = reshape(gray, [pic_size(1)*pic_size(2) pic_size(3)]);
%RGB_pic_list = reshape(RGB_pic,[pic_size(1)*pic_size(2)  3]);
%calibrated = lsqminnorm(double(gray_list),M);
calibrated = double(gray_list)*M;

gray_cal  = reshape(calibrated,[pic_size(1) pic_size(2) pic_size(3)]);
%a = gray - round(gray_cal)
imshow([round(gray_cal),gray]);
title('1st calibrated; 2nd normal')