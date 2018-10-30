# auto_color_calibration

ONLY COMPATIBLE WITH MATLAB 2018b and beyond (uses axes passed to uifigure, feature not available until that version).
Using an image of a Macbeth color checker (24 colors):

![alt text](https://github.com/alexandresoaresilva/auto_color_calibration/blob/master/checker_imgs/check8.png)

### a run of the app
Under the same light conditions the other pictures you want to calibrate were captured, this package of scripts:

1. Detects the checker patches and samples colors; 

2. Calculates a 3x3 transformation matrix through least-squares regression between reference RGA values from the 24 patches and the one sampled from the picture captured with the color checker;

3. You can choose different things to do with the generated matrix: 

![alt text](https://github.com/alexandresoaresilva/auto_color_calibration/blob/master/docs/options_window.JPG)
    
    3.1. batch process a folder
  
    3.2. color calibrate the captured checker itself
  
    3.3. color calibrate a file
  
    3.4. save calibration matrix for later use as a text file and mat file (Matlab variable-saving file).

4. It calculates RMS error of the RGB values, among other distance measures. It uses reference RGB values from the manufacturer, original  sampled values, and calibrated values. Below you can see the plot of normalized vs not normalized calibration, with RMS errors for individual colors and total average error for the 24 colors:

![alt text](https://github.com/alexandresoaresilva/auto_color_calibration/blob/master/docs/error_measurements_v2.png)


### modifying the color calibration scripts

If you want to create other color calibration projects based on this one, the scripts that actually execute color calibration are in the **color_cal_scripts** directory. There, you will find:

- **ColorPatchDetect.m**:detects patches and returns the vector colorPos, with, well, the positions of the colors on your image of the Macbeth checker.

- **colorCalib.m**: finds where the colors are based on finding the most likely white patch with the indeces stored in colorPos. It then finds corners and calculates the remaining color patch positions. Finally, it runs the regression task between reference RGB values and captured RGB values, and returns the 3x3 matrix used to calibrate the picture.

- **calibration_routine.m**: feed to this function an image from the same illumination context as the picture of your color checker and the 3x3 transformation matrix created by the previous function, and it will return a calibrated image, with negative pixels corrected, if they existed.

To run the object with the color calibration GUI, try ouy the script test.m
