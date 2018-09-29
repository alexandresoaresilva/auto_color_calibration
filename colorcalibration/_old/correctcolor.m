function RGBCOR = correctcolor(calcos, RGB) 
    %RGB are arrays of integers 0-255 X elements long, calcos is a 10x3 matrix 
    RGB = reshape(RGB(:), [], 3);
    n = size(RGB, 1);
    vals = [ones(n, 1), RGB, RGB.^2];
    calcosR = calcos(:, 1)';
    calcosG = calcos(:, 2)';
    calcosB = calcos(:, 3)';
    
    calcosR = repmat(calcosR, size(vals,1), 1);
    calcosG = repmat(calcosG, size(vals,1), 1);
    calcosB = repmat(calcosB, size(vals,1), 1);
    
    R = sum(vals .* calcosR, 2);
    G = sum(vals .* calcosG, 2);
    B = sum(vals .* calcosB, 2);
    
     minR = min(R);
     maxR = max(R);
     R = (R - minR) ./ (maxR - minR) .* 255;
     
     minG = min(G);
     maxG = max(G);
     G = (G - minG) ./ (maxG - minG) .* 255;
     
     minB = min(B);
     maxB = max(B);
     B = (B - minB) ./ (maxB - minB) .* 255;

      RGBCOR = [R, G, B];
%     minRGB = min(min(RGBCOR));
%     maxRGB = max(max(RGBCOR));
%     RGBCOR = (RGBCOR - minRGB) ./ (maxRGB - minRGB);
    
end