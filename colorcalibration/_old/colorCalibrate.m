%wrapper for correctcolor, calibratecolor that corrects image and displays
%percent error

%image = imread('manuallyalignedreferencetopcam.png');
% INPUTS
%   refer_color_checker
%
%
%




function colorCalibrate(refer_color_checker, ...
    bool_calib_checker_itself, img_for_corretion, normalize )
clc

    checker_sqr_width_pixels = 7; 
    sides_for_mean_pix_intensity  = round((checker_sqr_width_pixels-1)/2);
%% ============ loading pics %color1
    norm = normalize;
    
    %eliminates whitespace at the end of the names
    COLOR_CHECKER_IMG_NAME = '';
    checkerboard_img_cam = 0;
     %% checker load   
     
     I = 0;
    
    
    if ischar(refer_color_checker)
        refer_color_checker = deblank(refer_color_checker);
        COLOR_CHECKER_IMG_NAME = refer_color_checker;
        I = imread(COLOR_CHECKER_IMG_NAME);
        checkerboard_img_cam = double(I);
    else %if it is an actual image
        checkerboard_img_cam = refer_color_checker;
    end
    
    fig_sel = gcf;
    if ischar(img_for_corretion)
        img_for_corretion = deblank(img_for_corretion);
    else %if it is an actual img
        img_for_corretion = img_for_corretion;
    end
    
%     COLOR_CHECKER_IMG_NAME = refer_color_checker;
%     checkerboard_img_cam = double(imread(COLOR_CHECKER_IMG_NAME));
%     
%% img load
    % by default, calibrates the color checker image
    
    
   %IMG_FOR_CORRECTION_FILENAME = getname(ref_checker);
   %from https://www.mathworks.com/matlabcentral/answers/263718-what-is-the-best-way-to-get-the-name-of-a-variable-in-a-script
    getname = @(x) inputname(1);
    IMG_FOR_CORRECTION_FILENAME = getname(refer_color_checker);
    
    imageforcorrection = checkerboard_img_cam;
    
    if ~bool_calib_checker_itself
        IMG_FOR_CORRECTION_FILENAME = img_for_corretion;
%         if ~startsWith(img_for_corr_extension,'.') %correcting extension
%             img_for_corr_extension = strcat('.',img_for_corr_extension);
%         end
%         imageforcorrection = double(imread(...
%             strcat(IMG_FOR_CORRECTION_FILENAME,img_for_corr_extension)));
        imageforcorrection = double(imread(IMG_FOR_CORRECTION_FILENAME));
    end

    %load('colorcoords.mat');
    load('macbeth_checker_positions.mat');
    
    load('RGBreference.mat');
    %sample colors from pic
    RGB = zeros(24, 3);

    %% ============ building checkerboard values read from camera
    margin = sides_for_mean_pix_intensity;
    
    %color_pos
    
    for i = 1:24 % image(pixel_vertical,pixel_horizontal,[R G B])
%         RGB(i, :) = floor(mean([...
%             checkerboard_img_cam(colorcoords(i, 1), colorcoords(i, 2), :);... %1st row
%             checkerboard_img_cam(colorcoords(i, 1) + margin, colorcoords(i, 2), :); ...
%             checkerboard_img_cam(colorcoords(i, 1), colorcoords(i, 2) + margin, :); ...
%             checkerboard_img_cam(colorcoords(i, 1) - margin, colorcoords(i, 2), :); ...
%             checkerboard_img_cam(colorcoords(i, 1), colorcoords(i, 2) - margin, :)...
%             ], 1)...
%             );
        RGB(i, :) = floor(mean([...
            checkerboard_img_cam(macbeth_checker_positions(i, 1), macbeth_checker_positions(i, 2), :);... %1st row
            checkerboard_img_cam(macbeth_checker_positions(i, 1) + margin, macbeth_checker_positions(i, 2), :); ...
            checkerboard_img_cam(macbeth_checker_positions(i, 1), macbeth_checker_positions(i, 2) + margin, :); ...
            checkerboard_img_cam(macbeth_checker_positions(i, 1) - margin, macbeth_checker_positions(i, 2), :); ...
            checkerboard_img_cam(macbeth_checker_positions(i, 1), macbeth_checker_positions(i, 2) - margin, :)...
            ], 1)...
            );
    end

    %load('RGBtopcam2.mat');

    %% ============ getting calibration matrix
    %norms
    calcos = calibratecolor(RGBREF, RGB);

    %% ============ getting corrected image

