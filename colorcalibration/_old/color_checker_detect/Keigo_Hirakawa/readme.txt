*********************
CCFind.m readme file
*********************

1. Citation
If you use CCFind.m in any part of your project, please cite it as: 

  K. Hirakawa, "Color Checker Finder," accessed from
  http://campus.udayton.edu/~ISSL/software.


2. Copyright Notice
This code is copyrighted by PI Keigo Hirakawa. The softwares are for research use only. Use of software for commercial purposes without a prior agreement with the authors is strictly prohibited. We do not guarantee the code’s accuracy. We would appreciate if acknowledgments were made for the use of our codes in your publications.

3. What it does:
CCFind.m will detect the Macbeth ColorChecker inside an image. It will return the coordinates for the center points of the squares.

4. How to use it:
  [X,C]=CCFind(I)
  I: input image (grayscale, color, multispectral)
  X: center points of colorchecker squares
  C: colors corresponding to the squares
  X and C are empty if the detection was unsuccessful.

5. How it works:
CCFind.m does not detect squares explicitly. Instead, it learns the recurring shapes inside an image. Because ColorChecker has 24 squares, CCFind usually detects the square shapes. The code is >95% accurate on Shi’s dataset, and should run reasonably fast on a modern desktop computer.  The code was specifically designed not to use color as a cue. This is so that CCFind can be used with unconventional lighting or multispectral sensors.  Code does not support multiple ColorCheckers. We’re working on that.

6. Why CCFind?
Calibration and parameter tuning are essential for camera development.  Although it is labor intensive to look for coordinates of calibration targets such as the Macbeth ColorChecker, most companies/researchers/photographers still do this by hand.  ISSL developed CCFind.m to help shorten the time spent tuning camera pipelines as a service to the camera manufacturers and fellow researchers that we come into contact with on daily basis.

7. Suggestions:
- Macbeth ColorChecker can be in any orientation, any size, at any location.
- Most failures occur when the recurring shape is not detected (see findshape.m).
- CCFind.m may “give up” (X and C empty). But it rarely gives “wrong” answers (when X and C are returned).
- Generally, code will work more accurately at higher resolution (though slow), and smaller ColorChecker is more difficult to find. Try CCFind on smaller image first, and iff unsuccessful, try full resolution:
  [X,C] = CCFind(imresize(I,1/3));
  X = X*3;
  if isempty(X), [X,C] = CCFind(I); end

Incremental updates will be brought to this website as they are made.  We are working to improve accuracy and support multiple ColorCheckers.
