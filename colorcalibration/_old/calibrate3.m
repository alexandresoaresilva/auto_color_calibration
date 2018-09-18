%wrapper for correctcolor, calibratecolor that corrects image and displays
%percent error

%image = imread('manuallyalignedreferencetopcam.png');
% INPUTS



    %% ============ loading pics %color1
    norm = 1;
    %IMG_FOR_CORRECTION_FILENAME = 'imageforcorrectionexampleleftcam';
    IMG_FOR_CORRECTION_FILENAME = 'nonuniform_3';
    %nonuniform_3.png


    checker_to_be_corrected = 0;
    COLOR_CHECKER_IMG_NAME = 'imagefor.png'; % reference checker
    checkerboard_img_cam = double(imread(COLOR_CHECKER_IMG_NAME));

    if checker_to_be_corrected 
        IMG_FOR_CORRECTION_FILENAME = COLOR_CHECKER_IMG_NAME;
    end

    %image = double(image) ./ double(imagegray);
    imageforcorrection = double(imread(strcat(IMG_FOR_CORRECTION_FILENAME,'.png')));
    %imageforcorrection = double(imread(strcat(IMG_FOR_CORRECTION_FILENAME)));

    load('colorcoords.mat');
    load('RGBreference.mat');
    %sample colors from pic
    RGB = zeros(24, 3);

    %% ============ building checkerboard values read from camera
    for i = 1:24 % image(pixel_vertical,pixel_horizontal,[R G B])
    %	RGB(i, :) = image(colorcoords(i, 1), colorcoords(i, 2), :);
        RGB(i, :) = floor(mean([...
            checkerboard_img_cam(colorcoords(i, 1), colorcoords(i, 2), :);... %1st row
            checkerboard_img_cam(colorcoords(i, 1) + 5, colorcoords(i, 2), :); ...
            checkerboard_img_cam(colorcoords(i, 1), colorcoords(i, 2) + 5, :); ...
            checkerboard_img_cam(colorcoords(i, 1) - 5, colorcoords(i, 2), :); ...
            checkerboard_img_cam(colorcoords(i, 1), colorcoords(i, 2) - 5, :)...
            ], 1)...
            );
    end

    %load('RGBtopcam2.mat');

    %% ============ getting calibration matrix
    %norms
    calcos = calibratecolor(RGBREF, RGB);

    %% ============ getting corrected image
    imagecor = correctcolor(calcos, checkerboard_img_cam);
    imagecorrected = correctcolor(calcos, imageforcorrection);
    RGBCOR = correctcolor(calcos, RGB);

    %% ============ calculating error

    errormatrix = abs(RGBREF - RGB);
    figure(1)
    barcolorm = [1 0 0; 0 1 0; 0 0 1];
    b = bar(errormatrix,'FaceColor','flat');
    index = 1;

    for k = 1:size(errormatrix)*size(errormatrix,2)
        if index == 4
            index = 1;
        end

        %b.CData = barcolorm(index, :)
        index = index+1;
    end

    errorig = sum(abs(RGBREF(:) - RGB(:))) / (3 * 24);
    errcor = sum(abs(RGBREF(:) - RGBCOR(:))) / (3 * 24);
    fprintf('Percent error in original: %d\n', errorig);
    fprintf('Percent error in correction: %d\n', errcor);

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

    if norm %if normalized 
        for i = 1:24 % image(pixel_vertical,pixel_horizontal,[R G B])
            P_RGB_norm(i,:) = RGB(i,:)./( sqrt( sum(RGB(i,:).^2) ) ); %taking the norm of the vectors
        end

        for i=1:length(RGBREF)
            Q_RGB_ref_norm(i,:) = RGBREF(i,:)./(sqrt(sum(RGBREF(i,:).^2)));
        end
    end

    %% transpose to follow logic 3x24 (24 column vectors representing colors, 3
    % channels (one per row)
    %P = P_RGB_norm';
    %Q = Q_RGB_ref_norm';

    %P = P_RGB_norm;
    %Q = Q_RGB_ref_norm;


    %[M, M_scaled, transVect1, transformMAtrix2]   = calibratecolor3(P, Q)
    [M, M_scaled, transVect1, transformMAtrix2]   = calibratecolor3(P_RGB_norm, Q_RGB_ref_norm)

    %% ============ getting corrected image 2nd version

    imagecorrected2 = correctcolor3(M, imageforcorrection); 
    imagecorrected3 = correctcolor3(M_scaled, imageforcorrection);

    %% ============ calculating error 2nd version
    errormatrix = abs(RGBREF - RGB);
    figure(1)
    barcolorm = [1 0 0; 0 1 0; 0 0 1];
    b = bar(errormatrix,'FaceColor','flat');
    index = 1;

    Error_calibration_target = sum(abs(Q_RGB_ref_norm(:) - P_RGB_norm(:))) / (3 * 24)

    %% ============ save and display setup
    checkerboard_img_cam = uint8(checkerboard_img_cam);
    height = size(checkerboard_img_cam, 1);
    width = size(checkerboard_img_cam, 2);
    imagecor = uint8(reshape(imagecor(:), height, width, 3));
    height = size(imageforcorrection, 1);
    width = size(imageforcorrection, 2);
    imagecorrected = uint8(reshape(imagecorrected(:), height, width, 3));
    imagecorrected2 = uint8(reshape(imagecorrected2(:), height, width, 3));
    imagecorrected3 = uint8(reshape(imagecorrected3(:), height, width, 3));
    %figure(2)
    %imshow(imagecor);
    %figure(3)
    %imshow(image);

    %IMG_FOR_CORRECTION_FILENAME = strcat(IMG_FOR_CORRECTION_FILENAME, '_R_correct');


    if norm 
        IMG_FOR_CORRECTION_FILENAME2 = strcat(IMG_FOR_CORRECTION_FILENAME, 'newCheck_NORM');
    else
        IMG_FOR_CORRECTION_FILENAME2 = strcat(IMG_FOR_CORRECTION_FILENAME, 'newCheck_NOT_norm');
    end

    %IMG_FOR_CORRECTION_FILENAME3 = strcat(IMG_FOR_CORRECTION_FILENAME, '_X_corr_scaled');

    %creates new folder to save corrected images
    current_folder = pwd;
    new_folder = writeNewFileName('\_run','');%creates new folder name run_1..N
    new_folder = char(strcat(current_folder, new_folder));
    mkdir(new_folder);

    %% R corrected
    % figure(2)
    % fig = get(groot,'CurrentFigure');
    % fig.Name = IMG_FOR_CORRECTION_FILENAME;
    % imshow(imagecorrected);
    % 
    % newFileName = writeNewFileName(IMG_FOR_CORRECTION_FILENAME,'png');
    % %saves run in new folder
    % 
    % imwrite(imagecorrected, char(newFileName));
    %% X corrected with M not scaled
    figure(3)
    fig2 = get(groot,'CurrentFigure');
    fig2.Name = IMG_FOR_CORRECTION_FILENAME2;
    imshow(imagecorrected2);

    newFileName2 = writeNewFileName(IMG_FOR_CORRECTION_FILENAME2,'png');
    newFileName2 = strcat('\',newFileName2);
    newFileName2 = char(strcat(new_folder,newFileName2));

    imwrite(imagecorrected2, char(newFileName2));

    % %% X corrected with M scaled
    % figure(4)
    % fig3 = get(groot,'CurrentFigure');
    % fig3.Name = IMG_FOR_CORRECTION_FILENAME3;
    % imshow(imagecorrected3);
    % newFileName3 = writeNewFileName(IMG_FOR_CORRECTION_FILENAME3,'png');
    % imwrite(imagecorrected3, char(newFileName3));

