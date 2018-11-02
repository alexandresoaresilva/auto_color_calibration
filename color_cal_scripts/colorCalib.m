% this is the main function; wraps the other ones
function [calib_img, M, RGB_ref_values, err_pkg, err_calib_pkg]...
    = colorCalib(I_check_from_cam, I_name, norm) %this is the function definition

% INPUTS
%     check_from_cam : Macbeth 6x4 color checker captured in a environment 
%                     of interest
%     img_name : character vector with the image's filename 
%                 (so it can be compared with other images )
%     norm : 1 for normalized 3x3 color calibration matrix, 0 for not
%     normalized
% OUTPUTS
%     calib_img : calibrated checkerboard
%     M : color calbiration 3x3 matrix. If fed to the function 
%               calibration_routine with a new image from the same set as
%               the color checker image, it calibrates it
%     err_pkg: cell array with 4 different error measurements 
%     err_calib_pkg: cell array with 4 different error measurements for
%     calibrated images
    [colorPos, error] = ColorPatchDetect(I_check_from_cam, I_name);
    
    if colorPos
        %original samples, unmodified image
        RGB_samples = sample_colors_from_checker(I_check_from_cam, colorPos);
        
        %reference samples from manufacturer
        [M, RGB_ref_values] = getTransformMatrix(RGB_samples, norm);
        
        %Error for difference between unmodified image
        % and reference values form manufacturer
        [RMS, abs_dist_per_channel, dist_from_ref, within_distance] =...
            calculate_error(RGB_ref_values, RGB_samples);
        err_pkg =...
            {RMS,abs_dist_per_channel, dist_from_ref, within_distance};
    
        calib_img = calibration_routine(M, I_check_from_cam);
        
        %Error for difference between unmodified image
        % and reference values form manufacturer
        RGB_sampCalibrated =...
            sample_colors_from_checker(calib_img, colorPos);
        
        [RMS_calib, abs_dist_per_channel_calib, dist_from_ref_calib,...
            within_distance_calib] =...
            calculate_error(RGB_ref_values, RGB_sampCalibrated);
        
        err_calib_pkg =...
            {RMS_calib,abs_dist_per_channel_calib, dist_from_ref_calib,...
            within_distance_calib};
    else
        calib_img = 0;
        RGB_ref_values = 0;
        err_pkg = 0;
        err_calib_pkg = 0;
        M = 0;
        xlabel('failed to detect. Please try with a different checker pic');
        disp('Please try with a different checker pic');
    end
end

function [M, RGB_ref_values] = getTransformMatrix(RGB_samples, norm)
% INPUTS
%     check_from_cam : Macbeth 6x4 color checker captured in a environment 
%                     of interest
%     colorPos : character vector with the image's filename 
%                 (so it can be compared with other images )
%     norm : 1 for normalized 3x3 color calibration matrix, 0 for not
%     normalized
% OUTPUTS
%     calib_img : calibrated checkerboard
%     M : color calbiration 3x3 matrix. If fed to the function 
%               calibration_routine with a new image from the same set as
%               the color checker image, it calibrates it

        % M: matrix that minimizes the least squares regression (3x3)
            % calculated with inverse penrose; 
    
            % in Bastani and Funti (2014)
            % result is 3x3 matrix (equivalent to Px = Q)

    %check_from_cam = double(check_from_cam);
    RGB_samples = double(RGB_samples);
%    each begining of a 6-patch line on the checker is represented 
    % in the comments of RGB_ref as  ----------- 
    %RGB_ref RGBREF    
    RGB_ref_values  =  [115     82     68; %(1,:)dark skin (brown) ----------- 
                        194    150    130; %    light skin
                         98    122    157; %    blue sky
                         87    108     67; %    foliage
                        133    128    177; %    blue flower
                        103    189    170; %(6,:)bluish green
                        214    126     44; %(7,:)organge -----------
                         80     91    166;
                        193     90     99;
                         94     60    108;
                        157    188     64; 
                        224    163     46; %(12,:)orange yellow
                         56     61    150; %(13,:)blue -----------
                         70    148     73;
                        175     54     60;
                        231    199     31;
                        187     86    149; 
                          8    133    161; %(18,:)cyan
                        243    243    242; %(19,:)white-----------
                        200    200    200;
                        160    160    160;
                        122    122    121;
                         85     85     85; 
                         52     52     52];%(24,:)black

    % getting normalized (UNIT VECTORS) column vectors of RGB value
    % (mapping them to the unit sphere)
    % in Bastani and Funti, RGB == RGB and XYZ == RGB_reg 
    P_RGB_norm = zeros(24,3);
    Q_RGB_ref_norm = zeros(24,3);
    
    if norm %if normalized 
        for i=1:length(RGB_ref_values)
            P_RGB_norm(i,:) = normalize_RGB_vec(RGB_samples(i,:));
            Q_RGB_ref_norm(i,:) = normalize_RGB_vec(RGB_ref_values(i,:));
        end
    else % NOT norm, same var used
        P_RGB_norm = RGB_samples; 
        Q_RGB_ref_norm = RGB_ref_values;
    end
    
    %plot_errors(error_cell_pkg, RGB_ref_values)
    % M: matrix that minimizes the least squares calculation (3x3)
    % M: calculated with inverse penrose; 
    % M_scaled: all elements divided by sum(M(2,:)), 
    % in Bastani and Funti (2014)
    % result is 3x3 matrix (equivalent to Px = Q)
    M = P_RGB_norm\Q_RGB_ref_norm;

    function RGB_norm = normalize_RGB_vec(RGB_vec)
        R = RGB_vec(:,1)/sum(RGB_vec);
        G = RGB_vec(:,2)/sum(RGB_vec);
        B = RGB_vec(:,3)/sum(RGB_vec);
        RGB_norm = [R G B];
    end
