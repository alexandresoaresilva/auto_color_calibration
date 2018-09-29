clear, clc, close all;
%[ bluishgreen ; black ; brown; white ] [x, y;
%%  CONSTANTS
addpath('Sarraf_detect\checker_imgs');
addpath('Sarraf_detect\checker_imgs\fails_to_detect_any_patches');

I = imread('dist_checker_rotated.png');
I = imresize(I,[480 640]);


%height : bluish green-black
% widht : bluish green-brown
CHECKER_MIN_DIM = [237.00 301.00]; %[height width]
CHECKER_MIN_AREA = CHECKER_MIN_DIM(1) * CHECKER_MIN_DIM(2);
CHECKER_MAX_AREA = (CHECKER_MIN_DIM(1)+30)*(CHECKER_MIN_DIM(2)+30)*1.3;


color_sqr_max_area = (CHECKER_MIN_DIM(1)/4 * CHECKER_MIN_DIM(2)/6)*1.4;
COLOR_SQR_MIN_AREA = 40*40;
ref_positions =   [184, 162;...
                    184, 310;...
                    430, 162;...
                    430, 310];

%I = imread('dist_checker_rotated.png')
colors_select = ['r','y','w','c','m','r','g'];
%% CODE FOUND HERE
% https://stackoverflow.com/questions/20057146/is-there-any-difference-of-gaussians-function-in-matlab
k = 10;
sigma1 =  0.3;
sigma2 = sigma1*k;

hsize = [5,5];

% h1 = fspecial('gaussian', hsize, sigma1);
% h2 = fspecial('gaussian', hsize, sigma2);
% gauss1 = imfilter(I,h1,'replicate');
% gauss2 = imfilter(I,h2,'replicate');

gauss1 = imgaussfilt(I,sigma1);
gauss2 = imgaussfilt(I,sigma2);


dogImg = gauss1 - gauss2;
figure
dogImg = dogImg*10;
%dogImg(dogImg>25) = 255;
%I1=rgb2hsv(rgb1)
%I_gray_gauss = rgb2gray(dogImg);
I_gray_gauss = rgb2hsv(dogImg);
I_gray_gauss = I_gray_gauss(:,:,3);
imshow(I_gray_gauss );
I_bw_gauss = im2bw(dogImg);
hold on


% [Gmag,Gdir] = imgradient(I_gray_gauss);
% sub = I_gray_gauss;
 
gauss_props = regionprops(I_bw_gauss ,'Area','Centroid',...
     'BoundingBox');
[BB_gauss, BB_gauss_indeces, amount_detected_GAUSS] =...
    select_real_patches_from_BB(gauss_props, 40*40,...
    10000, [0.8 1.2])

for i=1:length(BB_gauss(:,1))
    j = mod(i,7)+1;
    color = colors_select(j);
    rectangles(i,:) = rectangle('Position',...
        BB_gauss(i,:),'EdgeColor', color,'LineWidth',1);
    i
end
xlabel([num2str(i),' boundingBoxes'])
hold off
%% binary new region props (maxima)
% checks whethere the bounding box has the expected area for the checker's
% square
function boolean_yes = isBB_withinArea(...
    boundBox_area, sqr_minArea, sqr_maxArea, ratio_width_height,...
    ratio_HW_lower_upper_bounds)
    
    boolean_yes = 0;
    if boundBox_area > sqr_minArea ...
    && boundBox_area < sqr_maxArea
        if ratio_width_height > ratio_HW_lower_upper_bounds(1)...
                && ratio_width_height < ratio_HW_lower_upper_bounds(2)
            boolean_yes = 1;
        end
    end
end

%% select_real_patches_from_BB
% ratio_HW_lower_upper_bounds: ratio of height / width of bounding boxes
% so if rectangular, around 0.5 to 1.5
% if sqr, 0.8-0.9 to 1.1 1.2 max]
function [detected_BB_patches, props_indeces, amount_detected] =...
    select_real_patches_from_BB(new_props, sqr_minArea,...
    sqr_maxArea, ratio_HW_lower_upper_bounds)

    j = 1;
    detected_BB_patches = [0 0 0 0];
    props_indeces = 0;
    
    for i=1:length(new_props)
        boundBox_area =...
            new_props(i).BoundingBox(3) * new_props(i).BoundingBox(4); 
        ratio_width_height = ...
            new_props(i).BoundingBox(3)/new_props(i).BoundingBox(4);
            
        if isBB_withinArea(boundBox_area, sqr_minArea,...
                sqr_maxArea, ratio_width_height,...
                ratio_HW_lower_upper_bounds)
                detected_BB_patches(j,:) = new_props(i).BoundingBox;
                props_indeces(j) = i;
                j = j + 1
        end
    end
    amount_detected = j;
end

function [I2, bw, objects_in_img] = removeNonUniformLight(img)
    background = imopen(img,strel('rectangle',[20 20]))*0.5;
    I2 = img - background;
    I3 = imadjust(I2);
    bw = imbinarize(I3);
    bw = bwareaopen(bw, 50);
    
    objects_in_img = bwconncomp(bw, 4);
end