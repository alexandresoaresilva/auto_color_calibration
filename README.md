# auto_color_calibration

Using an image of a Macbeth color checker (24 colors) under the same light conditions the other pictures you want to calibrate were captured:

1. it detects the checker patches and samples colors; 

2. It calculates a 3x3 transformation matrix through least-squares regression between reference RGA values from the 24 patches and the one sampled from the picture captured with the color checker;

3. You can choose different things to do with the generated matrix: 
  
    3.1. batch process a folder
  
    3.2. color calibrate the captured checker itself
  
    3.3. color calibrate a file
  
    3.4. save checker file for later use
  
    3.5. Still missing : save the transformation matrix.

4. It calculates RMS error, among other distance measures, from the original reference values and the calibrated ones.

To run the object with the color calibration GUI, try ouy the script test.m.

It's fully featured, if rought on the edges.
