clear, clc, close all;
%[ bluishgreen ; black ; brown; white ] [x, y;
%%  CONSTANTS

%height : bluish green-black
% widht : bluish green-brown
CHECKER_MIN_DIM = [237.00 301.00]; %[height width]
CHECKER_MIN_AREA = CHECKER_MIN_DIM(1) * CHECKER_MIN_DIM(2);
CHECKER_MAX_AREA = (CHECKER_MIN_DIM(1)+30)*(CHECKER_MIN_DIM(2)+30)*1.3;

addpath('Sarraf_detect\checker_imgs');
addpath('Sarraf_detect\checker_imgs\fails_to_detect_any_patches');
I = imread('dist_checker_rotated.png');
color_sqr_max_area = (CHECKER_MIN_DIM(1)/4 * CHECKER_MIN_DIM(2)/6)*1.4;
COLOR_SQR_MIN_AREA = 40*40;
ref_positions =   [184, 162;...
                    184, 310;...
                    430, 162;...
                    430, 310];

%resize to 640x480

I = imresize(I,[480 640]);

fig_sel = figure('Name','selection');
fig_sel.Color = [.5 .5 .5];
imshow(I)

input_sel = {'\color[rgb]{0.4 0.8 0.7}bluish green',...
    '\color[rgb]{0 0 0}black', '\color[rgb]{.4 .2 0}brown',...
    '\color[rgb]{1 1 1}white'};
x = 0;
y = 0;
fig_sel.Visible = 'off';
fig_sel.Visible = 'on';
fig_sel.Position(4) = fig_sel.Position(4)+40;
fig_sel.MenuBar = 'none';

for i=1:4
    title(['\color[rgb]{1 1 1}select ',...
        cell2mat(input_sel(i)), ' \color[rgb]{1 1 1}corner ',...
        num2str(i)],'FontSize',25);
    
    a = xlabel(['\color[rgb]{1 1 1}select ',...
        cell2mat(input_sel(i))],'FontSize',25,'FontWeight','bold');

    [x(i),y(i)] = ginput(1);
    pause(0.1);
end
close selection

%% TRANSFORMATION (shear + rotation + scaling )
%x(1), y(1) bluish green
%x(2), y(2) black
%x(3), y(3) brown
%x(4), y(4) white
found_positions =  [x(1), y(1);
                    x(2), y(2);
                    x(3), y(3);
                    x(4), y(4)];
% [max_x,index_max_x] = max(x);
% [max_y,index_max_y] = max(y);
% 
% [min_x,index_min_x] = min(x);
% [min_y,index_min_y] = min(y);


%vector steps between squares
half_sqr_bluish_green_to_black =...
    round(abs(y(1) - y(2))/3);

% region of interest for corners
X = found_positions-half_sqr_bluish_green_to_black;

bw_distorted = im2bw(I,0.45);

intensities = [0.45, 0.6, 0.45, 0.6];

angle_between_bluish_and_black =....
    rad2deg(atan(abs((y(1) - y(2))/(x(1) - x(2)))));
figure
for i=1:4
    ratio_HW = [0.7 1.3];
    MIN_PATCH_SIZE = 40*40;
    if angle_between_bluish_and_black < 60
        cropPatchMaxArea = (half_sqr_bluish_green_to_black*3.5)^2;
        ratio_HW = [0.9 1.1];
        sqr_cropped =...
        imcrop(I,[X(i,:),...
        half_sqr_bluish_green_to_black*2.4, half_sqr_bluish_green_to_black*2.4]);
    else
        cropPatchMaxArea = (half_sqr_bluish_green_to_black*1.2)^2;
        sqr_cropped =...
        imcrop(I,[X(i,:),...
        half_sqr_bluish_green_to_black*2.4, half_sqr_bluish_green_to_black*2.4]);
    end
  
    bw_patch = im2bw(sqr_cropped,intensities(i));

    one_sqr_pros = regionprops(bw_patch,'Area','Centroid',...
         'BoundingBox');

    [boundingBoxes_sqr, boundingBoxes_sqr_indeces, sqrsDetected] =...
        select_real_patches_from_BB(one_sqr_pros, MIN_PATCH_SIZE,...
        cropPatchMaxArea, ratio_HW);

    if boundingBoxes_sqr_indeces > 0
        subplot(2,2,i)
        imshow(sqr_cropped)
        hold on
        found_positions(i,:) =...
            X(i,:) + one_sqr_pros(boundingBoxes_sqr_indeces(1)).Centroid;

        rectangle('Position', boundingBoxes_sqr(1,:), 'EdgeColor','b',...
            'LineWidth',1);
        hold off
    end
end

%I_bin_maxima = imregionalmax(bw_distorted);
%corners = detectHarrisFeatures(I_bin_maxima,'ROI',[X(1,:) 50 50]);
% one_sqr_pros = regionprops(bw_distorted,'Area','Centroid',...
%     'BoundingBox','ROI',[X(1,:) 50 50]);


%pts = detectMSERFeatures(bw_distorted,'ROI',[X(1,:) 70 70]);
%[features, valid_points] = extractFeatures(bw_distorted,pts,'Upright',true);

figure('Name','bw distorted corner detect')
imshow(bw_distorted )
hold on


tform = fitgeotrans(found_positions,ref_positions,'projective')

% u = [0 1]; 
% v = [0 0]; 
% %[x, y] = transformPointsForward(tform, u, v); 
% dx = x(2) - x(1); 
% dy = y(2) - y(1); 
% angle = (180/pi) * atan2(dy, dx);
% scale = 1 / sqrt(dx^2 + dy^2);

newI = imwarp(I,tform);
%bw = im2bw(newI);


%%

%I_bin = imbinarize(histeq(newI),0.2);
%I_bin = imbinarize(histeq(I),0.45);
%checker_max_size = [480 640]*.7;;



%bw = im2bw(newI,0.2);
bw = im2bw(newI,0.45);
%I_bin_maxima = imregionalmax(bw);
new_props = regionprops(bw,'Area','Centroid','BoundingBox');
%new_props = regionprops(I_bin_maxima,'Area','Centroid','BoundingBox');
stats = regionprops(not(bw))



j=1;
props_indeces = 0;
boundBox_area = 0;
boundingBoxes = [0 0 0 0];

mean_boundBox_area = 0;
    

checkerBoundingBox=[0 0 0 0 ];
 %% gets bound_box area and calc average area

for i=1:length(new_props)
    boundBox_area(i) =...
        new_props(i).BoundingBox(3) * new_props(i).BoundingBox(4); 
    ratio_width_height(i) = ...
        new_props(i).BoundingBox(3)/new_props(i).BoundingBox(4);

%     if boundBox_area(i) > COLOR_SQR_MIN_AREA ...
%        && boundBox_area(i) < color_sqr_max_area
%         if ratio_width_height(i) > 0.8 && ratio_width_height(i) < 1.2
% %             if ~(boundBox_area(i) > (mean_boundBox_area +mean_boundBox_area/5))...
% %                && (boundBox_area(i) < (3.5*mean_boundBox_area))
%                     boundingBoxes(j,:) = new_props(i).BoundingBox;
%                     props_indeces(j) = i;
%                     j = j + 1
% %             end
%         end
%     end
    
   if isBB_withinArea(boundBox_area(i),COLOR_SQR_MIN_AREA,...
           color_sqr_max_area, ratio_width_height(i),[0.9 1.1])
            boundingBoxes(j,:) = new_props(i).BoundingBox;
            props_indeces(j) = i;
            j = j + 1
   end

    %tests for the checker itself
    if boundBox_area(i) > CHECKER_MIN_AREA ...
        && boundBox_area(i) < CHECKER_MAX_AREA
        if ratio_width_height(i) > 0.5...
           && ratio_width_height(i) < 1.4
            checkerBoundingBox = new_props(i).BoundingBox
        end
    end
end

isoutlier(boundingBoxes)
figure
imshow(newI);
hold on
title('transformed');

colors_select = ['r','y','w','c','m','r','g'];

for i=1:length(boundingBoxes(:,1))
    j = mod(i,7)+1;
    color = colors_select(j);
    rectangles(i,:) = rectangle('Position',...
        boundingBoxes(i,:),'EdgeColor', color,'LineWidth',1);
    i
end

% topLeftCorner = [min(boundingBoxes(:,1) - 10,...
%                  min(boundingBoxes(:,2))-10];
% width = abs(topLeftCorner(2) - max(boundingBoxes(:,1))+20);
% % height = abs(topLeftCorner(1) - max(boundingBoxes(:,1))+20);
% topRightCorner = max(boundingBoxes(:,3) + topLeftCorner + 20; % 6 + 6
% bottomLeftCorner = max(boundingBoxes(:,1) + max(boundingBoxes(:,4) - 10;
% bottomRightCorner = max(boundingBoxes(:,3) + min(boundingBoxes(:,1) + 6;
hold off

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
imshow(rgb2gray(dogImg));
I_bw_gauss = im2bw(dogImg);
hold on
gauss_props = regionprops(I_bw_gauss,'Area','Centroid',...
     'BoundingBox');
[BB_gauss, BB_gauss_indeces, amount_detected_GAUSS] =...
    select_real_patches_from_BB(gauss_props, 40*40,...
    8000, [0.6 1.4])

for i=1:length(BB_gauss(:,1))
    j = mod(i,7)+1;
    color = colors_select(j);
    rectangles(i,:) = rectangle('Position',...
        BB_gauss(i,:),'EdgeColor', color,'LineWidth',1);
    i
end

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