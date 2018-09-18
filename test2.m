fig = uifigure
dummy_screen_res = get(0,'screensize');
screen_res = dummy_screen_res(1,3:4); %selecting only width and height
fig_name = 'LS Color Calibration';
text_tx = {'Select the source (file/ camera) of your '; 'reference Macbeth color checker'};
no_of_buttons  = 4;
buttons = {'open file';'do that';'do this'; 'do that'}


%position with relation to the screen - centered window
fig.Position(1) = round( (screen_res(1) - fig.Position(4)*1.5)/2 );
fig.Position(2) = round( (screen_res(2) - fig.Position(3))/2 );
%size (width / height form the bottom)
fig.Position(3:4) = [330 130];
fig.Name = fig_name;
fig.Resize = 'off';
fig.CloseRequestFcn = createCallbackFcn(app, @fig_with_button_Close_it, true);


% Create make_selection
text = uilabel(fig);
text.FontSize = 16;
text.FontWeight = 'bold';
text.Position = [18 76 308 36];
text.Text = text_tx;

% Create openfileButton
fig_with_button.openfileButton = uibutton(fig, 'push');
fig_with_button.openfileButton.ButtonPushedFcn = createCallbackFcn(app, @openfileButtonPushed, true);
fig_with_button.openfileButton.Position = [202 26 100 22];
fig_with_button.openfileButton.Text = 'open file';