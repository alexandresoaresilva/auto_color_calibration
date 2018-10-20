%inputs: both are character vectors
%       img_folder: folder where imgs can be found
%       extension: e.g. 'png' 
% outputs: file names in img_folder with the specified extension on input
%       file_names2: column vector of strings
%       file_names2_char: column of char vectors (needs deblank before use)
%                   char vectors will have whitespace to fill up the
%                   difference in space between each file name, 
%                   after the extension
%
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
    %b = file_names{1,3}(1,:)

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
