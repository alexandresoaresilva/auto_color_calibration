function [calib_img, M] = colorCalib(check_from_cam, img_name, norm)
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
    [colorPos, error] = ColorPatchDetect(check_from_cam, img_name);
    
    if colorPos
        M = getTransformMatrix(check_from_cam,colorPos, norm);
        calib_img = calibration_routine(M, check_from_cam); 

        normalized = 'not normalized';
        if norm
            normalized = 'normalized';
        end
        

        figure('Name','color_calib');
        imshow([check_from_cam,calib_img])
        a = gcf;
        a.Units = 'normalized';
        a.Position = [0 0 1 1];
        title('original    ---   calibrated ');
        xlabel({['color calibration (', normalized,')'];...
            'PRESS ENTER TO CONTINUE...'},'FontSize',24);
        pause
        close(a);
        %hold on
    else
        calib_img = 0;
        M = 0;
        xlabel('failed to detect. Please try with a different checker pic');
        disp('Please try with a different checker pic');
    end
end

function M = getTransformMatrix(check_from_cam,colorPos, norm)
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

    check_from_cam = double(check_from_cam);
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

    RGB_from_pic = zeros(24, 3);
    
    for i = 1:length(colorPos) % image(pixel_vertical,pixel_horizontal,[R G B])
        offset=-2:2;
        x = colorPos(i,2)+offset;
        y = colorPos(i,1)+offset;
        
        avgPix(1,:) = mean(mean(check_from_cam(y,x,:)));
        RGB_from_pic(i, :) = avgPix(1,:);
    end
    
    % getting normalized (UNIT VECTORS) column vectors of RGB value
    % (mapping them to the unit sphere)
    % in Bastani and Funti, RGB == RGB and XYZ == RGB_reg 
    P_RGB_norm = zeros(24,3);
    Q_RGB_ref_norm = zeros(24,3);
    
    if norm %if normalized 
        for i=1:length(RGB_ref_values)
            P_RGB_norm(i,:) = normalize_RGB_vec(RGB_from_pic(i,:));
            Q_RGB_ref_norm(i,:) = normalize_RGB_vec(RGB_ref_values(i,:));
        end
    else
        P_RGB_norm = RGB_from_pic;
        Q_RGB_ref_norm = RGB_ref_values;
    end

    % M: matrix that minimizes the least squares calculation (3x3)
    % M: calculated with inverse penrose; 
    % M_scaled: all elements divided by sum(M(2,:)), 
    % in Bastani and Funti (2014)
    % result is 3x3 matrix (equivalent to Px = Q)
    M = P_RGB_norm\Q_RGB_ref_norm;
end

function RGB_norm = normalize_RGB_vec(RGB_vec)
    R = normalize_color_channel(RGB_vec(:,1));
    G = normalize_color_channel(RGB_vec(:,2));
    B = normalize_color_channel(RGB_vec(:,3));
    RGB_norm = [R G B];
    function norm_Color_channel =...
            normalize_color_channel(color_channel)
         norm_Color_channel = color_channel./255;
    end
end