end

function RGB_samples =...
    sample_colors_from_checker(I_check_from_cam, indeces)
	RGB_samples = zeros(24, 3);

	offset=-2:2;
	for i = 1:length(indeces) % image(pixel_vertical,pixel_horizontal,[R G B])
	    x = indeces(i,2)+offset;
	    y = indeces(i,1)+offset;
	    avgPix(1,:) = mean(mean(I_check_from_cam(y,x,:)));
	    RGB_samples(i, :) = avgPix(1,:);
	end
end

function [RMS, abs_dist_per_channel, dist_from_ref, within_distance] =...
    calculate_error(RGB_ref_values, RGB_samples)

    % formulas from:
    % http://citeseerx.ist.psu.edu/viewdoc/download;jsessionid=6314D4936859CB6845D9531389ABBD67?doi=10.1.1.412.9461&rep=rep1&type=pdf
    % returns a 24x1 vector, with L-2 norm of the distance vector
    dist_from_ref_f = @(ref,samples)sqrt(sum( (ref-samples).^2,2) ); 
    % returns 24x3 vect with absolute differences between channels
    abs_dist_per_channel_f = @(ref,samples)abs(ref-samples);
    within_distance_f = @(dist_from_ref)sum(dist_from_ref)/length(dist_from_ref);
    RMS_f=@(ref,samples)sqrt(mean( (ref-samples).^2,2));
    
    dist_from_ref = dist_from_ref_f(RGB_ref_values,RGB_samples);
    abs_dist_per_channel = abs_dist_per_channel_f(RGB_ref_values,RGB_samples);
    within_distance = within_distance_f(dist_from_ref);
    RMS = RMS_f(RGB_ref_values,RGB_samples);
end

function plot_errors(error_cell_pkg, RGB_ref_values)

   %=====================================================================
    RGB_triplets_plot = RGB_ref_values./255;
    color_labels ={'Dark skin'; 'Light skin'; 'Blue sky'; 'Foliage';...
       'Blue flower'; 'Bluish green'; 'Orange'; 'Purplish blue';...
       'Moderate red'; 'Purple'; 'Yellow green'; 'Orange yellow';...
       'Blue'; 'Green'; 'Red'; 'Yellow'; 'Magenta'; 'Cyan'; 'White';...
       'Neutral'; 'Neutral'; 'Neutral'; 'Neutral'; 'Black'};
    figure('Name','Errors');
    subplot(221); % absolute difference, separated by channel
    %=====================================================================
    scatter3(error_cell_pkg{2}(1,1),error_cell_pkg{2}(1,2),...
        error_cell_pkg{2}(1,3),100,RGB_triplets_plot(1,:),'filled')
    hold on;
    for i=2:length(error_cell_pkg{2})
        scatter3(error_cell_pkg{2}(i,1),error_cell_pkg{2}(i,2),...
            error_cell_pkg{2}(i,3),100,RGB_triplets_plot(i,:),'filled');
    end
    title('abs difference: $\mid\big(R_{ref},G_{ref},B_{ref}\big) - \big(R_{samples},G_{samples},B_{samples}\big)\mid$','Interpreter','latex')
    xlabel('R');
    ylabel('G');
    zlabel('B');
    legend(color_labels);
    hold off
    subplot(222);  % RMS difference, avg. over RGB
    %=====================================================================
    x_points = 1:length(error_cell_pkg{1});
    scatter(1,error_cell_pkg{1}(1,1),100, RGB_triplets_plot(1,:),'filled');
    hold on;
    for i=x_points(2:end)
        scatter(x_points(i), error_cell_pkg{1}(i,1), 100,...
            RGB_triplets_plot(i,:),'filled');
    end
    title('RMS errors: $\sqrt{\frac{1}{3}\sum_{k=1}^3(ref_{k}-samples_{k})^{2}}$','Interpreter','latex')
    ylabel('RGB');
    %legend(color_labels);
    hold off

    subplot(223);  % RMS difference, avg. over RGB
    %dist_from_ref_f = @(ref,samples)sqrt(sum( (ref-samples).^2,2) ); 
    %=====================================================================
    scatter(1,error_cell_pkg{3}(1,1),100, RGB_triplets_plot(1,:),'filled');
    hold on;
    for i=x_points(2:end)
        scatter(x_points(i), error_cell_pkg{3}(i,1), 100,...
            RGB_triplets_plot(i,:),'filled');
    end
    title('distance from ref: $\Delta{RGB = }\sqrt{\sum_{k=1}^3(ref_{k}-samples_{k})^{2}}$','Interpreter','latex')
    ylabel('RGB');    
    hold off
end