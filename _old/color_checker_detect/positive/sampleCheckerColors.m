function samples = sampleCheckerColors(image_filename)
    % color_pos(:,:,1) == bluish green to brown ("dark skin") (1st row)
    % color_pos(:,:,2) == orange yellow to orange(2nd row)
    % color_pos(:,:,3) == cyan to blue(3rd row)
    % color_pos(:,:,4) == black 2 to white(3rd row)
    I = imread(image_filename);
    color_pos = selectCheckerPatches(I);
    color_pos = round(color_pos)
    color_pos(:,1,1)
    %samples = I(color_pos);

   % R_G_B = I(color_pos(i,2,1),color_pos(j,1,1),:)

end

%I = imread('color1.png')


% a =
% 
%    115    82    68
%    194   150   130
%     98   122   157
%     87   108    67
%    133   128   177
%    103   189   170
%    214   126    44
%     80    91   166
%    193    90    99
%     94    60   108
%    157   188    64
%    224   163    46
%     56    61   150
%     70   148    73
%    175    54    60
%    231   199    31
%    187    86   149
%      8   133   161
%    243   243   242
%    200   200   200
%    160   160   160
%    122   122   121
%     85    85    85
%     52    52    52