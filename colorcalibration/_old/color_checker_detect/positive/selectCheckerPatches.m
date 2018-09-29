function  [colorPos, color_pos] = selectCheckerPatches(I)
    %[ bluishgreen ; black ; brown; white ] [x, y];
    
    if ischar(I)
        I = imread(I);
    end
    

    I = imresize(I,[480 640]);
    % FOR MIRRORRING THE IMG
   % I = I(:,[end:-1:1],:);
    
    fig_sel = figure('Name','selection');
    fig_sel.Color = [.5 .5 .5];
    imshow(I)

%     input_sel = {'\color[rgb]{0.4 0.8 0.7}bluish green',...
%         '\color[rgb]{0 0 0}black', '\color[rgb]{.4 .2 0}brown',...
%         '\color[rgb]{1 1 1}white'};
    input_sel = {'\color[rgb]{0.4 0.8 0.7}bluish green',...
        '\color[rgb]{0 0 0}black', '\color[rgb]{.4 .2 0}brown',...
        '\color[rgb]{1 1 1}white'};
    
    x = 0;
    y = 0;
    fig_sel.Visible = 'off';
    fig_sel.Visible = 'on';
    fig_sel.Position(4) = fig_sel.Position(4)+40;
    fig_sel.MenuBar = 'none';

    for i=1:4 %sample colors
        title(['\color[rgb]{1 1 1}select ',...
            cell2mat(input_sel(i)), ' \color[rgb]{1 1 1}corner ',...
            num2str(i)],'FontSize',25);

        a = xlabel(['\color[rgb]{1 1 1}select ',...
            cell2mat(input_sel(i))],'FontSize',25,'FontWeight','bold');

        [x(i),y(i)] = ginput(1);
        pause(0.1);
    end
    hold on

    %% TRANSFORMATION (shear + rotation + scaling )
    found_positions =  [x(1), y(1);
                        x(2), y(2);
                        x(3), y(3);
                        x(4), y(4)];

    %bluish green to black side
    step_blgr_to_brwn = ([x(1), y(1)] - [x(3), y(3)])/5;
    %black to white
    step_bk_to_wh = ([x(2), y(2)] - [x(4), y(4)])/5;

    blgr_to_brw(1,:) = [x(1), y(1)];
    bk_to_wh(1,:) = [x(2), y(2)];
    for i=2:6 %for sides
       %bluish green to brown
       blgr_to_brw(i,:) = blgr_to_brw(i-1,:)- step_blgr_to_brwn;
       %black to white
       bk_to_wh(i,:) = bk_to_wh(i-1,:)- step_bk_to_wh;
    end
    %step size between the large sides
    step_btw_wideSide = (blgr_to_brw - bk_to_wh)/3;
    %% matrix that holds positions for all colors
    colors = {'ob','xw','xm','og'};
    % color_pos(:,:,1) == bluish green to brown ("dark skin") (1st row)
    % color_pos(:,:,2) == orange yellow to orange(2nd row)
    % color_pos(:,:,3) == cyan to blue(3rd row)
    % color_pos(:,:,4) == black 2 to white(3rd row)
    color_pos(:,:,1) = blgr_to_brw;
    for i=2:4 %for sides
       color_pos(:,:,i) = color_pos(:,:,i-1) - step_btw_wideSide;
       scatter(color_pos(:,1,i),color_pos(:,2,i),cell2mat(colors(i)))
    end
    
    colorPos = round(color_pos(end:-1:1,2:-1:1,1));
    % colorPos matches sequence on pdf document
    % colorPos(1:6,:) == brown ("dark skin") to bluish green (1st row)
    % color_pos(7:12,:) == orange to orange yellow(2nd row)
    % color_pos(13:18,:) == blue to cyan(3rd row)
    % color_pos(19:24,:) == white to black (3rd row)
    
    for i=2:4
        colorPos = [                colorPos; 
                    round(color_pos(end:-1:1,2:-1:1,i))];
    end
    
    
    scatter(color_pos(:,1,1),color_pos(:,2,1),cell2mat(colors(1)))
    title('\color[rgb]{1 1 1}Done','FontSize',25);
    xlabel('\color[rgb]{1 1 1}Press any key to continue...',...
        'FontSize',25,'FontWeight','bold');
    pause
    close selection
end