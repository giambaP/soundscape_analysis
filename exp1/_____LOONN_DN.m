%LEAVE ONE OUT
clc
close all
clear all

%load("PrimoExp_SpectralMfccs.mat");
%mfccs = real(fsMfccsSet);
% %matriceDN = [matriceDN featuresSet];

load("./templatesDN/matriceDN.mat");
%data = real(data);

%we need to delete some audio
data = real(data(1:1430,:));
% n = size(data,1);

labelsDN = labels(:, 1:1430);
% labelsDN = labels;

%labels matrix
% load("training_labelsDN.mat")
% load("testing_labelsDN.mat");
% labelsDN = labels;
% labelsDN = [labelsDN; labels1];



%name of features
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
nomefs{12} = 'SpectralMfccs';

for st = 0:1
    %LOO with all the features
    features = 1:(176*11);
    [err] = LOONNErr(data,features,labelsDN,st);
    fprintf('Leave One Out (NO MFCCS) error: %.4f\n',err)
    
    %LOO with averaged features
    for j = 1:1430
        for i = 0:10
            featuresMean(j, i+1) = mean(data(j, (176*i+1):(176*(i+1))));
        end
    end
    [err] = LOONNErr(featuresMean,[1:11],labelsDN,st);
    fprintf('Leave One Out Averaged features error: %.4f\n\n',err)
    
    %LOO with spectral features
    features = [1:176,(176*2+1):(176*3),(176*4+1):(176*7)];
    [err] = LOONNErr(data,features,labelsDN,st);
    fprintf('Leave One Out SPECTRAL features error: %.4f\n',err)
    
    %LOO with averaged SPECTRAL features
    features = [1,3,5,6,7];
    [err] = LOONNErr(featuresMean,features,labelsDN,st);
    fprintf('Leave One Out Averaged SPECTRAL features error: %.4f\n\n',err)
    
    %LOO with tonaless features
    features = [(176+1):(176*2),(176*3+1):(176*4),(176*7+1):(176*8)];
    [err] = LOONNErr(data,features,labelsDN,st);
    fprintf('Leave One Out TONALESS features error: %.4f\n',err)
    
    %LOO with averaged tonaless features
    features = [2, 4, 8];
    [err] = LOONNErr(featuresMean,features,labelsDN,st);
    fprintf('Leave One Out Averaged TONALESS features error: %.4f\n\n',err)
    
    % LOO with time features
    features = (176*8+1):(176*11);
    [err] = LOONNErr(data,features,labelsDN,st);
    fprintf('Leave One Out TIME features error: %.4f\n',err)
    
    %LOO with averaged time features
    features = [9,10,11];
    [err] = LOONNErr(featuresMean,features,labelsDN,st);
    fprintf('Leave One Out Averaged TIME features error: %.4f\n\n',err)
    
    fprintf('LOO with every single feature:\n')
    %LOO with every single feature
    for i = 0:10
        features = [(176*i)+1:176*(i+1)];
        [err] = LOONNErr(data,features,labelsDN,st);
        fprintf('Leave One Out %s error: %.4f\n',nomefs{i+1}, err)
    end
    
    % LOO with mfccs
    %features = 1:261008;
    %[err] = LOONNErr(mfccs,features,labelsDN, st);
    %fprintf('Leave One Out mfccs error: %.4f\n',err)
    fprintf('\n');
end