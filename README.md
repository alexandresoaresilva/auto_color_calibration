# auto_color_calibration
Using a MAcbeth color checker (24 colors), it gets the 3x3 matrix to calibrate pictures and then corrects them for negative values.

The working version of the auto color calibration is within this app : https://github.com/alexandresoaresilva/MATLABrealsense. This will be a self-cointained version of that one (unfortunately, for now, you have to use an Intel SR300 camera to use MATLABrealsense).

For now, the part that works are the color calibration scripts not encapsulated in a class. In Matlab, class implementation has lots of quirks I didn't expected (I have just some experience from Java and C++), so avoid those object files and just use the scripts in https://github.com/alexandresoaresilva/auto_color_calibration/tree/master/color_cal_scripts if you need.
