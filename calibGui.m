classdef calibGui  < handle
   properties
%%%%%%%% color calibration image and coordinates and figures and axes %%%%%%%%%%%%%%%%%%
        script_fullPath
        screen_res
        small_window_pos
        screen_center
        color_calibrate_img %checker image
        calibrated_img
        RGB_ref_values
        error_cell_pkg
        color_labels
        RGB_triplets_plot
        transform_3x3_matrix
        img_name % char vector for bnaming the img to be calibrated
        norm_color_calib
        norm_color_calib_char
        window_calib_plots
        calib_I_pre_name
        ax_calib
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
       function this = calibGui(this)
            addpath('color_cal_scripts');
            addpath('checker_imgs');
            currentFolder = pwd;
           % appName = mfilename;
            find_color_cal_open = findall(0, 'Type', 'figure','Name','LS Color Calibration');
            
            if ~isempty(find_color_cal_open)
                close(find_color_cal_open);
            end
            this.calib_I_pre_name = 'calib_';
            this.norm_color_calib_char = '';
            appName = strcat({'\'},mfilename); % added for getting rid of slash on the next statement
                                                  %at the end of the full app path
            fullAppPath = mfilename('fullpath');
            app.script_fullPath = erase(fullAppPath,appName);
            
            if ~strcmpi(currentFolder,app.script_fullPath)
                %cd
                cd(app.script_fullPath)
            end
            this = create_color_calib_window(this);
            if nargout == 0
                clear calibGui
            end
       end
       
       function this = create_color_calib_window(this)
            dummy_screen_res = get(0,'screensize');
            this.screen_res = dummy_screen_res(1,3:4);
            
            % Create color_calibrate
            this.color_calibrate = uifigure;
            this.color_calibrate.Position = [100 100 330 130];
            this.color_calibrate.Name = 'LS Color Calibration';
            this.color_calibrate.Resize = 'off';
            this = bring_app_to_center(this,0);
%             this.color_calibrate.Position(1) = round( (this.screen_res(1) - this.color_calibrate.Position(4)*1.5)/2 );
%             this.color_calibrate.Position(2) = round( (this.screen_res(2) - this.color_calibrate.Position(3))/2 );
            %saves center for posterior use (small window center)
            this.small_window_pos = this.color_calibrate.Position;
            %this.screen_center(1,:) = this.color_calibrate.Position(1:2);
            
            %this.color_calibrate.Position(1:2) = [100 100];
            this.color_calibrate.CloseRequestFcn = @(color_calibrate, event) this.color_calibrateFig_Close_it;
            this = create_color_calib_window_components(this);
       end
       
%        function this = init_calib_plots(this)
%           this.window_calib_plots = uifigure;
%           
%             this.color_calibrate = ;
%             this.color_calibrate.Position = [100 100 330 130];
%             this.color_calibrate.Name = 'Calibration Results';
% 
%        end
       
       function this = bring_app_to_center(this,offset)
            this.color_calibrate.Position(1) = round( (this.screen_res(1) - this.color_calibrate.Position(4)*1.5)/2 );
            this.color_calibrate.Position(2) = round( (this.screen_res(2) - this.color_calibrate.Position(3))/2 + 100+offset); 
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
        function color_calibrateFig_Close_it(this,event)
            if isvalid(this.color_calibrate)
                delete(this.color_calibrate);
            end
        end
        % Button pushed function: openfileButton
        function this = openfileButtonPushed(this, event)
            this.checker_path = '';
            [this.img_name, this.checker_path] = uigetfile('*.png');
            
            if ~isnumeric(this.checker_path)
                this.color_calibrate_img = imread([this.checker_path, this.img_name]);
                this = delete_1st_dialog_elements(this);
                this = creat_norm_buttons(this);
            end
        end
        
        function this = delete_1st_dialog_elements(this)
            delete(this.color_calibrate.Children);
        end
        function this = create_calib_pics_and_errors(this)            
             %first not normalized
            [this.calibrated_img{1}, this.transform_3x3_matrix{1},...
                this.RGB_ref_values, this.error_cell_pkg{1}] =...
                colorCalib(this.color_calibrate_img, this.img_name, 0);
            %initializes vars for plotting RMS error
            size_matrix = size(this.transform_3x3_matrix{1});
            if ~(size_matrix(1) == 3) && ~(size_matrix(2) == 3)
                %warndlg({'Could not detect Macbeth checker. Please try again'});
                this.checker_found = 0;
            else
                this.checker_found = 1;
            end

            if this.checker_found
                this = init_error_values(this);
                %second normalized
                [this.calibrated_img{2}, this.transform_3x3_matrix{2},...
                    ~, this.error_cell_pkg{2}] =...
                    colorCalib(this.color_calibrate_img, this.img_name, 1);
                % adjusting window
                new_res = round(this.screen_res*2/3);
                this.color_calibrate.Position(3:4) = [new_res(1), new_res(2)];
                this.color_calibrate.AutoResizeChildren = 'off';
        % ====================== 1st pic without normalization + error calculated 
                this.ax_calib{1} = subplot(2,2,1,'Parent',this.color_calibrate);
                %rotates images 90 degress so they can fit together, side by
                %side, in a 4:3 ratio
                rot_I = imrotate(this.color_calibrate_img,90);
                rot_I_Calib1 = imrotate(this.calibrated_img{1},90);            
                I_s = imshow([rot_I, rot_I_Calib1],'Parent',this.ax_calib{1});
                
                title_noCal_vs_cal=...
                    {['within distance: $\frac{\sum_{i=1}^{24}\Delta{RGB}}{24}$= ',... 
                    num2str(this.error_cell_pkg{1}{4})];['where ',...
                    '$\Delta{RGB = }\sqrt{\sum_{k=1}^3(ref_{k}-samples_{k})^{2}}$']};
                title(title_noCal_vs_cal,'Interpreter','latex','Parent',this.ax_calib{1});
                xlabel('calib (not normalized)','FontSize',12,'Parent',this.ax_calib{1});
                
                %plot of the errors for each color
                this.ax_calib{2} = subplot(2,2,3,'Parent',this.color_calibrate);
                
                this = plot_RMS_error(this, this.error_cell_pkg{1},this.ax_calib{2});            
                title('RMS errors: $\sqrt{\frac{1}{3}\sum_{k=1}^3(ref_{k}-samples_{k})^{2}}$',...
                    'Interpreter','latex','Parent',this.ax_calib{2}); 
        % ====================== 2nd pic (normalized) + error calculated'
                this.ax_calib{3} = subplot(2,2,2,'Parent',this.color_calibrate);
                %rotates images 90 degress so they can fit together, side by
                %side, in a 4:3 ratio
                %now original in parallel with calib normalized
                rot_I_Calib1 = imrotate(this.calibrated_img{2},90);            
                I_s = imshow([rot_I, rot_I_Calib1],'Parent',this.ax_calib{3});
                
                title_noCal_vs_cal=...
                    {['within distance: $\frac{\sum_{i=1}^{24}\Delta{RGB}}{24}$= ',... 
                    num2str(this.error_cell_pkg{2}{4})];['where ',...
                    '$\Delta{RGB = }\sqrt{\sum_{k=1}^3(ref_{k}-samples_{k})^{2}}$']};
                title(title_noCal_vs_cal,'Interpreter','latex','Parent',this.ax_calib{3});
                xlabel('calib (normalized)','FontSize',12,'Parent',this.ax_calib{3});
                
                %plot of the errors for each color
                this.ax_calib{4} = subplot(2,2,4,'Parent',this.color_calibrate);
                
                this = plot_RMS_error(this, this.error_cell_pkg{2},this.ax_calib{4});            
                title('RMS errors: $\sqrt{\frac{1}{3}\sum_{k=1}^3(ref_{k}-samples_{k})^{2}}$',...
                    'Interpreter','latex','Parent',this.ax_calib{4});
            end
        end
        function this = creat_norm_buttons(this)
%             I_s2 = imshow([rot_I, rot_I_Calib1],'Parent',ax2);
%             x = this.color_calibrate.Position(3:4);
%             %Create normalized_or_not_text
%             x=round(x(2)/2);
%             y=round(x(1)/2);
            
            this = create_calib_pics_and_errors(this);
            if this.checker_found
                this = bring_app_to_center(this,200);
                this.normalized_or_not_text = uilabel(this.color_calibrate);
                this.normalized_or_not_text.HorizontalAlignment = 'center';
                this.normalized_or_not_text.FontSize = 16;
                this.normalized_or_not_text.FontWeight = 'bold';
                this.normalized_or_not_text.Position = [27 82 285 36];
                this.normalized_or_not_text.Text = {'Use normalized?'};
                %calibGui.color_calibrate.Visible = '';

                % Create normalized_explanat_txt
                this.normalized_explanat_txt = uilabel(this.color_calibrate);
                this.normalized_explanat_txt.Position = [55 49 226 28];
                this.normalized_explanat_txt.Text = {'normalization divides [R, G, B]/(R+G+B)  and '; 'then performs least-squares regression'};

                % Create yesButton
                this.yesButton = uibutton(this.color_calibrate, 'push');
                this.yesButton.ButtonPushedFcn = @(yesButtonPushed,event)this.yesButtonPushed;

                %calibGui.yesButton.ButtonPushedFcn = createCallbackFcn(calibGui, @yesButtonPushed, true);
                this.yesButton.Position = [27 15 100 22];
                this.yesButton.Text = 'yes';

                % Create noButton
                this.noButton = uibutton(this.color_calibrate, 'push');
                this.noButton.ButtonPushedFcn = @(noButton,event)this.noButtonPushed;

                %calibGui.noButton.ButtonPushedFcn = createCallbackFcn(calibGui, @noButtonPushed, true);
                this.noButton.Position = [200 15 100 22];
                this.noButton.Text = 'no';
                this = toggle_colorcalib_uifig_visibility(this);
            else
                this = calibrate_or_restart(this);
            end
        end
        % Button pushed function: yesButton
        function this = yesButtonPushed(this, event)
            this.norm_color_calib = 1;
            this.calibrated_img = this.calibrated_img{2};
            this.transform_3x3_matrix = this.transform_3x3_matrix{2};
            this.error_cell_pkg = this.error_cell_pkg{2};
            
            this.calib_I_pre_name =...
                [this.calib_I_pre_name, 'norm_'];
            this = calibrate_or_restart(this);
        end
        % Button pushed function: noButton
        function this = noButtonPushed(this, event)
            this.norm_color_calib = 0;
            this.calibrated_img = this.calibrated_img{1};
            this.transform_3x3_matrix = this.transform_3x3_matrix{1};
            this.error_cell_pkg = this.error_cell_pkg{1};
            
            this = calibrate_or_restart(this);
        end
        function this = delete_2nd_dialog_elements(this)
            if isvalid(this.normalized_or_not_text)
                delete(this.color_calibrate.Children)
            end
        end
        function this = calibrate_or_restart(this)
            %calibGui = color_calibrate_image(calibGui);
            if this.checker_found
                this = create_calib_itself_components(this);
                this =  toggle_colorcalib_uifig_visibility(this);
            else
                warndlg({'Could not detect Macbeth checker.';...
                    'Try with a different image.'});
                this = delete_2nd_dialog_elements(this);
                %this = create_color_calib_window_components(this);
            end
        end
        function this =  toggle_colorcalib_uifig_visibility(this)
            %toggles visibility so it comes back to the foreground
            this.color_calibrate.Visible = 'off';
            this.color_calibrate.Visible = 'on'; 
        end
    
        function this = color_calibrate_image(this)
            [this.calibrated_img, this.transform_3x3_matrix] =...
                colorCalib(this.color_calibrate_img, this.img_name, this.norm_color_calib);
            size_matrix = size(this.transform_3x3_matrix);           
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
               cd(older_folder);
            end
        end
        
        % Button pushed function: batchprocessafolderButton
        function this = batchprocessafolderButtonPushed(this, event)
            current_folder = cd(this.checker_path);
            folder_path = uigetdir(pwd);
            
            %calib_I_pre_name = 'calib_';
            if ischar(folder_path)
                old_folder = cd(folder_path );
                this.files_extension = 'png';
                this.img_folder = cd(folder_path );
                this = save_file_names_in_folder(this);

                mkdir calibrated;
                
                for img_i=1:size(this.fileNames_inFolder,1)
                    I_name =...
                        deblank(this.fileNames_inFolder_char(img_i,:));
                    new_img = imread(I_name);
                    calib_img =...
                        calibration_routine(this.transform_3x3_matrix, new_img);
                    
                    I_name = [this.calib_I_pre_name,I_name];    
                    imwrite(calib_img,['calibrated\',I_name]);
                    no_of_files = img_i;
                end
                calib_I_name = [': ', num2str(img_i), ' calibrated images'];
                %open dialog box with path where file was saved
                text_diag = {[pwd, '\calibrated']};
                diag_saved_files_path(this,text_diag,calib_I_name);
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
        function this = calibratecheckerimgButtonPushed(this, event)
           current_folder = cd(this.checker_path);
           mkdir calibrated
           cd calibrated;
           
           calib_img_name =...
                 [this.calib_I_pre_name, this.img_name];
           imwrite(this.calibrated_img, calib_img_name);
           %open dialog box with path where file was saved
           text_diag = {pwd};
           diag_saved_files_path(this,text_diag,calib_img_name);
           %goes back to main folder
           cd(current_folder);
        end
    
        function this = savecheckerforlateruseButtonPushed(this,event)
            older_folder = cd(this.checker_path);
            mkdir calibrated
            cd calibrated;
            calib_folder = 0;
            calib_folder = uigetdir(pwd);
            if ischar(calib_folder)
                %calib_folder = pwd;
                calib_img = this.calibrated_img;
                file_name_orig = this.img_name;
                file_name_orig = [file_name_orig(1:(end-4)),'_original',...
                    file_name_orig((end-3):end)];

                calib_I_name = [this.calib_I_pre_name,...
                    this.norm_color_calib_char];
                %calib_I_name = [calib_I_name, calibGui.img_name];


                file_name = [this.calib_I_pre_name, this.img_name];
                %file_name = ['calib_', calibGui.img_name];
                file_name2 = [calib_folder,'\',file_name];

                M_name_txt = ['M_transf_matrix',file_name, '.txt'];
                M_name_mat = ['M_transf_matrix',file_name, '.mat'];
                M_txt = [calib_folder,'\', M_name_txt];
                M_mat = [calib_folder,'\', M_name_mat];

                imwrite(this.calibrated_img, file_name2);
                imwrite(this.color_calibrate_img, file_name_orig);
                M = this.transform_3x3_matrix;
                save(M_mat,'M');
                fileID = fopen(M_txt,'w');
                for i=1:3
                    fprintf(fileID, [num2str(M(i,:)),'\n']);
                end

                text_diag = {calib_folder;file_name;M_name_txt;M_name_mat};
                file_name = [file_name, ', M_3x3_transf_matrix (.txt & .mat)'];
                
                diag_saved_files_path(this,text_diag,file_name);
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
        function this = create_calib_itself_components(this)
                this = delete_2nd_dialog_elements(this);
                
                this.color_calibrate.Position = this.small_window_pos;
                %this = bring_app_to_center(this,0);
                % Create UsethesavedcolorcheckertoLabel
                this.UsethesavedcolorcheckertoLabel = uilabel(this.color_calibrate);
                this.UsethesavedcolorcheckertoLabel.HorizontalAlignment = 'center';
                this.UsethesavedcolorcheckertoLabel.FontSize = 16;
                this.UsethesavedcolorcheckertoLabel.FontWeight = 'bold';
                this.UsethesavedcolorcheckertoLabel.Position = [45 90 248 22];
                this.UsethesavedcolorcheckertoLabel.Text = 'Use the saved color checker to ';

                % Create batchprocessafolderButton
                this.batchprocessafolderButton = uibutton(this.color_calibrate, 'push');
                this.batchprocessafolderButton.ButtonPushedFcn =...
                    @(batchprocessafolderButton,event)this.batchprocessafolderButtonPushed;
                this.batchprocessafolderButton.Position = [16 46 134 22];
                this.batchprocessafolderButton.Text = 'batch process a folder';             

                %Create calibrateafileButton
                this.calibrateafileButton = uibutton(this.color_calibrate, 'push');
                this.calibrateafileButton.ButtonPushedFcn =...
                    @(calibrateafileButton,event)this.calibrateafileButtonPushed;
                this.calibrateafileButton.Position = [170 46 100 22];
                this.calibrateafileButton.Text = 'calibrate a file';

                % Create calibratecheckerimgButton
                this.calibratecheckerimgButton = uibutton(this.color_calibrate, 'push');
                this.calibratecheckerimgButton.ButtonPushedFcn = @(calibratecheckerimgButton,event)this.calibratecheckerimgButtonPushed;
                this.calibratecheckerimgButton.Position = [18 15 129 22];
                this.calibratecheckerimgButton.Text = 'calibrate checker img';

                % Create savecheckerforlateruseButton
                this.savecheckerforlateruseButton = uibutton(this.color_calibrate, 'push');
                this.savecheckerforlateruseButton.FontWeight = 'bold';
                this.savecheckerforlateruseButton.FontColor = [1 0 0];
                this.savecheckerforlateruseButton.ButtonPushedFcn = @(savecheckerforlateruseButton,event)this.savecheckerforlateruseButtonPushed;
                this.savecheckerforlateruseButton.Position = [155 15 163 22];
                this.savecheckerforlateruseButton.Text = 'save checker/matrix'; 
                this =  toggle_colorcalib_uifig_visibility(this);
        end
    
        function this = delete_calib_itself_components(this)
            delete(this.color_calibrate.Children);
%             delete(this.UsethesavedcolorcheckertoLabel);
%             delete(this.batchprocessafolderButton);
            %delete(calibGui.colorcalibrateafileButton);            
            %delete(calibGui.calibratethecheckeritselftButton);            
        end
        
        function this = init_error_values(this)
            this.RGB_triplets_plot = this.RGB_ref_values./255;
            this.color_labels ={'Dark skin'; 'Light skin'; 'Blue sky'; 'Foliage';...
               'Blue flower'; 'Bluish green'; 'Orange'; 'Purplish blue';...
               'Moderate red'; 'Purple'; 'Yellow green'; 'Orange yellow';...
               'Blue'; 'Green'; 'Red'; 'Yellow'; 'Magenta'; 'Cyan'; 'White';...
               'Neutral'; 'Neutral'; 'Neutral'; 'Neutral'; 'Black'};
        end
        function this = plot_RMS_error(this, error_cell_pkg,ax)
            % RMS difference, avg. over RGB
            %=====================================================================
            x_points = 1:length(error_cell_pkg{1});
            scatter(1,error_cell_pkg{1}(1,1),100,...
                this.RGB_triplets_plot(1,:),'filled','Parent',ax);
            hold(ax);
            grid(ax);
            for i=x_points(2:end)
                scatter(x_points(i), error_cell_pkg{1}(i,1), 100,...
                    this.RGB_triplets_plot(i,:),'filled','Parent',ax);
            end
            title('RMS errors: $\sqrt{\frac{1}{3}\sum_{k=1}^3(ref_{k}-samples_{k})^{2}}$','Interpreter','latex',...
                'Parent',ax);
            ylabel('RGB','Parent',ax);
            legend(ax,this.color_labels);
            hold(ax,'off');
        end
   end
end