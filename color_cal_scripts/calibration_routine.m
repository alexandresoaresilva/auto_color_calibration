function I_corrected = calibration_routine(M, I)
    %getting the height and width before horizontalizing the image
    I = double(I);
    height = size(I, 1);
    width = size(I, 2);

    I = reshape(I(:), [], 3);
    I_corrected = I*M;
    
    R = correct_negative_intensities(I_corrected(:,1));
    G = correct_negative_intensities(I_corrected(:,2));
    B = correct_negative_intensities(I_corrected(:,3));

    I_corrected = [R, G, B];
    I_corrected = uint8(reshape(I_corrected(:), height, width, 3));
    
    % only applied to pixels with negative values, not all pixels
    function color_channel = correct_negative_intensities(color_channel)
        zero_i = find(color_channel<0);
        minR = min(color_channel);
        maxR = max(color_channel);
        color_channel(zero_i) =...
            (color_channel(zero_i) - minR)./(maxR - minR).*255;
%         color_channel =...
%             (color_channel - minR)./(maxR - minR).*255;   
    end
end