file_names = save_file_names_in_folder(pwd,'png');
for i=1:size(file_names,1)
    newname = ['gray_',num2str(i),'.png'];
    grayImg = uint8(rgb2gray(imread(file_names(i,:))));
   imwrite(grayImg,newname);
end