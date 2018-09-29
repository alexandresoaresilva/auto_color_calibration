function color_calibrate = create_color_calib_window_components
    dummy_screen_res = get(0,'screensize');
    screen_res = dummy_screen_res(1,3:4);
    % Create color_calibrate
    color_calibrate = uifigure;
    color_calibrate.Position = [100 100 330 130];
    color_calibrate.Name = 'LS Color Calibration';
    color_calibrate.Resize = 'off';
    color_calibrate.Position(1) = round( (screen_res(1) - color_calibrate.Position(4)*1.5)/2 );
    color_calibrate.Position(2) = round( (screen_res(2) - color_calibrate.Position(3))/2 );

    color_calibrate.CloseRequestFcn = @(color_calibrate, event) color_calibrateFig_Close_it;
    % Create make_selection
    make_selection = uilabel(color_calibrate);
    make_selection.FontSize = 16;
    make_selection.FontWeight = 'bold';
    make_selection.Position = [18 76 308 36];
    make_selection.Text = {'Select the source (file/ camera) of your '; 'reference Macbeth color checker'};

    % Create openfileButton
    openfileButton = uibutton(color_calibrate, 'push');
    openfileButton.ButtonPushedFcn = @(openfileButton,event)openfileButtonPushed;
    openfileButton.Position = [202 26 100 22];
    openfileButton.Text = 'open file';
end