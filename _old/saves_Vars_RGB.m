fileID = fopen('hold_values.txt','w');

load('macbeth_checker_positions.mat');
    
load('RGBreference.mat');


for i=1:size(macbeth_checker_positions,1)
    str = [num2str(macbeth_checker_positions(i,1)), '    ',...
        num2str(macbeth_checker_positions(i,2)), '\n'];
    
    fprintf(fileID,str)
end

% 
% 
for i=1:size(RGBREF,1)
    str = [num2str(RGBREF(i,1)), '    ', num2str(RGBREF(i,2)),...
        '    ',num2str(RGBREF(i,3))];
    fprintf(fileID,[str '\n'])
end

fclose('all');
