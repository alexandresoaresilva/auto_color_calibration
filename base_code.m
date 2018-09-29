        function colorCalibrateButtonPushed(app,event)
            color_calibrateFig_Close_it(app,1)
            create_color_calib_window_components(app);
        end
        function color_calibrateFig_Close_it(app,event)
            if isvalid(app.color_calibrate)
                delete( app.color_calibrate );
            end
        end
        
        function create_color_calib_window_components(app)
            % Create color_calibrate
            app.color_calibrate = uifigure;
            app.color_calibrate.Position = [100 100 330 130];
            app.color_calibrate.Name = 'LS Color Calibration';
            app.color_calibrate.Resize = 'off';
            app.color_calibrate.Position(1) = round( (app.screen_res(1) - app.color_calibrate.Position(4)*1.5)/2 );
            app.color_calibrate.Position(2) = round( (app.screen_res(2) - app.color_calibrate.Position(3))/2 );
            
            app.color_calibrate.CloseRequestFcn = createCallbackFcn(app, @color_calibrateFig_Close_it, true);

            % Create make_selection
            app.make_selection = uilabel(app.color_calibrate);
            app.make_selection.FontSize = 16;
            app.make_selection.FontWeight = 'bold';
            app.make_selection.Position = [18 76 308 36];
            app.make_selection.Text = {'Select the source (file/ camera) of your '; 'reference Macbeth color checker'};

            % Create cameraButton
            app.cameraButton = uibutton(app.color_calibrate, 'push');
            app.cameraButton.ButtonPushedFcn = createCallbackFcn(app, @cameraButtonPushed, true);
            app.cameraButton.Position = [18 26 100 22];
            app.cameraButton.Text = 'camera';

            % Create openfileButton
            app.openfileButton = uibutton(app.color_calibrate, 'push');
            app.openfileButton.ButtonPushedFcn = createCallbackFcn(app, @openfileButtonPushed, true);
            app.openfileButton.Position = [202 26 100 22];
            app.openfileButton.Text = 'open file';
        end
        
        % Button pushed function: cameraButton
        function cameraButtonPushed(app, event)
            app.capture = 1;
            app.img_name = 'captured img';
            open_RGB_stream(app);
            delete_1st_dialog_elements(app);
            creat_norm_buttons(app);
        end
    
        function delete_1st_dialog_elements(app)
            delete(app.cameraButton);
            delete(app.openfileButton);
            delete(app.make_selection);            
        end
    
        function creat_norm_buttons(app)
            % Create normalized_or_not_text
            app.normalized_or_not_text = uilabel(app.color_calibrate);
            app.normalized_or_not_text.HorizontalAlignment = 'center';
            app.normalized_or_not_text.FontSize = 16;
            app.normalized_or_not_text.FontWeight = 'bold';
            app.normalized_or_not_text.Position = [27 82 285 36];
            app.normalized_or_not_text.Text = {'Do you want the color calibration to '; 'normalize the RGB vectors?'};

            % Create normalized_explanat_txt
            app.normalized_explanat_txt = uilabel(app.color_calibrate);
            app.normalized_explanat_txt.Position = [55 49 226 28];
            app.normalized_explanat_txt.Text = {'normalization divides [R, G, B]./ 255  and '; 'then performs least-squares regression'};

            % Create yesButton
            app.yesButton = uibutton(app.color_calibrate, 'push');
            app.yesButton.ButtonPushedFcn = createCallbackFcn(app, @yesButtonPushed, true);
            app.yesButton.Position = [27 15 100 22];
            app.yesButton.Text = 'yes';

            % Create noButton
            app.noButton = uibutton(app.color_calibrate, 'push');
            app.noButton.ButtonPushedFcn = createCallbackFcn(app, @noButtonPushed, true);
            app.noButton.Position = [200 15 100 22];
            app.noButton.Text = 'no';
            toggle_colorcalib_uifig_visibility(app);
        end
    
        function delete_2nd_dialog_elements(app)
            if isvalid(app.normalized_or_not_text)
                delete(app.normalized_or_not_text );
                delete(app.normalized_explanat_txt);
                delete(app.yesButton);            
                delete(app.noButton);
            end
        end
    
        % Button pushed function: yesButton
        function yesButtonPushed(app, event)
            app.norm_color_calib = 1;
            if app.capture 
                create_capture_elements(app);
            else
                color_calibrate_image(app);
                create_calib_itself_components(app)
            end
        end

        % Button pushed function: noButton
        function noButtonPushed(app, event)
            app.norm_color_calib = 0;
            if app.capture
                create_capture_elements(app);
            else
                color_calibrate_image(app);
                create_calib_itself_components(app)
            end
        end

        function create_capture_elements(app)
            delete_2nd_dialog_elements(app);
            % Create ready_txt
            app.ready_txt = uilabel(app.color_calibrate);
            app.ready_txt.HorizontalAlignment = 'center';
            app.ready_txt.FontSize = 16;
            app.ready_txt.FontWeight = 'bold';
            app.ready_txt.FontColor = [1 0 0];
            app.ready_txt.Position = [98 86 135 22];
            app.ready_txt.Text = 'ready to capture!';

            % Create CAPTUREcheckerimageButton
            app.CAPTUREcheckerimageButton = uibutton(app.color_calibrate, 'push');
            app.CAPTUREcheckerimageButton.ButtonPushedFcn = createCallbackFcn(app, @CAPTUREcheckerimageButtonPushed, true);
            app.CAPTUREcheckerimageButton.BackgroundColor = [0 0.451 0.7412];
            app.CAPTUREcheckerimageButton.FontName = 'Eras Medium ITC';
            app.CAPTUREcheckerimageButton.FontSize = 16;
            app.CAPTUREcheckerimageButton.FontWeight = 'bold';
            app.CAPTUREcheckerimageButton.FontColor = [0 1 1];
            app.CAPTUREcheckerimageButton.Position = [78 13 175 63];
            app.CAPTUREcheckerimageButton.Text = {'CAPTURE'; 'checker image'};
            toggle_colorcalib_uifig_visibility(app);
        end
    
        function toggle_colorcalib_uifig_visibility(app)
            %toggles visibility so it comes back to the foreground
            app.color_calibrate.Visible = 'off';
            app.color_calibrate.Visible = 'on'; 
        end
    
        % Button pushed function: CAPTUREcheckerimageButton
        function CAPTUREcheckerimageButtonPushed(app, event)
            %app.capture = 1;
            color_calibrate_image(app);
            create_calib_itself_components(app);
            app.capture = 0;
            open_RGB_stream(app);
            %create_calib_itself_components(app);
        end
    
        function color_calibrate_image(app)
            [app.calibrated_img, app.transform_3x3_matrix] =...
                colorCalib(app.color_calibrate_img, app.img_name, app.norm_color_calib);
            size_matrix = size(app.transform_3x3_matrix);
            if ~(size_matrix(1) == 3) && ~(size_matrix(2) == 3)
                warndlg({'Could not detect Macbeth checker. Please try again'});
            end
        end
    
        % Button pushed function: openfileButton
        function openfileButtonPushed(app, event)
            app.checker_path = '';
            [app.img_name, app.checker_path] = uigetfile('*.png');
            
            if ~isempty(app.checker_path)
                app.color_calibrate_img = imread([app.checker_path, app.img_name]);
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
                
                calib_img = calibration_routine(app.transform_3x3_matrix, new_img);
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

                calib_img = calibration_routine(app.transform_3x3_matrix, img_to_be_calibrated);
                calib_img_name = ['calib_', img_to_be_calibrated_name];
                imwrite(calib_img,calib_img_name);
                
                calib_file_path = pwd;
                text_diag = calib_file_path;
           
                width_diag = 7*length(text_diag);
                height_diag = 100;
                x_pos = round( (app.screen_res(1) - width_diag/2)/2 );
                bottom_pos = round( (app.screen_res(2) - height_diag/2)/2 );
                
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
           older_folder = cd(app.checker_path);
           mkdir calibrated
           cd calibrated;
           
           %calib_folder = [app.checker_path, 'calibrated'];
           calib_folder = pwd;
           calib_img = app.calibrated_img;
           file_name = ['calib_', app.img_name];
           imwrite(app.calibrated_img, file_name);
           
           text_diag = calib_folder;
           
           width_diag = 7*length(text_diag);
           height_diag = 100;
           x_pos = round( (app.screen_res(1) - width_diag/2)/2 );
           bottom_pos = round( (app.screen_res(2) - height_diag/2)/2 );
            
           d = dialog('Position',[x_pos bottom_pos width_diag height_diag],'Name',[file_name, ' saved in folder']);
           txt = uicontrol('Parent',d,'Style','text','FontSize',13,'Position',[20 20 width_diag-10 80],...
               'String',text_diag);
            cd(older_folder)
        end
    
        function savecheckerforlateruseButtonPushed(app,event)
           older_folder = cd(app.checker_path);
