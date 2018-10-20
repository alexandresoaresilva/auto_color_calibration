%centroids = cat(1, new_props.Centroid);

%% CODE FOUND HERE
% https://stackoverflow.com/questions/20057146/is-there-any-difference-of-gaussians-function-in-matlab

[file_names2, file_names2_char] = save_file_names_in_folder(pwd,'jpg');

k = 10;
sigma1 =  0.3;
sigma2 = sigma1*k;
pics_ratio = 1.5;
no_of_files = size(file_names2,1);
%no_of_files = round(no_of_files/pics_ratio)-1;
rows = 2;
columns = ceil(no_of_files/rows);
colors_select = ['r','y','w','c','m','r','g'];
for i=1:no_of_files
    I = imread(cell2mat(file_names2(i,:)));
    
    %resize to 640x480
    I = imresize(I,[480 640]);
    gauss1 = imgaussfilt(I,sigma1);
    gauss2 = imgaussfilt(I,sigma2);


    %dogImg = gauss1 - gauss2;
    dogImg = I - gauss1;
    dogImg = dogImg*10;
    I_gray_gauss = rgb2gray(dogImg);
    [Gmag,Gdir] = imgradient(I_gray_gauss);
    
    subplot(rows,columns,i)
    imshow(dogImg);
    title(file_names2(i,:));
    I_bw_gauss = im2bw(Gmag);
    %I_bw_gauss = im2bw(dogImg);
    
    
    hold on
    gauss_props = regionprops(I_bw_gauss,'Area','Centroid',...
         'BoundingBox');
    [BB_gauss, BB_gauss_indeces, amount_detected_GAUSS] =...
        select_real_patches_from_BB(gauss_props, 25*25,...
        6500, [0.85 1.15])
    
    for i=1:length(BB_gauss(:,1))
        j = mod(i,7)+1;
        color = colors_select(j);
        rectangles(i,:) = rectangle('Position',...
            BB_gauss(i,:),'EdgeColor', color,'LineWidth',1);
        i
    end
    xlabel(['boundingBoxes: ',num2str(i)]);
    hold off
end
%% FUNCTION
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
        ROI_begining = [new_props(i).BoundingBox(1)...
                        new_props(i).BoundingBox(2)];
                    
        ROI_end = [new_props(i).BoundingBox(1)+new_props(i).BoundingBox(3),...
                   new_props(i).BoundingBox(2)+new_props(i).BoundingBox(4)];
        
        boundBox_area =...
            new_props(i).BoundingBox(3) * new_props(i).BoundingBox(4); 
        ratio_width_height = ...
            new_props(i).BoundingBox(3)/new_props(i).BoundingBox(4);
            
        if isBB_withinArea(boundBox_area, sqr_minArea,...
                sqr_maxArea, ratio_width_height,...
                ratio_HW_lower_upper_bounds)
            %next if defines ROI
            if (ROI_begining(1) > 80 ...
                && ROI_begining(2) >  77 )...
%                 && (ROI_end(1) < 
                detected_BB_patches(j,:) = new_props(i).BoundingBox;
                props_indeces(j) = i;
                j = j + 1
            end
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