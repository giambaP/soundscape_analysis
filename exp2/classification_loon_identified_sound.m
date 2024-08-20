clc; clear all; close all;

featuresCount = 11;

dirLabels = "labels";
labelsFileName = "audio_data_identified_with_labels.dat";
labelsSubsetFileName = "audio_data_identified_with_labels_subset.dat";
audioDataFileName = "audio_data.mat";

templatesfs0xsDirPath = "templates_fs0Xs";
templatesfs1sDirPath = "templates_fs1s";
dataFileName = "matrixAllFeatures.mat";
dirResult = "result_loonn_identified_sound";

%% function

function results = LOONN(featuresCount, elementsPerFeature, data, labels)
res = executeLOONN(featuresCount, elementsPerFeature, data, labels, 0, 0);
results.resultTypes = [res{:,1}]';
results.values = [res{:,2}]';
results.isStandardized = [res{:,3}]';
end

function data = extractDataFromAudioName(dataAll, uniqueNameColumnDataMtx, uniqueName)
uniqueNameSubset = convertCharsToStrings(uniqueName);
audioIdxs = ismember(uniqueNameColumnDataMtx, uniqueNameSubset) == 1;
idxs = audioIdxs > 0;
data = dataAll(idxs, :);
end

function [data, labels] = extractDataAndLabels(dataAll, uniqueNameColumnDataMtx, uniqueName, labelSubset)
rightLabelIndexes = find(labelSubset > 0);
labels = labelSubset(rightLabelIndexes,:);
uniqueNameSubset = uniqueName(rightLabelIndexes, :);
data = extractDataFromAudioName(dataAll, uniqueNameColumnDataMtx, uniqueNameSubset);
end

%% preparing

if ~exist(dirResult, 'dir'); mkdir(dirResult); end

audioDataMtx = load(sprintf("./%s/%s", dirLabels, audioDataFileName));
audioData = audioDataMtx.audioData;
uniqueNameColumnData = audioData(:, AudioDataColumnIndex.UniqueName.index);
uniqueNameColumnDataMtx = [uniqueNameColumnData{:}]';

%% LOONN with all rows

% retrieving labels identified sounds (186 audio)
dataSounds = readtable(sprintf("%s/%s", dirLabels, labelsFileName));
uniqueName = dataSounds.uniqueName;
labelsVehicle = dataSounds.vehicle;
labelBirds = dataSounds.birds;
labelsCrickets = dataSounds.crickets;
labelsRiverWaterfall = dataSounds.river_waterfall;
labelsRain = dataSounds.rain;
labelsThunder = dataSounds.thunder;
labelsNoise = dataSounds.noise;
labelsUnknown = dataSounds.unknown;

% retrieving labels identified sounds (same size, but subset of values, excluded has -1)
dataSoundsSubset = readtable(sprintf("%s/%s", dirLabels, labelsSubsetFileName));
uniqueNameSubset = dataSoundsSubset.uniqueName;
labelVehicleRain = dataSoundsSubset.labelVehicleRain;
labelVehicleCrickets = dataSoundsSubset.labelVehicleCrickets;
labelCricketsThunder = dataSoundsSubset.labelCricketsThunder;
labelCricketsRain = dataSoundsSubset.labelCricketsRain;
labelVehicleCricketsRain = dataSoundsSubset.labelSubsetVehicleCricketsRain;
labelVehicleCricketsThunder = dataSoundsSubset.labelSubsetVehicleCricketsThunder;