%     errorig = sum(abs(RGBREF(:) - RGB(:))) / (3 * 24);
%     errcor = sum(abs(RGBREF(:) - RGBCOR(:))) / (3 * 24);
%     fprintf('Percent error in original: %d\n', errorig);
%     fprintf('Percent error in correction: %d\n', errcor);

    %% <<<<<<<<<<<<<<<<<<<<<<<< 2nd method >>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % =================================================================
    % =================================================================

    % getting normalized (UNIT VECTORS) column vectors of RGB value
    % (mapping them to the unit sphere)
    % in Bastin et all, RGB == RGB and XYZ == RGB_reg 
    P_RGB_norm = zeros(24,3);
    Q_RGB_ref_norm = zeros(24,3);

    P_RGB_norm = RGB;
    Q_RGB_ref_norm = RGBREF;
    %mean_sqr_error_refer = immse(P_RGB_norm,Q_RGB_ref_norm )
    Err_before_cal = sum(abs(Q_RGB_ref_norm(:) - P_RGB_norm(:))) / (3 * 24)
    MSE_err_before_cal = immse(Q_RGB_ref_norm, P_RGB_norm)
    
    %LS_error_before_cal = lscov(P_RGB_norm,Q_RGB_ref_norm)
    [M_lscov, std_errors, mean_Squared_error] = lscov(P_RGB_norm,Q_RGB_ref_norm)
    
    if norm %if normalized 
        for i = 1:24 % image(pixel_vertical,pixel_horizontal,[R G B])
            %P_RGB_norm(i,:) = RGB(i,:)./( sqrt( sum(RGB(i,:).^2) ) ); %taking the norm of the vectors
            P_RGB_norm(i,:) = RGB(i,:)./sum(RGB(i,:)); %taking the norm of the vectors
        end

        for i=1:length(RGBREF)
            %Q_RGB_ref_norm(i,:) = RGBREF(i,:)./(sqrt(sum(RGBREF(i,:).^2)));
            Q_RGB_ref_norm(i,:) = RGBREF(i,:)./sum(RGBREF(i,:));
        end
    end

    %% transpose to follow logic 3x24 (24 column vectors representing colors, 3
    % channels (one per row)
    %P = P_RGB_norm';
    [M, M_scaled, transVect1, transformMAtrix2]   = calibratecolor3(P_RGB_norm, Q_RGB_ref_norm);
    
    %% ============ getting corrected image 2nd version

    imagecorrected2 = correctcolor3(M, imageforcorrection); 

    %% ============ calculating error 2nd version

%     errormatrix = abs(RGBREF - RGB);
%     figure(1)
%     barcolorm = [1 0 0; 0 1 0; 0 0 1];
%     b = bar(errormatrix,'FaceColor','flat');
%     index = 1;
    
    P_RGB_norm_calibrated = P_RGB_norm*M; %normalized when norm
    
    Error_after_calibration = sum(abs(Q_RGB_ref_norm(:) - P_RGB_norm_calibrated(:))) / (3 * 24)
    MSE_calibration_norm_when_norm = immse(P_RGB_norm_calibrated, P_RGB_norm)
    
    [M_lscov, std_errors, mean_Squared_error] = lscov(P_RGB_norm_calibrated,Q_RGB_ref_norm)
    

    %% ============ save and display setup
    checkerboard_img_cam = uint8(checkerboard_img_cam);
    height = size(checkerboard_img_cam, 1);
    width = size(checkerboard_img_cam, 2);
    
    %imagecor = uint8(reshape(imagecor(:), height, width, 3));
    height = size(checkerboard_img_cam, 1);
    width = size(checkerboard_img_cam, 2);
    %imagecorrected = uint8(reshape(imagecorrected(:), height, width, 3));
    imagecorrected2 = uint8(reshape(imagecorrected2(:), height, width, 3));

    if norm 
        IMG_FOR_CORRECTION_FILENAME2 = strcat(IMG_FOR_CORRECTION_FILENAME, 'newCheck_NORM');
    else
        IMG_FOR_CORRECTION_FILENAME2 = strcat(IMG_FOR_CORRECTION_FILENAME, 'newCheck_NOT_norm');
    end

    %creates new folder to save corrected images
    current_folder = pwd;
    new_folder = writeNewFileName('\_run','');%creates new folder name run_1..N
    new_folder = char(strcat(current_folder, new_folder));    
    mkdir(new_folder);
    %% X corrected with M not scaled
    
    normalized = 'not normalized';
    if normalize
        normalized = 'normalized';
    end
    
    I_diff = imshowpair(I,imagecorrected2);
    I_diff.Visible = 'off';
    %figure('Name','color_calib');
    imshow([I,imagecorrected2,I_diff.CData])
    title('original    ---   calibrated    ---   difference between the two');
        
    xlabel(['color calibration (',normalized,')']);

    newFileName2 = writeNewFileName(IMG_FOR_CORRECTION_FILENAME2,'png');
    newFileName2 = strcat('\',newFileName2);
    newFileName2 = char(strcat(new_folder,newFileName2));

    imwrite(imagecorrected2, char(newFileName2));
    
%     fprintf(fileID,formatSpec,A1,...,An)
% new_text_file = fopen( 'results.txt', 'wt' );        
% 
% 
% 
% for image = 1:N
%   [a1,a2,a3,a4] = ProcessMyImage( image );
%   fprintf( fid, '%f,%f,%f,%f\n', a1, a2, a3, a4);
% end
% fclose(fid);
% 
% 
end