%LOONN
clc; close all; clear all;

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
% Mfccs excluded

load("./templatesYAT/matriceYAT.mat");

objsCount = size(data, 1);
featuresCount = 11;
featSize = 176; % elements defining each feature
allFeaturesIdxs = 1:(featSize*11);

spectralCentroidIdxs = 1:featSize;
spectralCrestFactorIdxs = (featSize*1+1):(featSize*2);
spectralDecreaseIdxs = (featSize*2+1):(featSize*3);
spectralFlatnessIdxs = (featSize*3+1):(featSize*4);
spectralFluxIdxs = (featSize*4+1):(featSize*5);
spectralRolloffIdxs = (featSize*5+1):(featSize*6);
spectralSpreadIdxs = (featSize*6+1):(featSize*7);
spectralTonalPowerRatioIdxs = (featSize*7+1):(featSize*8);
timeZeroCrossingRateIdxs = (featSize*8+1):(featSize*9);
timeAcfCoeffIdxs = (featSize*9+1):(featSize*10);
timeMaxAcfIdxs = (featSize*10+1):(featSize*11);

featuresSpectralIdxs = [spectralCentroidIdxs, spectralDecreaseIdxs, spectralFluxIdxs, spectralRolloffIdxs, spectralSpreadIdxs];
featuresTonalessIdxs = [spectralCrestFactorIdxs, spectralFlatnessIdxs, spectralTonalPowerRatioIdxs];
featuresTimeIdxs = [timeZeroCrossingRateIdxs, timeAcfCoeffIdxs, timeMaxAcfIdxs];

% average features
featuresMean = zeros(objsCount, 11);
for j = 1 : objsCount
    for i = 0 : (featuresCount-1)
        featuresMean(j, i+1) = mean(data(j, (featSize*i+1):(featSize*(i+1))));
    end
end
featuresAvgSpectralIdxs = [1, 3, 5, 6, 7];
featuresAvgTonalessIdxs = [2, 4, 8];
featuresAvgTimeIdxs = [9, 10, 11];

% 19 calc * 2: orig and std
results = cell(19*2, 2); 

for st = 0:1
    % LOONN all features
    [err] = LOONNErr(data, allFeaturesIdxs, labels, st);
    results(1 + st*19, :) = {"LOONNErr conc feat all", err};
    
    % LOONN spectral features
    [err] = LOONNErr(data, featuresSpectralIdxs, labels, st);
    results(2 + st*19, :) = {"LOONNErr conc feat spectral", err};

    % LOONN tonaless features
    [err] = LOONNErr(data, featuresTonalessIdxs, labels, st);
    results(3 + st*19, :) = {"LOONNErr conc feat tonaless", err};

    % LOONN time features    
    [err] = LOONNErr(data, featuresTimeIdxs, labels, st);
    results(4 + st*19, :) = {"LOONNErr conc feat time", err};

    % LOONN all mean features 
    [err] = LOONNErr(featuresMean, 1:(featuresCount), labels, st);
    results(5 + st*19, :) = {"LOONNErr conc avg feat all", err};

    % LOONN mean of spectral features
    [err] = LOONNErr(featuresMean, featuresAvgSpectralIdxs, labels, st);
    results(6 + st*19, :) = {"LOONNErr conc avg feat spectral", err};

    % LOONN mean of tonaless features
    [err] = LOONNErr(featuresMean, featuresAvgTonalessIdxs, labels, st);
    results(7 + st*19, :) = {"LOONNErr conc avg feat tonaless", err};

    % LOONN mean of time features
    [err] = LOONNErr(featuresMean, featuresAvgTimeIdxs,labels, st);
    results(8 + st*19, :) = {"LOONNErr conc avg feat time", err};

    % LOONN single feature
    for i = 0 : (featuresCount-1)
        features = (featSize*i+1):(featSize*(i+1));
        [err] = LOONNErr(data, features, labels, st);
        results(9 + i + st*19, :) = {sprintf("LOONNErr feat %s", nomefs{i+1}), err};
    end
end

for i=1:size(results,1)
    id = results{i,1};
    err = results{i,2};
    fprintf("%2d. %-38s -> %.4f\n", i, id, err);
end


