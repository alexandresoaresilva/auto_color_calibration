clear, clc
close all;
color_folder_path = 'E:\code\GitHub\auto_color_calibration\checker_imgs\colorCalTrouble\fails_to_detect_any_patches\'
color_pic = [color_folder_path, 'dist_checker.png'];
I=imread('gray_13.png');
%I=max(double(I),0);
%I=I/max(I(:));
I = rgb2gray(imread(color_pic));
%hist_ref = histogram(I_hist);
%histeq(I,hist_ref.Values);
%imshow(J)
%J = imresize(I,[ ] );
%I(I<60) = 0;
I_bin = imbinarize(histeq(I),0.5);
%I_bin = imbinarize(histeq(I),0.45);
checker_max_size = [480 640]*.7;
% checker_max_size = checker_max_size*.9;
color_sqr_max_area = checker_max_size(1)/4 * checker_max_size(2)/6;
COLOR_SQR_MIN_AREA = 35*35;

% points = detectSURFFeatures(I);
% figure
% imshow(I)
% hold on
% plot(points.selectStrongest(10))
% title('surf features');
% hold off

regions = detectMSERFeatures(I,'RegionAreaRange',[35*35 10000],'MaxAreaVariation',.01);
figure; imshow(I); hold on;
plot(regions,'showPixelList',true,'showEllipses',false);
title('MSERF 1');
hold off

background = imopen(I,strel('disk',15,8));
% Display the Background Approximation as a Surface
%figure
%surf(double(background(1:8:end,1:8:end))),zlim([0 255]);
% ax = gca;
% ax.YDir = 'reverse';
I2 = (I - background);
I3 = imadjust(I2);

regions2 = detectMSERFeatures(I_bin ,'RegionAreaRange',[35*35 90000],'MaxAreaVariation',0.1);
figure; imshow(I); hold on;
plot(regions2,'showPixelList',true,'showEllipses',false);
title('MSERF 2');
hold off

% figure; imshow(I); hold on;
% plot(regions,'showPixelList',false,'showEllipses',true);
% title('MSERF2');
% hold off

% new_props = regionprops(I_bin,'Area','Centroid','BoundingBox');
figure
imshow(I3)
title('I3')
I_bin2 = imbinarize(I3,0.45);
figure
imshow(I_bin2)
title('I_bin2')
new_props = regionprops(I_bin,'Area','Centroid','BoundingBox');

centroids = cat(1, new_props.Centroid);
j=1;
props_indeces = 0;
boundBox_area=0;
boundingBoxes=[0 0 0 0 ];
 mean_boundBox_area =0 ;
 
 %% gets bound_box area and calc average area
for i=1:length(new_props)
    boundBox_area(i) =...
        new_props(i).BoundingBox(3) * new_props(i).BoundingBox(4); 
    ratio_width_height(i) = ...
        new_props(i).BoundingBox(3)/new_props(i).BoundingBox(4);
end

mean_boundBox_area = mean(boundBox_area);

for i=1:length(new_props)
%     boundBox_area =...
%         new_props(i).BoundingBox(3) * new_props(i).BoundingBox(4);
%     ratio_width_height = ...
%         new_props(i).BoundingBox(3)/new_props(i).BoundingBox(4);
%     if new_props(i).Area > COLOR_SQR_MIN_AREA ...
%        && new_props(i).Area < color_sqr_max_area
    if boundBox_area(i) > COLOR_SQR_MIN_AREA ...
       && boundBox_area(i) < color_sqr_max_area
        if ratio_width_height(i) > 0.8 && ratio_width_height(i) < 1.1
            if (boundBox_area(i) > (mean_boundBox_area+mean_boundBox_area/5))...
               && (boundBox_area(i) < (3.5*mean_boundBox_area))
                    boundingBoxes(j,:) = new_props(i).BoundingBox;
                    props_indeces(j) = i;
                    j = j + 1
            end
        end
    end
end

fig_sel = figure('Name','selection')
imshow(I);
hold on
fig_sel.Color = [.5 .5 .5];
colors_select = ['r','y','w','c','m','r','g'];

for i=1:length(boundingBoxes(:,1))
    j = mod(i,7)+1;
    color = colors_select(j);
    rectangles(i,:) = rectangle('Position',...
        boundingBoxes(i,:),'EdgeColor', color,'LineWidth',1);
    i
end


bluish_green = '\color[rgb]{0.4 0.8 0.7}bluish green';
input_sel = {'\color[rgb]{.4 .2 0}brown','\color[rgb]{0 0 0}black',...
    '\color[rgb]{1 1 1}white', bluish_green}
x = 0;
y = 0;
fig_sel.Visible = 'off';
fig_sel.Visible = 'on';
fig_sel.Position(4) = fig_sel.Position(4)+40;
fig_sel.MenuBar = 'none';

%x(1), y(1) brown
%x(2), y(2) black
%x(3), y(3) white
%x(4), y(4) bluish green
for i=1:4
    title(['\color[rgb]{1 1 1}select ',...
        cell2mat(input_sel(i)), ' \color[rgb]{1 1 1}corner ', num2str(i)],'FontSize',25)
    a = xlabel(['\color[rgb]{1 1 1}select ',...
        cell2mat(input_sel(i))],'FontSize',25,'FontWeight','bold')

    [x(i),y(i)] = ginput(1);
end

[max_x,index_max_x] = max(x);
[max_y,index_max_y] = max(y);

[min_x,index_min_x] = min(x);
[min_y,index_min_y] = min(y);


%vector steps between squares
step_bluish_green_to_brown = round(abs([x(1), y(1)]  - [x(4), y(4)])/5);
step_bluish_green_to_brown = step_bluish_green_to_brown;
step_black_to_white = round(abs([x(2), y(2)]  - [x(3), y(3)])/5);
step_bluish_green_to_black = round(abs([x(4), y(4)]  - [x(2), y(2)])/3);
step_white_from_brown = round(abs([x(1), y(1)]  - [x(3), y(3 )])/3);

sample_pixels = {}; 
% 1,1: bluish green
% 1,6: brown
% 4,1: black
% 4,6: white

if index_max_x == 1 %brown is leftmost on picture (assume mirrored)
    if index_max_y == 3 %white is under brown
        second_row = step_bluish_green_to_black + [x(4) y(4)]; %left side
        third_row = second_row + step_bluish_green_to_black;
        fourth_row = third_row + step_bluish_green_to_black;
        %each row of the cell array is a checker row with 6 squares and x,y
        %value
        sample_pixels  =....% 1st row
            {sample_colors(step_bluish_green_to_brown, 5, [x(4) y(4)]);... 
             sample_colors(step_bluish_green_to_brown, 5, second_row );...
             sample_colors(step_black_to_white, 5, third_row);...
             sample_colors(step_black_to_white, 5, fourth_row)}
        
    else % brown is both leftmost and bottom 
        
    end
end

function new_samples = sample_colors(step, how_many_steps, begining)
    %1st row is x, 2nd y
    new_samples = zeros(length(begining),how_many_steps+1);
    new_samples(:,1) = begining';
    for i=2:(how_many_steps+1)
        new_samples(:,i) = new_samples(:,i-1)+step';
    end
end