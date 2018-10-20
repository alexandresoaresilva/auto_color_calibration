function img_row_form  = horizontalize(image)
    dimensions = size(image);    
    no_of_columns_horiz_dimension = dimensions(1) *  dimensions(2);
     %1 row x N pixels (columns)
     %% for grayscale
    %dimensions = [1 no_of_columns_horiz_dimension]; 
    %img_row_form = reshape(image, [dimensions 3]);
    %% for colors
    img_row_form = reshape(image, [no_of_columns_horiz_dimension 3]);
end