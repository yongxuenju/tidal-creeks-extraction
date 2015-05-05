% This M file is to automatically generate a mask of LiDAR DEM
% The LiDAR DEM is stored in Geotiff format
% The input dir is                  :  c:\test\
% The filename of input LiDAR DEM is:  c:\test\data1.tif  c:\test\data2.tif c:\test\datan.tif
% Three parameters are uesed:  T is the minimun height of sea wall; T1, T2 are the area of sieved objects
% Output filename is                   c:\test\data1-boundary.tif.tif

tic
for qq=1:1
   str1=['C:\test\data',num2str(qq),'-'];
   str2=['C:\test\data',num2str(qq),'.tif'];
   lidardem=geotiffread([str2]);
   [X, R] = geotiffread([str2]);
   info = geotiffinfo([str2]);

   [m,n]=size(lidardem);
   T=4;     % 
   T1=5000; % threshold for extracting land-mask
   T2=200000;
   % boundary extraction
   damboundary = imhmin(lidardem,T);
   damboundary(damboundary<T)=0;
   damboundary(damboundary>=T)=1;
   damboundary=bwareaopen(damboundary, T1,8);
   damboundary=colfilt(damboundary,[5 5],'sliding',@max);
   damboundary=~damboundary;
   damboundary=bwareaopen(damboundary, T1,8);
   damboundary=~damboundary;
   
   se = strel('disk',3);
   damboundary=imdilate(damboundary,se);
   damboundary=imerode(damboundary,se);
   damboundary=~damboundary;
   damboundary=bwareaopen(damboundary, T2,8);
   damboundary=~damboundary;
   geotiffwrite([str1,'boundary.tif'],damboundary,R, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag); 
end;
toc
