close all
clear all
clc
%%
%  Select an image from the 'Disease Dataset' folder by opening the folder
[filename,pathname] = uigetfile({'*.*';'*.bmp';'*.tif';'*.gif';'*.png'},'Pick a Leaf Image');
I = imread([pathname,filename]);

%%
figure, imshow(I);title('leaf Image');

 image = imresize(I, [384 256]);
 
      image=image;   
if size(image,3) == 3
   img = rgb2gray(image);
end
figure, imshow(img);title('Grayscale Image');
img = adapthisteq(img,'clipLimit',0.02,'Distribution','rayleigh');
figure, imshow(img);title('Adaptive Histogram Image');
%%
% Create the Gray Level Cooccurance Matrices (GLCMs)
glcms = graycomatrix(img);

%Evaluate 13 features from the disease affected region only
% Derive Statistics from GLCM
stats = graycoprops(glcms,'Contrast Correlation Energy Homogeneity');
Contrast = stats.Contrast;
Correlation = stats.Correlation;
Energy = stats.Energy;
Homogeneity = stats.Homogeneity;
Mean = mean2(image);
Standard_Deviation = std2(image);
Entropy = entropy(image);
RMS = mean2(rms(image));
%Skewness = skewness(img)
Variance = mean2(var(double(image)));
a = sum(double(image(:)));
Smoothness = 1-(1/(1+a));
Kurtosis = kurtosis(double(image(:)));
Skewness = skewness(double(image(:)));

m = size(image,1);
n = size(image,2);
in_diff = 0;
for i = 1:m
    for j = 1:n
        temp = image(i,j)./(1+(i-j).^2);
        in_diff = in_diff+temp;
    end
end
IDM = double(in_diff);
% Put the 13 features in an array
 pred_feature= [Contrast,Correlation,Energy,Homogeneity, Mean, Standard_Deviation, Entropy, RMS, Variance, Smoothness, Kurtosis, Skewness, IDM];

load(fullfile("D:\FINAL YEAR PROJECT\lab project\LEAF-DISEASE-DETECTION\datasettest.mat"));
load(fullfile("D:\FINAL YEAR PROJECT\lab project\LEAF-DISEASE-DETECTION\datasettrain.mat"));

X_train = datasettrain;
Y_train = diseasetypetrain;
X_test = datasettest;
Y_test = diseasetypetest;

% Define the random forest parameters
numTrees = 50; % Number of decision trees in the forest
options = statset('UseParallel',true); % Enable parallel processing

% Train the random forest classifier
RF = TreeBagger(numTrees, X_train, Y_train, 'Options', options);

% Make predictions on the test set
Y_pred = RF.predict(X_test);

% Evaluate the performance of the classifier
predicted = zeros(1,1000);
total = 0;
for i = 1:1000
    predicted(i)=str2num(cell2mat(Y_pred(i)));
    total= total + (str2num(cell2mat((Y_pred(i))))==Y_test(i));
end

confusionmatrix = confusionmat(predicted,Y_test);
    
