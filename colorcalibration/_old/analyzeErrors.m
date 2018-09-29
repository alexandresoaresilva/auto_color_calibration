load('fail_img_err_table.mat')
for i=1:length(fail_img_err_table.Var1)
     disp('=====================================================')
    %checker img file name
    fail_img_err_table.failed_imgs(i)
    %error recorded for it
    fail_img_err_table.Var1(i)
    disp('Line on file: ');
    %line on function file where error was generated
    fail_img_err_table.Var1(i).stack.line
    disp('');
    %just press enter to continue to the next error
    pause
end