%            mkdir calibrated
%            cd calibrated;
           
           %calib_folder = [app.checker_path, 'calibrated'];
           calib_folder = pwd;
           calib_img = app.calibrated_img;
           file_name = ['calib_', app.img_name];
           imwrite(app.calibrated_img, file_name);
           
           text_diag = calib_folder;
           
           width_diag = 10*length(text_diag);
           height_diag = 100;
           x_pos = round( (app.screen_res(1) - width_diag/2)/2 );
           bottom_pos = round( (app.screen_res(2) - height_diag/2)/2 );
            
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
            app.UsethesavedcolorcheckertoLabel = uilabel(app.color_calibrate);
            app.UsethesavedcolorcheckertoLabel.HorizontalAlignment = 'center';
            app.UsethesavedcolorcheckertoLabel.FontSize = 16;
            app.UsethesavedcolorcheckertoLabel.FontWeight = 'bold';
            app.UsethesavedcolorcheckertoLabel.Position = [45 90 248 22];
            app.UsethesavedcolorcheckertoLabel.Text = 'Use the saved color checker to ';

            % Create batchprocessafolderButton
            app.batchprocessafolderButton = uibutton(app.color_calibrate, 'push');
            app.batchprocessafolderButton.ButtonPushedFcn = createCallbackFcn(app, @batchprocessafolderButtonPushed, true);
            app.batchprocessafolderButton.Position = [16 46 134 22];
            app.batchprocessafolderButton.Text = 'batch process a folder';

            % Create calibrateafileButton
            app.calibrateafileButton = uibutton(app.color_calibrate, 'push');
            app.calibrateafileButton.ButtonPushedFcn = createCallbackFcn(app, @calibrateafileButtonPushed, true);
            app.calibrateafileButton.Position = [170 46 100 22];
            app.calibrateafileButton.Text = 'calibrate a file';

            % Create calibratecheckerimgButton
            app.calibratecheckerimgButton = uibutton(app.color_calibrate, 'push');
            app.calibratecheckerimgButton.ButtonPushedFcn = createCallbackFcn(app, @calibratecheckerimgButtonPushed, true);
            app.calibratecheckerimgButton.Position = [18 15 129 22];
            app.calibratecheckerimgButton.Text = 'calibrate checker img';

            % Create savecheckerforlateruseButton
            app.savecheckerforlateruseButton = uibutton(app.color_calibrate, 'push');
            app.savecheckerforlateruseButton.FontWeight = 'bold';
            app.savecheckerforlateruseButton.FontColor = [1 0 0];
            app.savecheckerforlateruseButton.ButtonPushedFcn = createCallbackFcn(app, @savecheckerforlateruseButtonPushed, true);
            app.savecheckerforlateruseButton.Position = [155 15 163 22];
            app.savecheckerforlateruseButton.Text = 'save checker for later use'; 
            toggle_colorcalib_uifig_visibility(app);
        end
    
        function delete_calib_itself_components(app)
            delete(app.UsethesavedcolorcheckertoLabel);
            delete(app.batchprocessafolderButton);
            delete(app.colorcalibrateafileButton);            
            delete(app.calibratethecheckeritselftButton);            
        end