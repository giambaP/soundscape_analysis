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

matrixDataName = "matrixAllFeatures.mat";
matrixLabelsName = "labelsYAT.mat";

load(sprintf("./templates/%s", matrixDataName));
fprintf("loaded audio data from '%s'\n", matrixDataName);
load(sprintf("./templates/%s", matrixLabelsName));
fprintf("loaded labels data from '%s'\n", matrixLabelsName);

%% filtering exp1 data

% TEST PASSED SUCCESFULLY - ALL DATA ARE CORRECT

% audioData structure
uniqueNameColumn = 1;
audioNameColumn = 2;
audioNameNoExtensionColumn = 3;
yatColumn = 4;
yearColumn = 5;
monthColumn = 6;
dayColumn = 7;
hourColumn = 8;
minuteColumn = 9;

load("./templates/audio_data.mat");
% labels yat exp1: only all yats, march for 2,6,10,14,18,22 hours

monthColumnData = cell2mat(audioData(:, monthColumn));
monthFilters = monthColumnData == 3;
rangeMonthIndx = find(monthFilters);

hoursColumnData = cell2mat(audioData(:, hourColumn));
hourValues = [2, 6, 10, 14, 18, 22];
hourFilters = ismember(hoursColumnData, hourValues);
rangeHoursIndx = find(hourFilters);

minuteColumnData = cell2mat(audioData(:, minuteColumn));
minuteFilters = minuteColumnData == 0;
rangeMinutesIndx = find(minuteFilters);

rangeIdx = intersect(rangeMonthIndx, rangeHoursIndx);
rangeIdx = intersect(rangeIdx, rangeMinutesIndx);
% filtering data
data = data(rangeIdx, :);
labels = labelsYAT(rangeIdx);

%%

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
fprintf("> mean completed\n");

featuresAvgSpectralIdxs = [1, 3, 5, 6, 7];
featuresAvgTonalessIdxs = [2, 4, 8];
featuresAvgTimeIdxs = [9, 10, 11];


% 19 calc * 2: orig and std -> label, error, standardization on/off
results = cell(19*2, 3); 

for st = 0:1
    % LOONN all features
    fprintf("> conc feat all: start\n");
    [err] = LOONNErr(data, allFeaturesIdxs, labels, st);
    results(1 + st*19, :) = {"conc feat all", err, st}; 
    fprintf("> conc feat all: end\n");
    
    % LOONN spectral features
    fprintf("> conc feat spectral: start\n"); 
    [err] = LOONNErr(data, featuresSpectralIdxs, labels, st);
    results(2 + st*19, :) = {"conc feat spectral", err, st}; 
    fprintf("> conc feat spectral: end\n");

    % LOONN tonaless features
    [err] = LOONNErr(data, featuresTonalessIdxs, labels, st);
    results(3 + st*19, :) = {"conc feat tonaless", err, st}; 
    fprintf("> conc feat tonaless: start\n"); 
    fprintf("> conc feat tonaless: end\n");

    % LOONN time features    
    fprintf("> conc feat time: start\n"); 
    [err] = LOONNErr(data, featuresTimeIdxs, labels, st);
    results(4 + st*19, :) = {"conc feat time", err, st}; 
    fprintf("> conc feat time: end\n");

    % LOONN all mean features 
    fprintf("> conc avg feat all: start\n"); 
    [err] = LOONNErr(featuresMean, 1:(featuresCount), labels, st);
    results(5 + st*19, :) = {"conc avg feat all", err, st}; 
    fprintf("> conc avg feat all: end\n");

    % LOONN mean of spectral features
    fprintf("> conc avg feat spectral: start\n"); 
    [err] = LOONNErr(featuresMean, featuresAvgSpectralIdxs, labels, st);
    results(6 + st*19, :) = {"conc avg feat spectral", err, st}; 
    fprintf("> conc avg feat spectral: end\n");

    % LOONN mean of tonaless features
    fprintf("> conc avg feat tonaless: start\n"); 
    [err] = LOONNErr(featuresMean, featuresAvgTonalessIdxs, labels, st);
    results(7 + st*19, :) = {"conc avg feat tonaless", err, st}; 
    fprintf("> conc avg feat tonaless: end\n");

    % LOONN mean of time features
    fprintf("> conc avg feat time: start\n"); 
    [err] = LOONNErr(featuresMean, featuresAvgTimeIdxs,labels, st);
    results(8 + st*19, :) = {"conc avg feat time", err, st}; 
    fprintf("> conc avg feat time: end\n");

    % LOONN single feature
    fprintf("> conc feat all: start\n"); 
    for i = 0 : (featuresCount-1)
        features = (featSize*i+1):(featSize*(i+1));
        [err] = LOONNErr(data, features, labels, st);
        results(9 + i + st*19, :) = {sprintf("feat %s", nomefs{i+1}), err, st};
    end
    fprintf("> conc feat all: end\n");
end

for i=1:size(results,1)
    id = results{i,1};
    err = results{i,2};
    st = results{i,3};
    if st == 1
        st = "(std) ";
    else 
        st = "";
    end
    id = strcat(st, id);
    fprintf("%2d. LOONNErr %-35s -> %.4f\n", i, id, err);
end