% fs 0Xs
mtx = load(sprintf("./%s/%s", templatesfs0xsDirPath, dataFileName));
elementsPerFeature = 176;
fprintf("> LOONN fs0X: start\n");
% one to one
data = extractDataFromAudioName(mtx.data, uniqueNameColumnDataMtx, uniqueName);
fs0xRes.resultsVehicle = LOONN(featuresCount, elementsPerFeature, data, labelsVehicle);
fs0xRes.resultsBirds = LOONN(featuresCount, elementsPerFeature, data, labelBirds);
fs0xRes.resultsCrickets = LOONN(featuresCount, elementsPerFeature, data, labelsCrickets);
fs0xRes.resultsRiverWaterfall = LOONN(featuresCount, elementsPerFeature, data, labelsRiverWaterfall);
fs0xRes.resultsRain = LOONN(featuresCount, elementsPerFeature, data, labelsRain);
fs0xRes.resultsThunder = LOONN(featuresCount, elementsPerFeature, data, labelsThunder);
fs0xRes.resultsNoise = LOONN(featuresCount, elementsPerFeature, data, labelsNoise);
fs0xRes.resultsUnknown = LOONN(featuresCount, elementsPerFeature, data, labelsUnknown);
% binary
[dataSubSet, labelsSubset] = extractDataAndLabels(mtx.data, uniqueNameColumnDataMtx, uniqueNameSubset, labelVehicleRain);
fs0xRes.resultVehicleRain = LOONN(featuresCount, elementsPerFeature, dataSubSet, labelsSubset);
[dataSubSet, labelsSubset] = extractDataAndLabels(mtx.data, uniqueNameColumnDataMtx, uniqueNameSubset, labelVehicleCrickets);
fs0xRes.resultVehicleCrickets = LOONN(featuresCount, elementsPerFeature, dataSubSet, labelsSubset);
[dataSubSet, labelsSubset] = extractDataAndLabels(mtx.data, uniqueNameColumnDataMtx, uniqueNameSubset, labelCricketsThunder);
fs0xRes.resultCricketsThunder = LOONN(featuresCount, elementsPerFeature, dataSubSet, labelsSubset);
[dataSubSet, labelsSubset] = extractDataAndLabels(mtx.data, uniqueNameColumnDataMtx, uniqueNameSubset, labelCricketsRain);
fs0xRes.resultCricketsRain = LOONN(featuresCount, elementsPerFeature, dataSubSet, labelsSubset);
% tertiary
[dataSubSet, labelsSubset] = extractDataAndLabels(mtx.data, uniqueNameColumnDataMtx, uniqueNameSubset, labelVehicleCricketsRain);
fs0xRes.resultSubsetVehicleCricketsRain = LOONN(featuresCount, elementsPerFeature, dataSubSet, labelsSubset);
[dataSubSet, labelsSubset] = extractDataAndLabels(mtx.data, uniqueNameColumnDataMtx, uniqueNameSubset, labelVehicleCricketsThunder);
fs0xRes.resultSubsetVehicleCricketsThunder = LOONN(featuresCount, elementsPerFeature, dataSubSet, labelsSubset);
fprintf("> LOONN fs0Xs: end\n\n");

% fs 1s
mtx = load(sprintf("./%s/%s", templatesfs1sDirPath, dataFileName));
data = extractDataFromAudioName(mtx.data, uniqueNameColumnDataMtx, uniqueName);
elementsPerFeature = 120;
fprintf("> LOONN fs1: start\n");
% one to one
fs1sRes.resultsVehicle = LOONN(featuresCount, elementsPerFeature, data, labelsVehicle);
fs1sRes.resultsBirds = LOONN(featuresCount, elementsPerFeature, data, labelBirds);
fs1sRes.resultsCrickets = LOONN(featuresCount, elementsPerFeature, data, labelsCrickets);
fs1sRes.resultsRiverWaterfall = LOONN(featuresCount, elementsPerFeature, data, labelsRiverWaterfall);
fs1sRes.resultsRain = LOONN(featuresCount, elementsPerFeature, data, labelsRain);
fs1sRes.resultsThunder = LOONN(featuresCount, elementsPerFeature, data, labelsThunder);
fs1sRes.resultsNoise = LOONN(featuresCount, elementsPerFeature, data, labelsNoise);
fs1sRes.resultsUnknown = LOONN(featuresCount, elementsPerFeature, data, labelsUnknown);
% binary
[dataSubSet, labelsSubset] = extractDataAndLabels(mtx.data, uniqueNameColumnDataMtx, uniqueNameSubset, labelVehicleRain);
fs1sRes.resultVehicleRain = LOONN(featuresCount, elementsPerFeature, dataSubSet, labelsSubset);
[dataSubSet, labelsSubset] = extractDataAndLabels(mtx.data, uniqueNameColumnDataMtx, uniqueNameSubset, labelVehicleCrickets);
fs1sRes.resultVehicleCrickets = LOONN(featuresCount, elementsPerFeature, dataSubSet, labelsSubset);
[dataSubSet, labelsSubset] = extractDataAndLabels(mtx.data, uniqueNameColumnDataMtx, uniqueNameSubset, labelCricketsThunder);
fs1sRes.resultCricketsThunder = LOONN(featuresCount, elementsPerFeature, dataSubSet, labelsSubset);
[dataSubSet, labelsSubset] = extractDataAndLabels(mtx.data, uniqueNameColumnDataMtx, uniqueNameSubset, labelCricketsRain);
fs1sRes.resultCricketsRain = LOONN(featuresCount, elementsPerFeature, dataSubSet, labelsSubset);
% tertiary
[dataSubSet, labelsSubset] = extractDataAndLabels(mtx.data, uniqueNameColumnDataMtx, uniqueNameSubset, labelVehicleCricketsRain);
fs1sRes.resultSubsetVehicleCricketsRain = LOONN(featuresCount, elementsPerFeature, dataSubSet, labelsSubset);
[dataSubSet, labelsSubset] = extractDataAndLabels(mtx.data, uniqueNameColumnDataMtx, uniqueNameSubset, labelVehicleCricketsThunder);
fs1sRes.resultSubsetVehicleCricketsThunder = LOONN(featuresCount, elementsPerFeature, dataSubSet, labelsSubset);
fprintf("> LOONN fs1: end\n\n");


