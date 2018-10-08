# auto_color_calibration

Using an image of a Macbeth color checker (24 colors):

![alt text](https://github.com/alexandresoaresilva/auto_color_calibration/blob/master/checker_imgs/check46.png)

Under the same light conditions the other pictures you want to calibrate were captured, this package of scripts:

1. Detects the checker patches and samples colors; 

2. Calculates a 3x3 transformation matrix through least-squares regression between reference RGA values from the 24 patches and the one sampled from the picture captured with the color checker;

3. You can choose different things to do with the generated matrix: 
  
    3.1. batch process a folder
  
    3.2. color calibrate the captured checker itself
  
    3.3. color calibrate a file
  
    3.4. save calibration matrix for later use as a text file and mat file (Matlab variable-saving file).

4. It calculates RMS error, among other distance measures, from the original reference values and the calibrated ones.

This is the result of the previous checker image:

![alt text](https://github.com/alexandresoaresilva/auto_color_calibration/blob/master/checker_imgs/calibrated/calib_check46.png)

And this is the errors measureded when the color calibration is run, separated by color in 3 of the measurements:

![alt text](https://github.com/alexandresoaresilva/auto_color_calibration/blob/master/docs/error_measurements.JPG)

To run the object with the color calibration GUI, try ouy the script test.m.

It's fully featured, if rought on the edges.
