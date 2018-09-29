I = checkerboard(40);
J = imrotate(I,30);
imshowpair(I,J,'montage');

fixedPoints = [41 41; 281 161];
movingPoints = [56 175; 324 160];

fixedPoints = [41 41; 281 161];
movingPoints = [56 175; 324 160];

tform = fitgeotrans(movingPoints,fixedPoints,'NonreflectiveSimilarity')

Jregistered = imwarp(J,tform,'OutputView',imref2d(size(I)));
figure
imshowpair(I,Jregistered);

u = [0 1]; 
v = [0 0]; 
[x, y] = transformPointsForward(tform, u, v); 
dx = x(2) - x(1); 
dy = y(2) - y(1); 
angle = (180/pi) * atan2(dy, dx);

scale = 1 / sqrt(dx^2 + dy^2)
