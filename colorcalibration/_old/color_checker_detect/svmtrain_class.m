% gets present folder
script_folder = pwd;

addpath(script_folder);
img_names_pos = save_file_names_in_folder('positive','png');
img_names_neg = save_file_names_in_folder('negative','png');


no_of_rows_pos = size(img_names_pos,1);
no_of_rows_neg = size(img_names_neg,1);
row_total = no_of_rows_pos + no_of_rows_neg;

class_1 = zeros(no_of_rows_pos,...
    24*3+2); %1 is label, 1 is bias
load('colorcoords.mat');%where the colors are in terms of pixels
% positive samples
cd('positive');

for j=1:size(img_names_pos,1) %class 1, color checker
    img_dummy = imread(img_names_pos(j,:)); 
    checkerSamples = zeros(24,3);
     for i = 1:24 %*4 % image(pixel_vertical,pixel_horizontal,[R G B])
        checkerSamples(i,:) = floor(mean([...
            img_dummy(colorcoords(i, 1) + 5, colorcoords(i, 2), :);... %upper sample
            img_dummy(colorcoords(i, 1) - 5, colorcoords(i, 2), :); ...%down
            img_dummy(colorcoords(i, 1), colorcoords(i, 2) + 5, :); ...%rigth
            img_dummy(colorcoords(i, 1), colorcoords(i, 2) - 5, :); ...%left
            img_dummy(colorcoords(i, 1), colorcoords(i, 2), :)...%center
            ], 1)...
            );
     end
                    %bias data labels
    class_1(j,:) = [1 horizontalize_RGB(checkerSamples) 1];
end
cd(script_folder);
class_2 = zeros(no_of_rows_neg,...
    24*3+2); %1 is label, 1 is bias
% negative samples
cd('negative');
for j=1:no_of_rows_neg%class 1, color checker
    
    img_dummy = imread(img_names_neg(j,:)); 
    %load('colorcoords.mat');%where the colors are in terms of pixels
    %cd(script_folder);
    checkerSamples = zeros(24,3);
     for i = 1:24 %*4 % image(pixel_vertical,pixel_horizontal,[R G B])
        checkerSamples(i,:) = floor(mean([...
            img_dummy(colorcoords(i, 1) + 5, colorcoords(i, 2), :);... %upper sample
            img_dummy(colorcoords(i, 1) - 5, colorcoords(i, 2), :); ...%down
            img_dummy(colorcoords(i, 1), colorcoords(i, 2) + 5, :); ...%rigth
            img_dummy(colorcoords(i, 1), colorcoords(i, 2) - 5, :); ...%left
            img_dummy(colorcoords(i, 1), colorcoords(i, 2), :)...%center
            ], 1)...
            );
     end
    pos = no_of_rows_pos+j; %:row_total  
    class_2(pos,:) = [1 horizontalize_RGB(checkerSamples) -1];
end
cd(script_folder);
total_samples  = [-class_1; class_2];
%% first run, 0 <= lambda <= C = 0.1 and 0 <= lambda <= C = 100
% w = zeros(size(class_1,2),2);
% y=class_1(:,end);
% H = (class_1(:,1:(end-1).*y)*(class_1(:,1:3).*y)';
% f = -ones(length(samples),1);
% % Aeq*x = b_eq is the equality constrain
% Aeq = y';
% b_eq = 0;

%T =table(img_row_form)
%fitcsvm(table,y)