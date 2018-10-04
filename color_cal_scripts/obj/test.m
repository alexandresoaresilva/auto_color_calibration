clear, clc;
addpath('img');
file_name = 'check8.png';
I = imread(file_name);

a = colorCalib(I, file_name, 1);

M = a.getM_transf_3x3_matrix(colorCalib);

I_corrected = a.calibration_routine(I,M);
imshow([a.I_check_from_cam, I_corrected]);
hold on
scatter(a.color_pos(:,1), a.color_pos(:,2));