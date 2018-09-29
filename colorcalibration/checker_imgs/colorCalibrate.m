%wrapper for correctcolor, calibratecolor that corrects image and displays
%percent error

%image = imread('manuallyalignedreferencetopcam.png');
% INPUTS
%   refer_color_checker
%
%
%

function calibratedImg = colorCalibrate(colorPos, refer_color_checker, ...
    bool_calib_checker_itself, img_for_corretion, normalize )
clc

%each begining of a 6-patch line on the checker is represented 
% in the comments of RGB_ref as  ----------- 
RGB_ref =  [115     82     68; %(1,:)dark skin (brown) ----------- 
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
            243    243    242; %%(19,:)white-----------
            200    200    200;
            160    160    160;
            122    122    121;
             85     85     85; 
             52     52     52];%(24,:)black


%% ============ loading pics %color1
    norm = normalize;
    
    %eliminates whitespace at the end of the names
    COLOR_CHECKER_IMG_NAME = '';
    check_from_cam = 0;
     %% checker load   
     
     I = 0;
    
    if ischar(refer_color_checker)
        refer_color_checker = deblank(refer_color_checker);
        COLOR_CHECKER_IMG_NAME = refer_color_checker;
        I = imread(COLOR_CHECKER_IMG_NAME);
        check_from_cam = double(I);
    else %if it is an actual image
        check_from_cam = double(refer_color_checker);
        I = check_from_cam;
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
    
        
    I_to_correct = check_from_cam;
    
    if ~bool_calib_checker_itself
        IMG_FOR_CORRECTION_FILENAME = img_for_corretion;
%         if ~startsWith(img_for_corr_extension,'.') %correcting extension
%             img_for_corr_extension = strcat('.',img_for_corr_extension);
%         end
%         imageforcorrection = double(imread(...
%             strcat(IMG_FOR_CORRECTION_FILENAME,img_for_corr_extension)));
        I_to_correct = double(imread(IMG_FOR_CORRECTION_FILENAME));
    end

    %load('colorcoords.mat');
    %load('macbeth_checker_positions.mat');
    
    load('RGBreference.mat');
    %sample colors from pic
    RGB = zeros(24, 3);

    %% ============ building checkerboard values read from camera
    %margin = sides_for_mean_pix_intensity;
    
    %color_pos
    % colorPos matches sequence on pdf document
    % colorPos(1:6,:) == brown ("dark skin") to bluish green (1st row)
    % color_pos(7:12,:) == orange to orange yellow(2nd row)
    % color_pos(13:18,:) == blue to cyan(3rd row)
    % color_pos(19:24,:) == white to black (3rd row)
        
    for i = 1:24 % image(pixel_vertical,pixel_horizontal,[R G B])
        offset=-2:2;
        y = corners(i,2)+offset;
        x = corners(i,1)+offset;
        
       %rectangle for average of colors
%        rect = rectangle('Position',[colorPos(i,2) colorPos(i,1) 10 10],...
%            'Curvature',[1 1],'LineWidth',5);
%        avgPix(1,:) = mean(mean(check_from_cam(...
%            rect.Position(2):rect.Position(2)+5, ...
%            rect.Position(1):rect.Position(1)+5,:)))
        avgPix(1,:) = mean(mean(check_from_cam(y,x,:)))
        RGB(i, :) = avgPix(1,:);
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
            %P_RGB_norm(i,:) = RGB(i,:); %taking the norm of the vectors
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

    imagecorrected2 = correctcolor3(M, I_to_correct); 

    %% ============ calculating error 2nd version

