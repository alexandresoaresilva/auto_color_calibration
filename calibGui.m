classdef calibGui  < handle
   properties
%%%%%%%% color calibration image and coordinates and figures and axes %%%%%%%%%%%%%%%%%%
        script_fullPath
        screen_res
        color_calibrate_img %checker image
        calibrated_img
        transform_3x3_matrix
        img_name % char vector for bnaming the img to be calibrated
        norm_color_calib
        norm_color_calib_char
        calib_I_pre_name
        color_calibrate                 matlab.ui.Figure
        normalized_or_not_text          matlab.ui.control.Label
        normalized_explanat_txt         matlab.ui.control.Label
        yesButton                       matlab.ui.control.Button
        noButton                        matlab.ui.control.Button
        make_selection                  matlab.ui.control.Label
        cameraButton                    matlab.ui.control.Button
        openfileButton                  matlab.ui.control.Button
        ready_txt                       matlab.ui.control.Label
        CAPTUREcheckerimageButton       matlab.ui.control.Button
        capture %bobolean flag
        UsethesavedcolorcheckertoLabel  matlab.ui.control.Label
        batchprocessafolderButton       matlab.ui.control.Button
        calibrateafileButton            matlab.ui.control.Button
        calibratecheckerimgButton       matlab.ui.control.Button
        savecheckerforlateruseButton    matlab.ui.control.Button
        checker_path
        checker_found
        img_folder
        fileNames_inFolder
        fileNames_inFolder_char
        files_extension
   end
   methods
       function calibGui = calibGui(calibGui)
            addpath('color_cal_scripts');
            addpath('checker_imgs');
            currentFolder = pwd;
           % appName = mfilename;
            find_color_cal_open = findall(0, 'Type', 'figure','Name','LS Color Calibration');
            
            if ~isempty(find_color_cal_open)
                close(find_color_cal_open);
            end
            calibGui.calib_I_pre_name = 'calib_';
            calibGui.norm_color_calib_char = '';
            appName = strcat({'\'},mfilename); % added for getting rid of slash on the next statement
                                                  %at the end of the full app path
            fullAppPath = mfilename('fullpath');
            app.script_fullPath = erase(fullAppPath,appName);
            
            if ~strcmpi(currentFolder,app.script_fullPath)
                %cd
                cd(app.script_fullPath)
            end
            calibGui = create_color_calib_window(calibGui);
            if nargout == 0
                clear calibGui
            end
       end
       
       function calibGui = create_color_calib_window(calibGui)
            dummy_screen_res = get(0,'screensize');
            calibGui.screen_res = dummy_screen_res(1,3:4);
            % Create color_calibrate
            calibGui.color_calibrate = uifigure;
            calibGui.color_calibrate.Position = [100 100 330 130];
            calibGui.color_calibrate.Name = 'LS Color Calibration';
            calibGui.color_calibrate.Resize = 'off';
            calibGui.color_calibrate.Position(1) = round( (calibGui.screen_res(1) - calibGui.color_calibrate.Position(4)*1.5)/2 );
            calibGui.color_calibrate.Position(2) = round( (calibGui.screen_res(2) - calibGui.color_calibrate.Position(3))/2 );
            calibGui.color_calibrate.CloseRequestFcn = @(color_calibrate, event) calibGui.color_calibrateFig_Close_it;
            calibGui = create_color_calib_window_components(calibGui);
       end
       
       function calibGui = create_color_calib_window_components(calibGui)            
            % Create make_selection
            calibGui.make_selection = uilabel(calibGui.color_calibrate);
            calibGui.make_selection.FontSize = 16;
            calibGui.make_selection.FontWeight = 'bold';
            calibGui.make_selection.Position = [18 76 308 36];
            calibGui.make_selection.Text = {'Select the source (file) of your '; 'reference Macbeth color checker'};

            % Create openfileButton
            calibGui.openfileButton = uibutton(calibGui.color_calibrate, 'push');
            calibGui.openfileButton.ButtonPushedFcn = @(openfileButton,event)calibGui.openfileButtonPushed;
            calibGui.openfileButton.Position = [202 26 100 22];
            calibGui.openfileButton.Text = 'open file';
        end
        function color_calibrateFig_Close_it(calibGui,event)
            if isvalid(calibGui.color_calibrate)
                delete(calibGui.color_calibrate);
            end
        end
        % Button pushed function: openfileButton
        function calibGui = openfileButtonPushed(calibGui, event)
            calibGui.checker_path = '';
            [calibGui.img_name, calibGui.checker_path] = uigetfile('*.png');
            
            if ~isnumeric(calibGui.checker_path)
                calibGui.color_calibrate_img = imread([calibGui.checker_path, calibGui.img_name]);
                calibGui = delete_1st_dialog_elements(calibGui);
                calibGui = creat_norm_buttons(calibGui);
            end
        end
        
        function calibGui = delete_1st_dialog_elements(calibGui)
            delete(calibGui.cameraButton);
            delete(calibGui.openfileButton);
            delete(calibGui.make_selection);            
        end
    
        function calibGui = creat_norm_buttons(calibGui)
            % Create normalized_or_not_text
            calibGui.normalized_or_not_text = uilabel(calibGui.color_calibrate);
            calibGui.normalized_or_not_text.HorizontalAlignment = 'center';
            calibGui.normalized_or_not_text.FontSize = 16;
            calibGui.normalized_or_not_text.FontWeight = 'bold';
            calibGui.normalized_or_not_text.Position = [27 82 285 36];
            calibGui.normalized_or_not_text.Text = {'Do you want the color calibration to '; 'normalize the RGB vectors?'};
            %calibGui.color_calibrate.Visible = '';

            % Create normalized_explanat_txt
            calibGui.normalized_explanat_txt = uilabel(calibGui.color_calibrate);
            calibGui.normalized_explanat_txt.Position = [55 49 226 28];
            calibGui.normalized_explanat_txt.Text = {'normalization divides [R, G, B]./ 255  and '; 'then performs least-squares regression'};

            % Create yesButton
            calibGui.yesButton = uibutton(calibGui.color_calibrate, 'push');
            calibGui.yesButton.ButtonPushedFcn = @(yesButtonPushed,event)calibGui.yesButtonPushed;
            
            %calibGui.yesButton.ButtonPushedFcn = createCallbackFcn(calibGui, @yesButtonPushed, true);
            calibGui.yesButton.Position = [27 15 100 22];
            calibGui.yesButton.Text = 'yes';

            % Create noButton
            calibGui.noButton = uibutton(calibGui.color_calibrate, 'push');
            calibGui.noButton.ButtonPushedFcn = @(noButton,event)calibGui.noButtonPushed;
            
            %calibGui.noButton.ButtonPushedFcn = createCallbackFcn(calibGui, @noButtonPushed, true);
            calibGui.noButton.Position = [200 15 100 22];
            calibGui.noButton.Text = 'no';
            calibGui = toggle_colorcalib_uifig_visibility(calibGui);
        end
    
        function calibGui = delete_2nd_dialog_elements(calibGui)
            if isvalid(calibGui.normalized_or_not_text);
                delete(calibGui.normalized_or_not_text );
                delete(calibGui.normalized_explanat_txt);
                delete(calibGui.yesButton);            
                delete(calibGui.noButton);
            end
        end
        function calibGui = calibrate_or_restart(calibGui)
            calibGui = color_calibrate_image(calibGui);
            if calibGui.checker_found
                calibGui = create_calib_itself_components(calibGui);
                calibGui =  toggle_colorcalib_uifig_visibility(calibGui);
            else
                warndlg({'Could not detect Macbeth checker. Please try again'});
                calibGui = delete_2nd_dialog_elements(calibGui);
                calibGui = create_color_calib_window_components(calibGui);
            end
        end
        % Button pushed function: yesButton
        function calibGui = yesButtonPushed(calibGui, event)
            calibGui.norm_color_calib = 1;

            calibGui.calib_I_pre_name =...
                [calibGui.calib_I_pre_name, 'norm_']
            %calibGui.norm_color_calib_char = 'norm_';
            calibGui = calibrate_or_restart(calibGui);
        end

        % Button pushed function: noButton
        function calibGui = noButtonPushed(calibGui, event)
            calibGui.norm_color_calib = 0;
            calibGui = calibrate_or_restart(calibGui);
        end
    
        function calibGui =  toggle_colorcalib_uifig_visibility(calibGui)
            %toggles visibility so it comes back to the foreground
            calibGui.color_calibrate.Visible = 'off';
            calibGui.color_calibrate.Visible = 'on'; 
        end
    
        function calibGui = color_calibrate_image(calibGui)
            [calibGui.calibrated_img, calibGui.transform_3x3_matrix] =...
                colorCalib(calibGui.color_calibrate_img, calibGui.img_name, calibGui.norm_color_calib);
            size_matrix = size(calibGui.transform_3x3_matrix);
            if ~(size_matrix(1) == 3) && ~(size_matrix(2) == 3)
                %warndlg({'Could not detect Macbeth checker. Please try again'});
                calibGui.checker_found = 0;
            else
                calibGui.checker_found = 1;
            end              
        end
        
        % Button pushed function: calibrateafileButton
        function calibGui = calibrateafileButtonPushed(calibGui, event)
            img_to_be_calibrated_name = '';
            [img_to_be_calibrated_name, file_path] = uigetfile('*.png');
            
            if ischar(img_to_be_calibrated_name)
                older_folder = cd(file_path);
                
                I_to_be_calibrated = imread(img_to_be_calibrated_name);
                
                mkdir calibrated
                cd calibrated;

                calib_img =...
                    calibration_routine(calibGui.transform_3x3_matrix, I_to_be_calibrated);
                
                calib_I_name =....
                        [calibGui.calib_I_pre_name, img_to_be_calibrated_name];
                imwrite(calib_img,calib_I_name);
               %open dialog box with path where file was saved
               text_diag = {pwd};
               diag_saved_files_path(calibGui,text_diag,calib_I_name);
            end
        end
        
        % Button pushed function: batchprocessafolderButton
        function calibGui = batchprocessafolderButtonPushed(calibGui, event)
            current_folder = cd(calibGui.checker_path);
            folder_path = uigetdir(pwd);
            
            %calib_I_pre_name = 'calib_';
            if ischar(folder_path)
                old_folder = cd(folder_path );
                calibGui.files_extension = 'png';
                calibGui.img_folder = cd(folder_path );
                calibGui = save_file_names_in_folder(calibGui);

                mkdir calibrated;
                
                for img_i=1:size(calibGui.fileNames_inFolder,1)
                    I_name =...
                        deblank(calibGui.fileNames_inFolder_char(img_i,:));
                    new_img = imread(I_name);
                    calib_img =...
                        calibration_routine(calibGui.transform_3x3_matrix, new_img);
                    
                    I_name = [calibGui.calib_I_pre_name,I_name];    
                    imwrite(calib_img,['calibrated\',I_name]);
                    no_of_files = img_i;
                end
                calib_I_name = [': ', num2str(img_i), ' calibrated images'];
                %open dialog box with path where file was saved
                text_diag = {pwd};
                diag_saved_files_path(calibGui,text_diag,calib_I_name);
                cd(old_folder);
            end
        end

        function this = save_file_names_in_folder(this)
            %gets file names with the selected extension
            current_folder = pwd; %saving so the program can return to the original  folder

            cd(this.img_folder);
            if this.files_extension(1) ~= '*'
                if this.files_extension(1) ~= '.'
                    this.files_extension = char(strcat('*.',this.files_extension));
                else
                    this.files_extension = char(strcat('*',this.files_extension));
                end
            end

            file_names = struct2cell(dir(this.files_extension));
            this.fileNames_inFolder = string.empty(0, length(file_names(1,:)) );

            for i=1:size(file_names,2)%no. of columns
                %file_name_dummy = cell2mat(file_names(1,i));
                file_name_dummy = file_names{1,i}(1,:);
                file_name_dummy = string(file_name_dummy);
                if i == 1
                    this.fileNames_inFolder = file_name_dummy;
                else
                    this.fileNames_inFolder = [this.fileNames_inFolder; file_name_dummy];
                end
            end
            this.fileNames_inFolder_char = char(this.fileNames_inFolder);
            cd(current_folder);
        end

        % Button pushed function: calibratecheckerimgButton
        function calibGui = calibratecheckerimgButtonPushed(calibGui, event)
           current_folder = cd(calibGui.checker_path);
           mkdir calibrated
           cd calibrated;
           
           calib_img_name =...
                 [calibGui.calib_I_pre_name, calibGui.img_name];
           imwrite(calibGui.calibrated_img, calib_img_name);
           %open dialog box with path where file was saved
           text_diag = {pwd};
           diag_saved_files_path(calibGui,text_diag,calib_img_name);
           %goes back to main folder
           cd(current_folder);
        end
    
        function calibGui = savecheckerforlateruseButtonPushed(calibGui,event)
            older_folder = cd(calibGui.checker_path);
            mkdir calibrated
            cd calibrated;
            calib_folder = 0;
            calib_folder = uigetdir(pwd);
            if ischar(calib_folder)
                %calib_folder = pwd;
                calib_img = calibGui.calibrated_img;
                file_name_orig = calibGui.img_name;
                file_name_orig = [file_name_orig(1:(end-4)),'_original',...
                    file_name_orig((end-3):end)];

                calib_I_name = [calibGui.calib_I_pre_name,...
                    calibGui.norm_color_calib_char];
                %calib_I_name = [calib_I_name, calibGui.img_name];


                file_name = [calibGui.calib_I_pre_name, calibGui.img_name];
                %file_name = ['calib_', calibGui.img_name];
                file_name2 = [calib_folder,'\',file_name];

                M_name_txt = ['M_transf_matrix',file_name, '.txt'];
                M_name_mat = ['M_transf_matrix',file_name, '.mat'];
                M_txt = [calib_folder,'\', M_name_txt];
                M_mat = [calib_folder,'\', M_name_mat];

                imwrite(calibGui.calibrated_img, file_name2);
                imwrite(calibGui.color_calibrate_img, file_name_orig);
                M = calibGui.transform_3x3_matrix;
                save(M_mat,'M');
                fileID = fopen(M_txt,'w');
                for i=1:3
                    fprintf(fileID, [num2str(M(i,:)),'\n']);
                end

                text_diag = {calib_folder;file_name;M_name_txt;M_name_mat};
                file_name = [file_name, ', M_3x3_transf_matrix (.txt & .mat)'];
                
                diag_saved_files_path(calibGui,text_diag,file_name);
            end
            cd(older_folder)            
        end

        %text diag is a cell array
        function this = diag_saved_files_path(this,text_diag,file_name)
            width_diag = 10*length(text_diag{1});
            height_diag = 30*length(text_diag);
            x_pos = round( (this.screen_res(1) - width_diag/2)/2 );
            bottom_pos = round( (this.screen_res(2) - height_diag/2)/2 );
            %file_name = [file_name, ', M_3x3_transf_matrix (.txt & .mat)'];
            d = dialog('Position',[x_pos bottom_pos width_diag height_diag],...
               'Name',['checker ', file_name, ' saved in']);
            txt = uicontrol('Parent',d,'Style','text','FontSize',13,...
                'Position',[20 10 width_diag-10 height_diag-10],...
               'String',text_diag);
        end
        
        % Create UIFigure and components
        function calibGui = create_calib_itself_components(calibGui)
                calibGui = delete_2nd_dialog_elements(calibGui);
%             if (calibGui.checker_found)
                % Create UsethesavedcolorcheckertoLabel
                calibGui.UsethesavedcolorcheckertoLabel = uilabel(calibGui.color_calibrate);
                calibGui.UsethesavedcolorcheckertoLabel.HorizontalAlignment = 'center';
                calibGui.UsethesavedcolorcheckertoLabel.FontSize = 16;
                calibGui.UsethesavedcolorcheckertoLabel.FontWeight = 'bold';
                calibGui.UsethesavedcolorcheckertoLabel.Position = [45 90 248 22];
                calibGui.UsethesavedcolorcheckertoLabel.Text = 'Use the saved color checker to ';

                % Create batchprocessafolderButton
                calibGui.batchprocessafolderButton = uibutton(calibGui.color_calibrate, 'push');
                calibGui.batchprocessafolderButton.ButtonPushedFcn =...
                    @(batchprocessafolderButton,event)calibGui.batchprocessafolderButtonPushed;
                calibGui.batchprocessafolderButton.Position = [16 46 134 22];
                calibGui.batchprocessafolderButton.Text = 'batch process a folder';             

                %Create calibrateafileButton
                calibGui.calibrateafileButton = uibutton(calibGui.color_calibrate, 'push');
                calibGui.calibrateafileButton.ButtonPushedFcn =...
                    @(calibrateafileButton,event)calibGui.calibrateafileButtonPushed;
                calibGui.calibrateafileButton.Position = [170 46 100 22];
                calibGui.calibrateafileButton.Text = 'calibrate a file';

                % Create calibratecheckerimgButton
                calibGui.calibratecheckerimgButton = uibutton(calibGui.color_calibrate, 'push');
                calibGui.calibratecheckerimgButton.ButtonPushedFcn = @(calibratecheckerimgButton,event)calibGui.calibratecheckerimgButtonPushed;
                calibGui.calibratecheckerimgButton.Position = [18 15 129 22];
                calibGui.calibratecheckerimgButton.Text = 'calibrate checker img';

                % Create savecheckerforlateruseButton
                calibGui.savecheckerforlateruseButton = uibutton(calibGui.color_calibrate, 'push');
                calibGui.savecheckerforlateruseButton.FontWeight = 'bold';
                calibGui.savecheckerforlateruseButton.FontColor = [1 0 0];
                calibGui.savecheckerforlateruseButton.ButtonPushedFcn = @(savecheckerforlateruseButton,event)calibGui.savecheckerforlateruseButtonPushed;
                calibGui.savecheckerforlateruseButton.Position = [155 15 163 22];
                calibGui.savecheckerforlateruseButton.Text = 'save checker/matrix'; 
                calibGui =  toggle_colorcalib_uifig_visibility(calibGui);
        end
    
        function calibGui = delete_calib_itself_components(calibGui)
            delete(calibGui.UsethesavedcolorcheckertoLabel);
            delete(calibGui.batchprocessafolderButton);
            %delete(calibGui.colorcalibrateafileButton);            
            %delete(calibGui.calibratethecheckeritselftButton);            
        end
   end
end

