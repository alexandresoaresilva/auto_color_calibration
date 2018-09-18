function img_row_form  = horizontalize_RGB(image)
    dimensions = size(image);    
    no_of_columns_horiz_dimension = dimensions(1) *  dimensions(2);
    img_row_form = reshape(image, [1 no_of_columns_horiz_dimension]);

    if length(dimensions) > 2
        no_of_columns_horiz_dimension =...
            dimensions(1)*dimensions(2)*dimensions(3);
        img_row_form =...
            reshape(image, [1 no_of_columns_horiz_dimension]);
    end
    %1 row x N pixels (columns)
     %% for grayscale
    %dimensions = [1 no_of_columns_horiz_dimension]; 
    %img_row_form = reshape(image, [dimensions 3]);
    
end