%% input StringToBeFound is char array/string

% If a file with its name starting with StringToBeFound already exists:
%
%   filename_1.ext
%
% the program returns the string/char vector 'filename_2.ext'
% if there are no files within the folder, the extension will be '.mat'
% Written by Alexandre Soares on Sep 18, 2017
%for use with color calibration software to avoid overwritting theprevious
%test
%extension must be passed as 'png', for example.

%%
function newFileName = writeNewFileName(StringToBeFound, extension)
    newFileName = char.empty; %self-expl
    if ~isempty(extension)
        extension = strcat('.',extension);
    end
    
    nameToBeFoundWithUndersc = strcat(StringToBeFound, '_');%followed by underscore
    
    %namesStartingWith(:,1) is file name
    %namesStartingWith(:,2) is extension
	namesStartingWith = string.empty(0,2); % j,1 string array for storing the ...
                    %files starting with filenameToBeFound
                    
    %index of max Value found in namesStartingWith 
    %starts with 1
    maxIndex = uint32(1);  
    maxValue = uint32(0); %max Value found on filename_MAX.mat 
   
    selectedFolder = dir; %struct with filenames from the selected folder

    fileExists = uint8(0); %does not exist byt default

    j=0;%index for file names found and stored in namesStartingWith

    for i=1:length(selectedFolder(:,1)) %finds matches with ....
        %filenameToBeFound in struct with folder's file names

        if startsWith(selectedFolder(i,1).name,StringToBeFound)...
                && ~selectedFolder(i,1).isdir %still if

            j = j + 1;%all the names saved
            namesStartingWith(j,1) = selectedFolder(i,1).name;
            %gets extension (next line)
            [~,~, namesStartingWith(j,2)] = ...
                fileparts(selectedFolder(i,1).name);
            
            %deletes extension from file name, leaving StringToBeFound & number
            namesStartingWith(j,1) = ...
                erase(namesStartingWith(j,1),namesStartingWith(j,2));
            
            %leaves just number, deleting stringToBeFound from file name
            namesStartingWith(j,1) = ...
                erase(namesStartingWith(j,1),nameToBeFoundWithUndersc);
                        
            fileExists = 1;
        end
    end
    numsAfterNames = uint32(str2double(namesStartingWith));
    %delete namesStartingWith;
    
    if fileExists %file(s) with the name already exist in the folder    
        [maxValue, maxIndex] = max(numsAfterNames);
    else
        %namesStartingWith(1,2)='.png'; %default extension
        namesStartingWith(1,2)=extension; %default extensionextension 
    end

    %next index to avoid rewriting the file 
    %1 if file doesn't exist yet
    maxValue = maxValue + 1;

    %it will be name_(maxIndex+1).extension
    newFileName = strcat(nameToBeFoundWithUndersc, num2str(maxValue));
    newFileName = char(strcat(newFileName, namesStartingWith(maxIndex(1,1),2)));
end