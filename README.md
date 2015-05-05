# tidal-creeks-extraction
MATLAB code for automatic extracting tidal creeks from lidar dem
Automated method for extracting tidal creeks (AMETC) from LiDAR DEMs is implemented in MATLAB R2013a. The AMETC can also be extended to Landsat-8 OLI images (using the modified NDWI). There are three m-files in total.
(1) boundary.m      is generate a land mask from LiDAR DEM. 
(2) Gaussianmatch.m is Gaussian-matched filtering function.
(3) tidalcreekextraction0819a.m is the main file.

Before run the code in MATLAB.
(1) Create a fold in C disk.
(2) Put the demo tif(data1.tif) into C:\test\
(3) run boundary.m
(4) run tidalcreekextraction0819a.m

Notably that the median operation in the Multi-window Median Neighborhood Analysis(MNA) is very sensitive to the size and number of windows used. Hence, we use Matlab Parallel Computing technology to acclerate the operation. 
(1) tidalcreekextraction0819a.m shoud be run in Matlab with an administrator authentication. 
(2) matlabpool number should not exceed the number of computer