%     errormatrix = abs(RGBREF - RGB);
%     figure(1)
%     barcolorm = [1 0 0; 0 1 0; 0 0 1];
%     b = bar(errormatrix,'FaceColor','flat');
%     index = 1;
    
    P_RGB_norm_calibrated = P_RGB_norm*M; %normalized when norm
    
    Error_after_calibration = sum(abs(Q_RGB_ref_norm(:) - P_RGB_norm_calibrated(:))) / (3 * 24);
    MSE_calibration_norm_when_norm = immse(P_RGB_norm_calibrated, P_RGB_norm);
    
    [M_lscov, std_errors, mean_Squared_error] = lscov(P_RGB_norm_calibrated,Q_RGB_ref_norm);
    

    %% ============ save and display setup
    check_from_cam = uint8(check_from_cam);
    height = size(check_from_cam, 1);
    width = size(check_from_cam, 2);
    
    %imagecor = uint8(reshape(imagecor(:), height, width, 3));
    height = size(check_from_cam, 1);
    width = size(check_from_cam, 2);
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
    hold off
    
    I_diff = imshowpair(I,imagecorrected2);
    I_diff.Visible = 'off';
    %figure('Name','color_calib');
    imshow([I,imagecorrected2,I_diff.CData])
    a = gcf;
    title('original    ---   calibrated    ---   difference between the two');
        
    xlabel(['color calibration (',normalized,')']);

    newFileName2 = writeNewFileName(IMG_FOR_CORRECTION_FILENAME2,'png');
    newFileName2 = strcat('\',newFileName2);
    newFileName2 = char(strcat(new_folder,newFileName2));
    pause
    
    close(a);
    hold on
    
    imwrite(imagecorrected2, char(newFileName2));
    calibratedImg = imagecorrected2;
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

function calcos = calibratecolor(RGBREF, RGB) 
    %RGB are arrays of integers 0-255 24 elements long, calcos is 10x3 matrix 
    vals = [ones(24, 1), RGB, RGB.^2];
    calcosR = regress(RGBREF(:, 1), vals);
    calcosG = regress(RGBREF(:, 2), vals);
    calcosB = regress(RGBREF(:, 3), vals);
    calcos = [calcosR, calcosG, calcosB];
end

% M 
function [M, M_scaled, transformMAtrix1, transformMAtrix2]  = calibratecolor3(P,Q)
    % M: matrix that minimizes the least squares calculation (3x3)
    % M: calculated with inverse penrose; 
    % M_scaled: all elements divided by sum(M(2,:)), 
    % as suggested in Bastani et all
    % result is 3x3 matrix (equivalent to Px = Q)
    %transformation_Matrix_0 is a 3x1 vect, M calculated from invers
    %transformation_Matrix_2 is a 3x1 vect, with M scaled 
   %
    %M =  Q*P'*(inv(P*P'));
    
    M = P\Q;
    
    E_M = zeros(size(P*M));
     
    for i=1:length(P) % E_m IS 3X1 column vector
        E_M = E_M + ( (abs(P(i,:)*M-Q(i,:))).^2 );
    end

    
    E_M = E_M./sum(E_M(2));
    
    transformMAtrix1 = E_M; %first result
    
    %% 2nd calculation
    %E_M = zeros(size(M*P(:,1)));
    E_M = zeros(size(P*M));
    
    M_scaled = M./(sum(M(2,:)));

    for i=1:length(P) % E_m IS 3X1 column vector
        E_M = E_M + ( (abs(P(i,:)*M-Q(i,:))).^2 );
    end
    
    transformMAtrix2 = E_M; % now scaled
end

function RGBCOR = correctcolor3(transfMatrix, image) 
    %RGB are arrays of integers 0-255 X elements long, calcos is a 10x3 matrix 
    image = reshape(image(:), [], 3);
    %n = size(RGB, 1);
    RGBCOR = image*transfMatrix;
    R = RGBCOR(:,1);
    G = RGBCOR(:,2);
    B = RGBCOR(:,3);
    
      
     minR = min(R);
     maxR = max(R);
     R = (R - minR) ./ (maxR - minR) .* 255;
     
     minG = min(G);
     maxG = max(G);
     G = (G - minG) ./ (maxG - minG) .* 255;
     
     minB = min(B);
     maxB = max(B);
     B = (B - minB) ./ (maxB - minB) .* 255;

      RGBCOR = [R, G, B];
end