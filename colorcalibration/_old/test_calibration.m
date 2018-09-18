%% testing all imgs

for i=1:size(f_char,1)
    colorCalibrate(f_char(i,1),'',1,f_char(i,1),'',0)
end