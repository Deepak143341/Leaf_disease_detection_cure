%%training dataset creating
clc
clear all
close all

folder_name = uigetdir(pwd, 'Select the test directory of images');

 %dataset loading
jpgImagesDir = fullfile(folder_name, '*.jpg');

% calculate total number of images
num_of_jpg_images = numel( dir(jpgImagesDir) );

totalImages = num_of_jpg_images;
jpg_files = dir(jpgImagesDir);

if ( ~isempty( jpg_files ) )
    % read jpg images from stored folder name
    % directory and construct the feature dataset
    jpg_counter = 0;
    for k = 1:totalImages
        
        if ( (num_of_jpg_images - jpg_counter) > 0)
            imgInfoJPG = imfinfo( fullfile( folder_name, jpg_files(jpg_counter+1).name ) );
            if ( strcmp( lower(imgInfoJPG.Format), 'jpg') == 1 )
                % read images
                sprintf('%s \n', jpg_files(jpg_counter+1).name);
                % extract features
                image = imread( fullfile(folder_name, jpg_files(jpg_counter+1).name ) );
                [pathstr, name, ext] = fileparts( fullfile(folder_name, jpg_files(jpg_counter+1).name ) );
                image = imresize(image, [384 256]);
            end
            jpg_counter = jpg_counter + 1;
            
        end
     seg_img=image;   
if size(seg_img,3) == 3
   img = rgb2gray(seg_img);
end

img = adapthisteq(img,'clipLimit',0.02,'Distribution','rayleigh');
% Create the Gray Level Cooccurance Matrices (GLCMs)
glcms = graycomatrix(img);

%Evaluate 13 features from the disease affected region only
% Derive Statistics from GLCM
stats = graycoprops(glcms,'Contrast Correlation Energy Homogeneity');
Contrast = stats.Contrast;
Correlation = stats.Correlation;
Energy = stats.Energy;
Homogeneity = stats.Homogeneity;
Mean = mean2(seg_img);
Standard_Deviation = std2(seg_img);
Entropy = entropy(seg_img);
RMS = mean2(rms(seg_img));
%Skewness = skewness(img)
Variance = mean2(var(double(seg_img)));
a = sum(double(seg_img(:)));
Smoothness = 1-(1/(1+a));
Kurtosis = kurtosis(double(seg_img(:)));
Skewness = skewness(double(seg_img(:)));

m = size(seg_img,1);
n = size(seg_img,2);
in_diff = 0;
for i = 1:m
    for j = 1:n
        temp = seg_img(i,j)./(1+(i-j).^2);
        in_diff = in_diff+temp;
    end
end 
IDM = double(in_diff);

% Put the 13 features in an array
 feat_disease= [Contrast,Correlation,Energy,Homogeneity, Mean, Standard_Deviation, Entropy, RMS, Variance, Smoothness, Kurtosis, Skewness, IDM];

datasettrain(k, :) = feat_disease ;
    end
end
res = [];
for i = 1:10
    temp = zeros(1,1000)+i;
    res = cat(2,res,temp);
end
diseasetypetrain=res;

%uisave ('dataset','dataset')
uisave({'datasettrain','diseasetypetrain'},'datasettrain')


%%
%test dataset creating

clc
clear all
close all

folder_name = uigetdir(pwd, 'Select the test directory of images');

 %dataset loading
jpgImagesDir = fullfile(folder_name, '*.jpg');

% calculate total number of images
num_of_jpg_images = numel( dir(jpgImagesDir) );

totalImages = num_of_jpg_images;
jpg_files = dir(jpgImagesDir);

if ( ~isempty( jpg_files ) )
    % read jpg images from stored folder name
    % directory and construct the feature dataset
    jpg_counter = 0;
    for k = 1:totalImages
        
        if ( (num_of_jpg_images - jpg_counter) > 0)
            imgInfoJPG = imfinfo( fullfile( folder_name, jpg_files(jpg_counter+1).name ) );
            if ( strcmp( lower(imgInfoJPG.Format), 'jpg') == 1 )
                % read images
                sprintf('%s \n', jpg_files(jpg_counter+1).name);
                % extract features
                image = imread( fullfile(folder_name, jpg_files(jpg_counter+1).name ) );
                [pathstr, name, ext] = fileparts( fullfile(folder_name, jpg_files(jpg_counter+1).name ) );
                image = imresize(image, [384 256]);
            end
            jpg_counter = jpg_counter + 1;
            
        end
     seg_img=image;   
if size(seg_img,3) == 3
   img = rgb2gray(seg_img);
end

img = adapthisteq(img,'clipLimit',0.02,'Distribution','rayleigh');
% Create the Gray Level Cooccurance Matrices (GLCMs)
glcms = graycomatrix(img);

%Evaluate 13 features from the disease affected region only
% Derive Statistics from GLCM
stats = graycoprops(glcms,'Contrast Correlation Energy Homogeneity');
Contrast = stats.Contrast;
Correlation = stats.Correlation;
Energy = stats.Energy;
Homogeneity = stats.Homogeneity;
Mean = mean2(seg_img);
Standard_Deviation = std2(seg_img);
Entropy = entropy(seg_img);
RMS = mean2(rms(seg_img));
%Skewness = skewness(img)
Variance = mean2(var(double(seg_img)));
a = sum(double(seg_img(:)));
Smoothness = 1-(1/(1+a));
Kurtosis = kurtosis(double(seg_img(:)));
Skewness = skewness(double(seg_img(:)));

m = size(seg_img,1);
n = size(seg_img,2);
in_diff = 0;
for i = 1:m
    for j = 1:n
        temp = seg_img(i,j)./(1+(i-j).^2);
        in_diff = in_diff+temp;
    end
end 
IDM = double(in_diff);

% Put the 13 features in an array
 feat_disease= [Contrast,Correlation,Energy,Homogeneity, Mean, Standard_Deviation, Entropy, RMS, Variance, Smoothness, Kurtosis, Skewness, IDM];

datasettest(k, :) = feat_disease ;
    end
end
res = [];
for i = 1:10
    temp = zeros(1,100)+i;
    res = cat(2,res,temp);
end
diseasetypetest=res;

%uisave ('dataset','dataset')
uisave({'datasettest','diseasetypetest'},'datasettest')