% RESULTS TABLE ONE vs ONE
resultType = fs0xRes.resultsVehicle.resultTypes;
headers = {'CheckType', ...
    'Vehicle', 'Vehicle STD', ...
    'Crickets', 'Crickets STD', ...
    'Rain', 'Rain STD', ...
    'Thunder', 'Thunder STD', ...
    'VehicleRain', 'VehicleRain STD', ...
    'VehicleCrickets', 'VehicleCrickets STD', ...
    'CricketsThunder', 'CricketsThunder STD', ...
    'CricketsRain', 'CricketsRain STD', ...
    'VehicleCricketsRain', 'VehicleCricketsRain STD', ...
    'VehicleCricketsThunder', 'VehicleCricketsThunder STD'
    };

normal = 1:19;
std = 20:38;

fprintf("> CHECKS LOONN all features, fs 0Xs\n\n");
t = table(resultType(normal, 1), ...
    fs0xRes.resultsVehicle.values(normal, 1), ...
    fs0xRes.resultsVehicle.values(std, 1), ...
    fs0xRes.resultsCrickets.values(normal, 1), ...
    fs0xRes.resultsCrickets.values(std, 1), ...
    fs0xRes.resultsRain.values(normal, 1), ...
    fs0xRes.resultsRain.values(std, 1), ...
    fs0xRes.resultsThunder.values(normal, 1), ...
    fs0xRes.resultsThunder.values(std, 1), ...
    fs0xRes.resultVehicleRain.values(normal, 1), ...
    fs0xRes.resultVehicleRain.values(std, 1), ...
    fs0xRes.resultVehicleCrickets.values(normal, 1), ...
    fs0xRes.resultVehicleCrickets.values(std, 1), ...
    fs0xRes.resultCricketsThunder.values(normal, 1), ...
    fs0xRes.resultCricketsThunder.values(std, 1), ...
    fs0xRes.resultCricketsRain.values(normal, 1), ...
    fs0xRes.resultCricketsRain.values(std, 1), ...
    fs0xRes.resultSubsetVehicleCricketsRain.values(normal, 1), ...
    fs0xRes.resultSubsetVehicleCricketsRain.values(std, 1), ...
    fs0xRes.resultSubsetVehicleCricketsThunder.values(normal, 1), ...
    fs0xRes.resultSubsetVehicleCricketsThunder.values(std, 1), ...
    'VariableNames', headers ...
    );
disp(t);
writetable(t, sprintf("%s/loon_identified_sound_fs0x.csv", dirResult));

fprintf("> CHECKS LOONN all features, fs 1s\n\n");
t = table(resultType(normal, 1), ...
    fs1sRes.resultsVehicle.values(normal, 1), ...
    fs1sRes.resultsVehicle.values(std, 1), ...
    fs1sRes.resultsCrickets.values(normal, 1), ...
    fs1sRes.resultsCrickets.values(std, 1), ...
    fs1sRes.resultsRain.values(normal, 1), ...
    fs1sRes.resultsRain.values(std, 1), ...
    fs1sRes.resultsThunder.values(normal, 1), ...
    fs1sRes.resultsThunder.values(std, 1), ...
    fs1sRes.resultVehicleRain.values(normal, 1), ...
    fs1sRes.resultVehicleRain.values(std, 1), ...
    fs1sRes.resultVehicleCrickets.values(normal, 1), ...
    fs1sRes.resultVehicleCrickets.values(std, 1), ...
    fs1sRes.resultCricketsThunder.values(normal, 1), ...
    fs1sRes.resultCricketsThunder.values(std, 1), ...
    fs1sRes.resultCricketsRain.values(normal, 1), ...
    fs1sRes.resultCricketsRain.values(std, 1), ...
    fs1sRes.resultSubsetVehicleCricketsRain.values(normal, 1), ...
    fs1sRes.resultSubsetVehicleCricketsRain.values(std, 1), ...
    fs1sRes.resultSubsetVehicleCricketsThunder.values(normal, 1), ...
    fs1sRes.resultSubsetVehicleCricketsThunder.values(std, 1), ...
    'VariableNames', headers ...
    );
disp(t);
writetable(t, sprintf("%s/loon_identified_sound_fs1.csv", dirResult));


