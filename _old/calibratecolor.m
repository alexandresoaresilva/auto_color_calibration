function calcos = calibratecolor(RGBREF, RGB) 
    %RGB are arrays of integers 0-255 24 elements long, calcos is 10x3 matrix 
    vals = [ones(24, 1), RGB, RGB.^2];
    calcosR = regress(RGBREF(:, 1), vals);
    calcosG = regress(RGBREF(:, 2), vals);
    calcosB = regress(RGBREF(:, 3), vals);
    calcos = [calcosR, calcosG, calcosB];
end