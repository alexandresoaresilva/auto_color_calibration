        classdef fig_with_button
            properties (Access = public)
                fig_obj
                text
                button_obj
                no_of_buttons
                screen_res
            end
            methods (Access = public)
                function fig_obj = fig_with_button
                    %gets screen resolution
                    dummy_screen_res = get(0,'screensize');
                    fig_with_button.screen_res = dummy_screen_res(1,3:4);
                    fig_with_button_Close_it(fig_with_button)
                    fig_name = 'LS Color Calibration';
                    text = {'Select the source (file/ camera) of your '; 'reference Macbeth color checker'};
                    create_fig_with_button_components(fig_with_button,fig_name, text);
                    
                end

                function fig_with_button_Close_it(fig_with_button)
                    if isvalid(fig_with_button.fig_obj)
                        delete( fig_with_button.fig_obj);
                    end
                end
                
                function create_fig_with_button_components(fig_with_button, fig_name, text)
                    % Create color_calibrate
                    fig_with_button.fig_obj = uifigure;
                    %position with relation to the screen
                    fig_with_button.fig_obj.Position(1) = round( (fig_with_button.screen_res(1) - fig_with_button.fig_obj.Position(4)*1.5)/2 );
                    fig_with_button.fig_obj.Position(2) = round( (fig_with_button.screen_res(2) - fig_with_button.fig_obj.Position(3))/2 );
                    %size (width / height form the bottom)
                    fig_with_button.fig_obj.Position(3:4) = [330 130];
                    fig_with_button.fig_obj.Name = fig_name;
                    fig_with_button.fig_obj.Resize = 'off';
                    fig_with_button.fig_obj.CloseRequestFcn = createCallbackFcn(app, @fig_with_button_Close_it, true);
                    
                    
                    % Create make_selection
                    fig_with_button.text = uilabel(fig_with_button.fig_obj);
                    fig_with_button.text.FontSize = 16;
                    fig_with_button.text.FontWeight = 'bold';
                    fig_with_button.text.Position = [18 76 308 36];
                    fig_with_button.text.Text = text;

                    % Create openfileButton
                    fig_with_button.openfileButton = uibutton(fig_with_button.fig_obj, 'push');
                    fig_with_button.openfileButton.ButtonPushedFcn = createCallbackFcn(app, @openfileButtonPushed, true);
                    fig_with_button.openfileButton.Position = [202 26 100 22];
                    fig_with_button.openfileButton.Text = 'open file';
                end                
            end
        end

               
        % Button pushed function: cameraButton
        function cameraButtonPushed(app, event)
            fig_with_button.capture = 1;
            fig_with_button.img_name = 'captured img';
            open_RGB_stream(app);
            delete_1st_dialog_elements(app);
            creat_norm_buttons(app);
        end
    
        function delete_1st_dialog_elements(app)
            delete(fig_with_button.cameraButton);
            delete(fig_with_button.openfileButton);
            delete(fig_with_button.make_selection);            
        end
    
        function creat_norm_buttons(app)
            % Create normalized_or_not_text
            fig_with_button.normalized_or_not_text = uilabel(fig_with_button.fig_obj);
            fig_with_button.normalized_or_not_text.HorizontalAlignment = 'center';
            fig_with_button.normalized_or_not_text.FontSize = 16;
            fig_with_button.normalized_or_not_text.FontWeight = 'bold';
            fig_with_button.normalized_or_not_text.Position = [27 82 285 36];
            fig_with_button.normalized_or_not_text.Text = {'Do you want the color calibration to '; 'normalize the RGB vectors?'};

            % Create normalized_explanat_txt
            fig_with_button.normalized_explanat_txt = uilabel(fig_with_button.fig_obj);
            fig_with_button.normalized_explanat_txt.Position = [55 49 226 28];
            fig_with_button.normalized_explanat_txt.Text = {'normalization divides [R, G, B]./ 255  and '; 'then performs least-squares regression'};

            % Create yesButton
            fig_with_button.yesButton = uibutton(fig_with_button.fig_obj, 'push');
            fig_with_button.yesButton.ButtonPushedFcn = createCallbackFcn(app, @yesButtonPushed, true);
            fig_with_button.yesButton.Position = [27 15 100 22];
            fig_with_button.yesButton.Text = 'yes';

            % Create noButton
            fig_with_button.noButton = uibutton(fig_with_button.fig_obj, 'push');
            fig_with_button.noButton.ButtonPushedFcn = createCallbackFcn(app, @noButtonPushed, true);
            fig_with_button.noButton.Position = [200 15 100 22];
            fig_with_button.noButton.Text = 'no';
            toggle_colorcalib_uifig_visibility(app);
        end
    
        function delete_2nd_dialog_elements(app)
            if isvalid(fig_with_button.normalized_or_not_text)
                delete(fig_with_button.normalized_or_not_text );
                delete(fig_with_button.normalized_explanat_txt);
                delete(fig_with_button.yesButton);            
                delete(fig_with_button.noButton);
            end
        end
    
        % Button pushed function: yesButton
        function yesButtonPushed(app, event)
            fig_with_button.norm_color_calib = 1;
            if fig_with_button.capture 
                create_capture_elements(app);
            else
                color_calibrate_image(app);
                create_calib_itself_components(app)
            end
        end

        % Button pushed function: noButton
        function noButtonPushed(app, event)
            fig_with_button.norm_color_calib = 0;
            if fig_with_button.capture
                create_capture_elements(app);
            else
                color_calibrate_image(app);
                create_calib_itself_components(app)
            end
        end

        function create_capture_elements(app)
            delete_2nd_dialog_elements(app);
            % Create ready_txt
            fig_with_button.ready_txt = uilabel(fig_with_button.fig_obj);
            fig_with_button.ready_txt.HorizontalAlignment = 'center';
            fig_with_button.ready_txt.FontSize = 16;
            fig_with_button.ready_txt.FontWeight = 'bold';
            fig_with_button.ready_txt.FontColor = [1 0 0];
            fig_with_button.ready_txt.Position = [98 86 135 22];
            fig_with_button.ready_txt.Text = 'ready to capture!';

            % Create CAPTUREcheckerimageButton
            fig_with_button.CAPTUREcheckerimageButton = uibutton(fig_with_button.fig_obj, 'push');
            fig_with_button.CAPTUREcheckerimageButton.ButtonPushedFcn = createCallbackFcn(app, @CAPTUREcheckerimageButtonPushed, true);
            fig_with_button.CAPTUREcheckerimageButton.BackgroundColor = [0 0.451 0.7412];
            fig_with_button.CAPTUREcheckerimageButton.FontName = 'Eras Medium ITC';
            fig_with_button.CAPTUREcheckerimageButton.FontSize = 16;
            fig_with_button.CAPTUREcheckerimageButton.FontWeight = 'bold';
            fig_with_button.CAPTUREcheckerimageButton.FontColor = [0 1 1];
            fig_with_button.CAPTUREcheckerimageButton.Position = [78 13 175 63];
            fig_with_button.CAPTUREcheckerimageButton.Text = {'CAPTURE'; 'checker image'};
            toggle_colorcalib_uifig_visibility(app);
        end
    
        function toggle_colorcalib_uifig_visibility(app)
            %toggles visibility so it comes back to the foreground
            fig_with_button.fig_obj.Visible = 'off';
            fig_with_button.fig_obj.Visible = 'on'; 
        end
    
        % Button pushed function: CAPTUREcheckerimageButton
        function CAPTUREcheckerimageButtonPushed(app, event)
            %fig_with_button.capture = 1;
            color_calibrate_image(app);
            create_calib_itself_components(app);
            fig_with_button.capture = 0;
            open_RGB_stream(app);
            %create_calib_itself_components(app);
        end
    
        function color_calibrate_image(app)
            [fig_with_button.calibrated_img, fig_with_button.transform_3x3_matrix] =...
                colorCalib(fig_with_button.fig_obj_img, fig_with_button.img_name, fig_with_button.norm_color_calib);
            size_matrix = size(fig_with_button.transform_3x3_matrix);
            if ~(size_matrix(1) == 3) && ~(size_matrix(2) == 3)
                warndlg({'Could not detect Macbeth checker. Please try again'});
            end
        end
    
        % Button pushed function: openfileButton
        function openfileButtonPushed(app, event)
            fig_with_button.checker_path = '';
            [fig_with_button.img_name, fig_with_button.checker_path] = uigetfile('*.png');
            
            if ~isempty(fig_with_button.checker_path)
                fig_with_button.fig_obj_img = imread([fig_with_button.checker_path, fig_with_button.img_name]);
                delete_1st_dialog_elements(app);
                creat_norm_buttons(app);
            end
        end

        % Button pushed function: batchprocessafolderButton
        function batchprocessafolderButtonPushed(app, event)
            folder_path = uigetdir(pwd);
            old_folder = cd(folder_path );
            [img_names, img2]  = save_file_names_in_folder(folder_path,'png');
            %failed_imgs = "";
            %failure = MException.empty(); %initializing exception array
            %colorPos = zeros(24,3);
            %j = 0;
            mkdir calibrated;
            %old_folder2 = cd('calibrated');
            for img_i=1:size(img_names,1)
                %[colorPos, checker_found, error] = ColorPatchDetectClean(deblank(img2(img_i,:)));
                I_name = deblank(img2(img_i,:));
                new_img = imread(I_name);
                
                calib_img = calibration_routine(fig_with_button.transform_3x3_matrix, new_img);
                imwrite(calib_img,['calibrated\calib_', I_name]);
            end
            cd(old_folder);
        end
        
        function [file_names2, file_names2_char] = save_file_names_in_folder(img_folder,extension)
            %gets file names with the selected extension
            current_folder = pwd; %saving so the program can return to the original  folder
        
            cd(img_folder);
            if extension(1) ~= '*'
                if extension(1) ~= '.'
                    extension = char(strcat('*.',extension));
                else
                    extension = char(strcat('*',extension));
                end
            end
        
            file_names = struct2cell(dir(extension));
            file_names2 = string.empty(0, length(file_names(1,:)) );
        
            for i=1:size(file_names,2)%no. of columns
                %file_name_dummy = cell2mat(file_names(1,i));
                file_name_dummy = file_names{1,i}(1,:);
                file_name_dummy = string(file_name_dummy);
                if i == 1
                    file_names2 = file_name_dummy;
                else
                    file_names2 = [file_names2; file_name_dummy];
                end
            end
            file_names2_char = char(file_names2);
            cd(current_folder);
        end
        % Button pushed function: calibrateafileButton
        function calibrateafileButtonPushed(app, event)
            img_to_be_calibrated_name = '';
            [img_to_be_calibrated_name, file_path] = uigetfile('*.png')
            if ischar(img_to_be_calibrated_name)
                older_folder = cd(file_path);
                
                img_to_be_calibrated = imread(img_to_be_calibrated_name);
                
                mkdir calibrated
                cd calibrated;

                calib_img = calibration_routine(fig_with_button.transform_3x3_matrix, img_to_be_calibrated);
                calib_img_name = ['calib_', img_to_be_calibrated_name];
                imwrite(calib_img,calib_img_name);
                
                calib_file_path = pwd;
                text_diag = calib_file_path;
           
                width_diag = 7*length(text_diag);
                height_diag = 100;
                x_pos = round( (fig_with_button.screen_res(1) - width_diag/2)/2 );
                bottom_pos = round( (fig_with_button.screen_res(2) - height_diag/2)/2 );
                
                d = dialog('Position',...
                    [x_pos bottom_pos width_diag height_diag],...
                    'Name',[img_to_be_calibrated_name, ' saved in folder']);
                txt = uicontrol('Parent',d,'Style',...
                    'text','FontSize',13,'Position',[20 20 width_diag-10 80],...
                'String',text_diag);
                cd(older_folder)
            end
        end

        % Button pushed function: calibratecheckerimgButton
        function calibratecheckerimgButtonPushed(app, event)
           older_folder = cd(fig_with_button.checker_path);
           mkdir calibrated
           cd calibrated;
           
           %calib_folder = [fig_with_button.checker_path, 'calibrated'];
           calib_folder = pwd;
           calib_img = fig_with_button.calibrated_img;
           file_name = ['calib_', fig_with_button.img_name];
           imwrite(fig_with_button.calibrated_img, file_name);
           
           text_diag = calib_folder;
           
           width_diag = 7*length(text_diag);
           height_diag = 100;
           x_pos = round( (fig_with_button.screen_res(1) - width_diag/2)/2 );
           bottom_pos = round( (fig_with_button.screen_res(2) - height_diag/2)/2 );
            
           d = dialog('Position',[x_pos bottom_pos width_diag height_diag],'Name',[file_name, ' saved in folder']);
           txt = uicontrol('Parent',d,'Style','text','FontSize',13,'Position',[20 20 width_diag-10 80],...
               'String',text_diag);
            cd(older_folder)
        end
    
        function savecheckerforlateruseButtonPushed(app,event)
           older_folder = cd(fig_with_button.checker_path);