accuracy = total/length(Y_test); % Calculate the accuracy
fprintf('Accuracy = %.2f%%\n\n', accuracy*100);
result = str2num(cell2mat(RF.predict(pred_feature)));
switch result
    case 1
        disp(['1- The disease detected is Bacterial spot,caused by Xanthomonas bacteria', newline ,'It can be treated with copper-based bactericides or through crop rotation and other cultural practices.'])
    case 2
        disp(['2- The disease detected is Early Blight caused by the fungus Alternaria solani.', newline,'It can be treated with fungicides, proper spacing and pruning, and the removal of infected plant parts to prevent spread.'])
    case 3
        disp('3- The leaf is normal, Do not worry farmer, Your leaf is not infected')
    case 4
        disp(['4- The disease detected is Late Blight caused by the fungus Phytophthora infestans.', newline,'It can be treated with fungicides, removal of infected plant parts, and implementing cultural practices such as proper plant spacing and avoiding overhead irrigation.'])
    case 5
        disp(['5- The disease detected is Leaf Mold caused by the fungus Fulvia fulva (formerly Cladosporium fulvum).', newline,'It can be treated with fungicides, good air circulation, avoiding overhead irrigation, and removing infected plant parts.'])
    case 6
        disp(['6- The disease detected is Septoria Leaf Spot caused by the fungus Septoria lycopersici.', newline,'It can be treated with fungicides, good air circulation, avoiding overhead irrigation, and removing infected plant parts.'])
    case 7
        disp(['7- The Disease detected is Two spotted spider mite.', newline,'It can be controlled by introducing predatory mites or other natural enemies, using insecticidal soaps or oils, or applying miticides.'])
    case 8
        disp(['8- The Disease detected is Target Spot caused by the fungus Corynespora cassiicola.', newline,'It can be treated with fungicides, good air circulation, avoiding overhead irrigation, and removing infected plant parts.'])
    case 9
        disp(['9- The Disease detected by Tomato mosaic Virus that can cause mottled or distorted leaves,stunted growth.', newline,'It can be managed by using virus-resistant cultivars, controlling insect vectors, and avoiding mechanical transmission through contaminated tools or hands.'])
    case 10
        disp(['10- The Disease detected by Tomato yellow leaf curl Virus is a plant virus that is transmitted by the whitefly Bemisia tabaci and can cause yellowing, curling, and stunting of tomato plants,', newline,'It can be managed by using virus-resistant cultivars, controlling whitefly populations, and avoiding mechanical transmission through contaminated tools or hands.'])
end

confusion=confusionmatrix;
tp = [];
fp = [];
fn = [];
tn = [];
len = size(confusion, 1);
for k = 1:len                  %  predict
    % True positives           % | x o o |
    tp_value = confusion(k,k); % | o o o | true
    tp = [tp, tp_value];       % | o o o |
                                               %  predict
    % False positives                          % | o o o |
    fp_value = sum(confusion(:,k)) - tp_value; % | x o o | true
    fp = [fp, fp_value];                       % | x o o |
                                               %  predict
    % False negatives                          % | o x x |
    fn_value = sum(confusion(k,:)) - tp_value; % | o o o | true
    fn = [fn, fn_value];                       % | o o o |
                                                                       %  predict
    % True negatives (all the rest)                                    % | o o o |
    tn_value = sum(sum(confusion)) - (tp_value + fp_value + fn_value); % | o x x | true
    tn = [tn, tn_value];                                               % | o x x |
end
% Statistics of interest for confusion matrix
prec = tp ./ (tp + fp); % precision
sens = tp ./ (tp + fn); % sensitivity, recall
spec = tn ./ (tn + fp); % specificity
acc = sum(tp) ./ sum(sum(confusion));
f1 = (2 .* prec .* sens) ./ (prec + sens);
% For micro-average
microprec = sum(tp) ./ (sum(tp) + sum(fp)); % precision
microsens = sum(tp) ./ (sum(tp) + sum(fn)); % sensitivity, recall
microspec = sum(tn) ./ (sum(tn) + sum(fp)); % specificity
microacc = acc;
microf1 = (2 .* microprec .* microsens) ./ (microprec + microsens);
% Names of the rows
name = ["true_positive"; "false_positive"; "false_negative"; "true_negative"; ...
    "precision"; "sensitivity"; "specificity"; "accuracy"; "F-measure"];
% Names of the columns
varNames = ["name"; "classes"; "macroAVG"; "microAVG"];
% Values of the columns for each class
values = [tp; fp; fn; tn; prec; sens; spec; repmat(acc, 1, len); f1];
% Macro-average
macroAVG = mean(values, 2);
% Micro-average
microAVG = [macroAVG(1:4); microprec; microsens; microspec; microacc; microf1];
% OUTPUT: final table
stats = table(name, values, macroAVG, microAVG, 'VariableNames',varNames);

