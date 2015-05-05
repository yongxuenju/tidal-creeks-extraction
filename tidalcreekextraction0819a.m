tic
matlabpool local 4    

clear
K1=9;     % iterations for median neighborhood analysis(MNA) 
K2=3;     % scales for gaussian matched filtering (GMF)

T2=0.0;
k_threshold = 0.2; % std threshold parameter
k_threshold2 = 0.5;
T4=30;   % threshold for sieve small tidal creeks
T5=100;   % threshold for sieve small tidal creeks

depth=-1.5;
T6=500;

for qq=1:1

    str1=['C:\test\data',num2str(qq),'-'];
    str2=['C:\test\data',num2str(qq),'.tif'];
    lidardem=geotiffread([str2]);
    [X, R] = geotiffread([str2]);
    info = geotiffinfo([str2]);
    [m,n]=size(lidardem);
     % load boundary
    damboundary=geotiffread([str1,'boundary.tif']);
    % calculate residual topography based on median neighborhood analysis (MNA) 
    % parfor i=1:K1
    parfor i=1:K1
        neighborenhance=medfilt2(lidardem,[10*i i*10]);  
        neighborenhance=neighborenhance-lidardem;
        neighborenhance(neighborenhance<0)=0;
        geotiffwrite([str1,num2str(i*10),'-local.tif'],neighborenhance,R, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);    
    end

    %Gaussian matched filtering and local thresholding 
    smallcreek=double(zeros(m,n));
    bigcreek=double(zeros(m,n));
    bigcreek(lidardem<depth)=1;
    for i=1:K1
       neighborenhance = geotiffread([str1,num2str(i*10),'-local.tif']);
         
     %smallcreek extraction
     neighborenhance(lidardem==-10)=0; %消除nodata 的影响
     a7=double(zeros(m,n));
     for j=1:K2
         % Gaussian mathced filter 
         sigma=1.0+0.5*j;
         siz=5*sigma;
         a3=Gaussianmatch(neighborenhance,sigma,siz);
% %          geotiffwrite([str1,num2str(i*10),'-local','-gaussian',num2str(j),'.tif'],a3,R, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag); 
% %          level = graythresh(a3);
% %          BW = im2bw(a3,level);
% %          BW(damboundary==1)=0;
% %          geotiffwrite([str1,num2str(i*10),'-local','-gaussian',num2str(j),'OTSU.tif'],BW,R, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag); 
         
         a3(a3<T2*max(max(a3)))=0;   
         % calculate mean, and std    
         h = fspecial('average',i*10);
         local_mean=imfilter(a3,h,'conv','symmetric');
         local_std = sqrt(imfilter(a3 .^ 2, h, 'symmetric'));
         
         local_std = (local_std - local_mean.^2).^0.5;
         % calculate binary image            
         BW = a3 > (local_mean + k_threshold * local_std);    
         BW(damboundary==1)=0;
% %          geotiffwrite([str1,num2str(i*10),'-local','-gaussian',num2str(j),'firstround.tif'],BW,R, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag); 
         
         % Second local thresholding
         a3(BW==1)=local_mean(BW==1); 
         local_mean=imfilter(a3,h,'conv','symmetric');
         local_std = sqrt(imfilter(a3 .^ 2, h, 'symmetric'));   
         local_std = (local_std - local_mean.^2).^0.5;
         BW2 = a3 > (local_mean + k_threshold * local_std);
         BW2(damboundary==1)=0;
% %          geotiffwrite([str1,num2str(i*10),'-local','-gaussian',num2str(j),'secondround.tif'],BW2,R, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);          
         BW2(BW==1)=1;
% %          geotiffwrite([str1,num2str(i*10),'-local','-gaussian',num2str(j),'merge.tif'],BW2,R, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);    
         BW2=bwareaopen(BW2, T4,8);    
% %          geotiffwrite([str1,num2str(i*10),'-local','-gaussian',num2str(j),'extraction.tif'],BW2,R, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);            
         a7=a7+ double(BW2);   
     end;
     a7(a7>0)=1;
     BW = bwareaopen(a7, T4,8); 
     geotiffwrite([str1,num2str(i*10),'-local','-gaussian-extraction.tif'],BW,R, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);     

     smallcreek=smallcreek+ double(BW); 
     smallcreek(smallcreek>0)=1;
     smallcreek = bwareaopen(smallcreek, T4,8); 
     %geotiffwrite([str1,num2str(i*10),'-local','-gaussian-extraction-sum.tif'],smallcreek,R, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);       
 end
 %bigcreek extraction
 neighborenhance = geotiffread([str1,num2str(K1*10),'-local.tif']);
 
 level = graythresh(neighborenhance);
 BW = im2bw(neighborenhance,level);
 % BW(damboundary==1)=0;
% %  geotiffwrite([str1,'-bigcreek-OTSU.tif'],BW,R, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag); 
         
 h = fspecial('average',K1*10);
 local_mean=imfilter(neighborenhance,h,'conv','symmetric');
 local_std = sqrt(imfilter(neighborenhance .^ 2, h, 'symmetric'));
 local_std = (local_std - local_mean.^2).^0.5;
 bigcreekBW = neighborenhance > (local_mean + k_threshold2 * local_std);     
 bigcreekBW=bwareaopen(bigcreekBW, T6,8);  

  bigcreekBW(damboundary==1)=0;
  geotiffwrite([str1,'-bigcreek-systhen.tif'],bigcreekBW,R, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);
 
  
 % smallcreek post-processing
 smallcreek(smallcreek>0)=1;
 smallcreek = bwareaopen(smallcreek, T4,8); 
 geotiffwrite([str1,'-smallcreek-systhen1.tif'],smallcreek,R, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);

 % smallcreek(damboundary==1)=0;
 smallcreek = bwareaopen(smallcreek, T5,8); 
 geotiffwrite([str1,'-smallcreek-after1.tif'],smallcreek,R, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);
 
 creek=smallcreek+bigcreekBW;
 creek(creek>0)=1;
 creek = bwareaopen(creek, T5,8); 
 creek(lidardem==-10)=0;
 geotiffwrite([str1,'-creek-all-1.tif'],creek,R, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);
end;
matlabpool close
toc
