% color_calibrate = create_color_calib_window_components;
close all;
clear, clc;

a = calibGui;
transform_3x3_matrix = a.transform_3x3_matrix;

% 
%     dist_from_ref_f = @(ref,samples)sqrt(sum( (ref-samples).^2,2) ); 
%     
%     
%     % returns 24x3 vect with absolute differences between channels
%     abs_dist_per_channel_f = @(ref,samples)abs(ref-samples);
%     within_distance_f = @(dist_from_ref)sum(dist_from_ref)/length(dist_from_ref);
%     RMS_f=@(ref,samples)sqrt(1/length(samples)*sum( (ref-samples).^2,2))