%            mkdir calibrated
%            cd calibrated;
           
           %calib_folder = [fig_with_button.checker_path, 'calibrated'];
           calib_folder = pwd;
           calib_img = fig_with_button.calibrated_img;
           file_name = ['calib_', fig_with_button.img_name];
           imwrite(fig_with_button.calibrated_img, file_name);
           
           text_diag = calib_folder;
           
           width_diag = 10*length(text_diag);
           height_diag = 100;
           x_pos = round( (fig_with_button.screen_res(1) - width_diag/2)/2 );
           bottom_pos = round( (fig_with_button.screen_res(2) - height_diag/2)/2 );
            
           d = dialog('Position',[x_pos bottom_pos width_diag height_diag],...
               'Name',['checker file ', file_name, ' saved in']);
           txt = uicontrol('Parent',d,'Style','text','FontSize',13,'Position',[20 20 width_diag-10 80],...
               'String',text_diag);
            cd(older_folder)            
        end
    
        % Create UIFigure and components
        function create_calib_itself_components(app)
            delete_2nd_dialog_elements(app);
            % Create UsethesavedcolorcheckertoLabel
            fig_with_button.UsethesavedcolorcheckertoLabel = uilabel(fig_with_button.fig_obj);
            fig_with_button.UsethesavedcolorcheckertoLabel.HorizontalAlignment = 'center';
            fig_with_button.UsethesavedcolorcheckertoLabel.FontSize = 16;
            fig_with_button.UsethesavedcolorcheckertoLabel.FontWeight = 'bold';
            fig_with_button.UsethesavedcolorcheckertoLabel.Position = [45 90 248 22];
            fig_with_button.UsethesavedcolorcheckertoLabel.Text = 'Use the saved color checker to ';

            % Create batchprocessafolderButton
            fig_with_button.batchprocessafolderButton = uibutton(fig_with_button.fig_obj, 'push');
            fig_with_button.batchprocessafolderButton.ButtonPushedFcn = createCallbackFcn(app, @batchprocessafolderButtonPushed, true);
            fig_with_button.batchprocessafolderButton.Position = [16 46 134 22];
            fig_with_button.batchprocessafolderButton.Text = 'batch process a folder';

            % Create calibrateafileButton
            fig_with_button.calibrateafileButton = uibutton(fig_with_button.fig_obj, 'push');
            fig_with_button.calibrateafileButton.ButtonPushedFcn = createCallbackFcn(app, @calibrateafileButtonPushed, true);
            fig_with_button.calibrateafileButton.Position = [170 46 100 22];
            fig_with_button.calibrateafileButton.Text = 'calibrate a file';

            % Create calibratecheckerimgButton
            fig_with_button.calibratecheckerimgButton = uibutton(fig_with_button.fig_obj, 'push');
            fig_with_button.calibratecheckerimgButton.ButtonPushedFcn = createCallbackFcn(app, @calibratecheckerimgButtonPushed, true);
            fig_with_button.calibratecheckerimgButton.Position = [18 15 129 22];
            fig_with_button.calibratecheckerimgButton.Text = 'calibrate checker img';

            % Create savecheckerforlateruseButton
            fig_with_button.savecheckerforlateruseButton = uibutton(fig_with_button.fig_obj, 'push');
            fig_with_button.savecheckerforlateruseButton.FontWeight = 'bold';
            fig_with_button.savecheckerforlateruseButton.FontColor = [1 0 0];
            fig_with_button.savecheckerforlateruseButton.ButtonPushedFcn = createCallbackFcn(app, @savecheckerforlateruseButtonPushed, true);
            fig_with_button.savecheckerforlateruseButton.Position = [155 15 163 22];
            fig_with_button.savecheckerforlateruseButton.Text = 'save checker for later use'; 
            toggle_colorcalib_uifig_visibility(app);
        end
    
        function delete_calib_itself_components(app)
            delete(fig_with_button.UsethesavedcolorcheckertoLabel);
            delete(fig_with_button.batchprocessafolderButton);
            delete(fig_with_button.colorcalibrateafileButton);            
            delete(fig_with_button.calibratethecheckeritselftButton);            
        end