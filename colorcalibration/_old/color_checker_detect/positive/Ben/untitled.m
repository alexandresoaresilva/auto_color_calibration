clear all
clc

cam = webcam('Intel(R) RealSense(TM) Camera SR300 RGB');
cam.Resolution = '640x480';
while 1
    
    img = cam.snapshot;
    imagesc(img); axis equal;
    drawnow
end




