%output is the file names in img_folder with the specified extension 
% it's a volumn vector of strings & a column of char vectors
% char vectors will have whitespace to fill up the
% difference in space between each file name, after the extension
function file_names2_char = save_file_names_in_folder(img_folder,extension)
    %gets file names with the selected extension
    current_folder = pwd;
    %current_folder = current_folder.folder; %saving so the program can return to the original  folder
    if ~strcmp(pwd, img_folder)
        cd(img_folder); 
    end
    
    extension = char(strcat('*.',extension));
    file_names = struct2cell(dir(extension));
    
    file_names2 = string.empty(0, length(file_names(1,:)) );
    %b = file_names{1,3}(1,:)
    
    for i=1:length(file_names)
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