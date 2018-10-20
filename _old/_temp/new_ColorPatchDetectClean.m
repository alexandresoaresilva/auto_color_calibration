

rgb1=imread('.\checker_imgs\pictures_with_wrong_points_over_them\check14.png');
I1=rgb2hsv(rgb1);
I1=I1(:,:,3);

% I1 = imgaussfilt(I1,1);
figure; 
imshow(I1)

[regions]=detectMSERFeatures(I1,'RegionAreaRange',[1000 10000]);

circular=(regions.Axes(:,2)./regions.Axes(:,1))>0.9;
regions(circular==0)=[];
tar_reg=cell2mat(regions.PixelList);
BW=zeros(size(I1));
BW(sub2ind(size(I1),tar_reg(:,2),tar_reg(:,1)))=1;
figure
imshow(BW,[]);

T3=[1 0 0; 0 1 0; -5 -5 1];
tform = affine2d(T3);
BW=imwarp(BW,tform,'nearest','outputview',imref2d(size(BW)));
BW=imclearborder(BW,8);
T3=[1 0 0; 0 1 0; 10 10 1];
tform = affine2d(T3);
BW=imwarp(BW,tform,'nearest','outputview',imref2d(size(BW)));
BW=imclearborder(BW,8);
T3=[1 0 0; 0 1 0; -5 -5 1];
tform = affine2d(T3);
BW=imwarp(BW,tform,'nearest','outputview',imref2d(size(BW)));

L=bwlabel(BW);
stats = regionprops('table',L,'Centroid','Area');
sizefilt=stats.Area>(mean(stats.Area)+3*std(stats.Area)) | ...
    stats.Area<mean(stats.Area)-3*std(stats.Area);
if any(sizefilt)
    BW(L==find(sizefilt))=0;
end
stats = regionprops('table',bwlabel(BW),'Centroid');
figure
imshow(BW,[]);

[B,L] = bwboundaries(BW,'noholes');
figure
imshow(label2rgb(L, @jet, [.5 .5 .5]))
hold on
bou=zeros(size(I1));
for k = 1:length(B)
   boundary = B{k};
   plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
   bou(sub2ind(size(I1),floor(boundary(:,1)),floor(boundary(:,2))))=1;
end

[H,T,R] = hough(bou,'Theta',-45:45);
P  = houghpeaks(H,1);
rotang = T(P(:,2)); rho = R(P(:,1));
% if rotang < 0, rotang=rotang+90; end
plot(rotang,rho,'s','color','white');
% figure
% imshow(imrotate(I1,rotang),[])

Sfft=abs(fftshift(fft2(imrotate(bou,rotang,'nearest','crop'))));
% figure
% imshow(Sfft,[])

win=Sfft(480/2+1,640/2+1-15:640/2+1+15);
win(16-2:16+2)=0;
[m,ind]=max(win(:));

[x,y]=ind2sub([1,31],ind);

fff_r=abs(16-y);

win=Sfft(480/2+1-15:480/2+1+15,640/2+1+fff_r);

win(16-2:16+2)=0;
[m,ind]=max(win(:));
[x,y]=ind2sub([31,1],ind);
fff_c=abs(16-x);

mask=uint8(zeros(size(I1)));

figure
imshow(BW,[]);
hold on
plot(stats.Centroid(:,1),stats.Centroid(:,2),'r*')
mask(sub2ind(size(I1),floor(stats.Centroid(:,2)),...
    floor(stats.Centroid(:,1))))=255;

BW1=imrotate(BW,rotang,'nearest','crop');
stats1 = regionprops('table',bwlabel(BW1),'PixelList');
xxx=cell2mat(stats1.PixelList);
xmin=min(xxx(:,1));
xmax=max(xxx(:,1));
ymin=min(xxx(:,2));
ymax=max(xxx(:,2));

Rmat=[cosd(rotang) -sind(rotang); sind(rotang) cosd(rotang)];
iRmat=[cosd(rotang) sind(rotang); -sind(rotang) cosd(rotang)];
C=[stats.Centroid(:,1)-640/2 stats.Centroid(:,2)-480/2]*Rmat;
C=[C(:,1)+640/2 C(:,2)+480/2];

% getting bottom borders
Cnew1=[C(:,1) C(:,2)+480/fff_c];
Cnew1(Cnew1(:,1)>xmax | Cnew1(:,1)<xmin,:)=[];
Cnew1(Cnew1(:,2)>ymax | Cnew1(:,2)<ymin,:)=[];
Cnew1=[Cnew1(:,1)-640/2 Cnew1(:,2)-480/2]*iRmat;
Cnew1=[Cnew1(:,1)+640/2 Cnew1(:,2)+480/2];
plot(Cnew1(:,1),Cnew1(:,2),'gs')
mask(sub2ind(size(I1),floor(Cnew1(:,2)),floor(Cnew1(:,1))))=255;

% getting top borders
Cnew2=[C(:,1) C(:,2)-480/fff_c];
Cnew2(Cnew2(:,1)>xmax | Cnew2(:,1)<xmin,:)=[];
Cnew2(Cnew2(:,2)>ymax | Cnew2(:,2)<ymin,:)=[];
Cnew2=[Cnew2(:,1)-640/2 Cnew2(:,2)-480/2]*iRmat;
Cnew2=[Cnew2(:,1)+640/2 Cnew2(:,2)+480/2];
plot(Cnew2(:,1),Cnew2(:,2),'gs')
mask(sub2ind(size(I1),floor(Cnew2(:,2)),floor(Cnew2(:,1))))=255;

% getting centroids on 5 squares to the right
Cnew3=[C(:,1)+640/fff_r C(:,2)];
Cnew3(Cnew3(:,1)>xmax | Cnew3(:,1)<xmin,:)=[];
Cnew3(Cnew3(:,2)>ymax | Cnew3(:,2)<ymin,:)=[];
Cnew3=[Cnew3(:,1)-640/2 Cnew3(:,2)-480/2]*iRmat;
Cnew3=[Cnew3(:,1)+640/2 Cnew3(:,2)+480/2];
plot(Cnew3(:,1),Cnew3(:,2),'gs')
mask(sub2ind(size(I1),floor(Cnew3(:,2)),floor(Cnew3(:,1))))=255;
% getting centroids on 5 squares to the left
Cnew4=[C(:,1)-640/fff_r C(:,2)];
Cnew4(Cnew4(:,1)>xmax | Cnew4(:,1)<xmin,:)=[];
Cnew4(Cnew4(:,2)>ymax | Cnew4(:,2)<ymin,:)=[];
Cnew4=[Cnew4(:,1)-640/2 Cnew4(:,2)-480/2]*iRmat;
Cnew4=[Cnew4(:,1)+640/2 Cnew4(:,2)+480/2];
plot(Cnew4(:,1),Cnew4(:,2),'gs')
mask(sub2ind(size(I1),floor(Cnew4(:,2)),floor(Cnew4(:,1))))=255;

mask=imdilate(mask,strel('disk',5));
figure
imshow((0.8*rgb1+0.2*mask),[])


