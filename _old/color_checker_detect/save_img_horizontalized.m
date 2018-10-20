function bikes = save_img_horizontalized(img_folder)
    
    img_names = save_file_names_in_folder(img_folder,'png')
        
        %img_names = char.empty
%    while contains(img_cell(i),'.')
%         fileName = char( erase(fileName ,'.') );
%     end
    
    bikes = []
    for i=1:size(img_names,1)
        fileName = img_names(i,:);
        img_dummy = imread(fileName);
        img_dummy_gray = resize_and_grayscale(img_dummy,[240 320]);
        imshow(img_dummy_gray);
        pause;
        close all;
        img_dummy_gray = horizontalize(img_dummy_gray);
        bikes = [bikes;img_dummy_gray];
    end
end 

% rows x columuns (ex: 375 x 500 as [375 500]; 320 x 240 as [240 320]); 
%if dimensions == 'original', then dimensions will be extracted from the
%image and only grayscale will applied
% use an image variable created with imread();
function img_dummy_gray  = resize_and_grayscale(img,dimensions) 
    
    img_dummy_gray = [];
    horiz_or_vert = size(img);
   
    if strcmp(dimensions,'original')
        img_dummy_gray = rgb2gray(img);
    else
        ratio_columns_rows = horiz_or_vert(2)/horiz_or_vert(1);
        
%         if ratio_columns_rows > 1.1 && ratio_columns_rows < 1.4 %if horizontal
%             dimensions = dimensions;
        if ratio_columns_rows < 1% if vertical image
            dimensions = [dimensions(2) dimensions(1)];
        end
        
        img = imresize(img,dimensions);
        img_dummy_gray = rgb2gray(img);
    end
end