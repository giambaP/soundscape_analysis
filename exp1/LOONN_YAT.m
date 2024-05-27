%LEAVE ONE OUT
clc
close all
clear all

nomefs{1} = 'SpectralCentroid';
nomefs{2} = 'SpectralCrestFactor';
nomefs{3} = 'SpectralDecrease';
nomefs{4} = 'SpectralFlatness';
nomefs{5} = 'SpectralFlux';
nomefs{6} = 'SpectralRolloff';
nomefs{7} = 'SpectralSpread';
nomefs{8} = 'SpectralTonalPowerRatio';
nomefs{9} = 'TimeZeroCrossingRate';
nomefs{10} = 'TimeAcfCoeff';
nomefs{11} = 'TimeMaxAcf';

%load features;
load("./templatesYAT/matriceYAT.mat");
%load("./templatesYAT/PrimoExp_SpectralMfccs.mat");

for st = 0:1
%LOO with all the features(no Mfccs)
[err] = LOONNErr(data,[1:(176*11)],labels,st);
fprintf('Leave One Out error (no Mfccs) : %.4f\n',err);

%LOO with spectral features
features = [1:176,(176*2+1):(176*3),(176*4+1):(176*7)];
[err] = LOONNErr(data,features,labels,st);
fprintf('Leave One Out SPECTRAL features error: %.4f\n',err);

%LOO with tonaless features
features = [(176+1):(176*2),(176*3+1):(176*4),(176*7+1):(176*8)];
[err] = LOONNErr(data,features,labels,st);
fprintf('Leave One Out TONALESS features error: %.4f\n',err);

% LOO with time features
features = [(176*8+1):(176*11)];
[err] = LOONNErr(data,features,labels,st);
fprintf('Leave One Out TIME features error: %.4f\n',err);

% LOO with mfccs
%features = [1:97856];
%[err] = LOONNErr(MfccsSet,features,labels);
%fprintf('Leave One Out Mfccs error: %.4f\n',err)

% Averaged features
for j = 1 : 556
    for i = 0 : 10
        FeaturesMean(j, i+1) = mean(data(j, (176*i+1):(176*(i+1))));
    end
end

%LOO with all the mean of the features(no Mfccs)
[err] = LOONNErr(FeaturesMean,[1:11],labels,st);
fprintf('Leave One Out mean features error (no Mfccs) : %.4f\n',err);

%LOO with the mean of spectral features
features = [1,3,5,6,7];
[err] = LOONNErr(FeaturesMean,features,labels,st);
fprintf('Leave One Out mean SPECTRAL features error: %.4f\n',err);

%LOO with tonaless features
features = [2,4,8];
[err] = LOONNErr(FeaturesMean,features,labels,st);
fprintf('Leave One Out mean TONALESS features error: %.4f\n',err);

% LOO with time features
features = [9, 10, 11];
[err] = LOONNErr(FeaturesMean,features,labels,st);
fprintf('Leave One Out mean TIME features error: %.4f\n',err);

%LOO single feature
for i = 0 : 10
    features = [(176*i+1):(176*(i+1))];
    [err] = LOONNErr(data, features, labels,st);
    fprintf('Leave One Out %s : %.4f\n', nomefs{i+1}, err);
end
end
