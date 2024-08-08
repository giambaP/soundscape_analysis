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

%% FUNCTION

function results = LOONN(featuresCount, elementsPerFeature, data, labels)
res = executeLOONN(featuresCount, elementsPerFeature, data, labels, 0, 0);
results.resultTypes = [res{:,1}]';
results.values = [res{:,2}]';
results.isStandardized = [res{:,3}]';
end

function data = extractDataFromAudioName(dataAll, uniqueNameColumnDataMtx, uniqueName)    
uniqueNameSubset = convertCharsToStrings(uniqueName);
audioIdxs = ismember(uniqueNameColumnDataMtx, uniqueNameSubset) == 1;
data = dataAll(audioIdxs, :);
end

function [data, labels] = extractDataAndLabels(dataAll, uniqueNameColumnDataMtx, uniqueName, labelsAll)
    [indexes, labels] = find(labelsAll > 0);
    uniqueNameSubset = uniqueName(indexes, :);
    data = extractDataFromAudioName(dataAll, uniqueNameColumnDataMtx, uniqueNameSubset);
end

%% PREPARING

if ~exist(dirResult, 'dir'); mkdir(dirResult); end

%% preparing

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
labelSubsetVehicleCricketsRain = dataSoundsSubset.labelSubsetVehicleCricketsRain;
labelSubsetVehicleCricketsThunder = dataSoundsSubset.labelSubsetVehicleCricketsThunder;

% fs 0Xs 
mtx = load(sprintf("./%s/%s", templatesfs0xsDirPath, dataFileName));
data = extractDataFromAudioName(mtx.data, uniqueNameColumnDataMtx, uniqueName);
elementsPerFeature = 176;
fprintf("> LOONN fs0X: start\n");
% one to one
fs0xRes.resultsVehicle = LOONN(featuresCount, elementsPerFeature, data, labelsVehicle);
fs0xRes.resultsBirds = LOONN(featuresCount, elementsPerFeature, data, labelBirds);
fs0xRes.resultsCrickets = LOONN(featuresCount, elementsPerFeature, data, labelsCrickets);
fs0xRes.resultsRiverWaterfall = LOONN(featuresCount, elementsPerFeature, data, labelsRiverWaterfall);
fs0xRes.resultsRain = LOONN(featuresCount, elementsPerFeature, data, labelsRain);
fs0xRes.resultsThunder = LOONN(featuresCount, elementsPerFeature, data, labelsThunder);
fs0xRes.resultsNoise = LOONN(featuresCount, elementsPerFeature, data, labelsNoise);
fs0xRes.resultsUnknown = LOONN(featuresCount, elementsPerFeature, data, labelsUnknown);
% binary

[dataSubSet, labelsSubset] = extractDataAndLabels(data, uniqueNameColumnDataMtx, uniqueNameSubset, labelSubsetVehicleCricketsRain);
fs0xRes.labelSubsetVehicleCricketsRain = LOONN(featuresCount, elementsPerFeature, dataSubset, labelSubsetVehicleCricketsRain);
% tertiary
fprintf("> LOONN fs0Xs: end\n\n");

% fs 1s 
mtx = load(sprintf("./%s/%s", templatesfs1sDirPath, dataFileName));
data = mtx.data(audioIdxs, :);
dataSubset = mtx.data(audioSubsetIdxs, :);
elementsPerFeature = 120;
fprintf("> LOONN fs1: start\n");
fs1sRes.resultsVehicle = LOONN(featuresCount, elementsPerFeature, data, labelsVehicle);
fs1sRes.resultsBirds = LOONN(featuresCount, elementsPerFeature, data, labelBirds);
fs1sRes.resultsCrickets = LOONN(featuresCount, elementsPerFeature, data, labelsCrickets);
fs1sRes.resultsRiverWaterfall = LOONN(featuresCount, elementsPerFeature, data, labelsRiverWaterfall);
fs1sRes.resultsRain = LOONN(featuresCount, elementsPerFeature, data, labelsRain);
fs1sRes.resultsThunder = LOONN(featuresCount, elementsPerFeature, data, labelsThunder);
fs1sRes.resultsNoise = LOONN(featuresCount, elementsPerFeature, data, labelsNoise);
fs1sRes.resultsUnknown = LOONN(featuresCount, elementsPerFeature, data, labelsUnknown);
fs1sRes.labelSubsetVehicleCricketsRain = LOONN(featuresCount, elementsPerFeature, dataSubset, labelSubsetVehicleCricketsRain);
fprintf("> LOONN fs1: end\n\n");


% RESULTS TABLE
resultType = fs0xRes.resultsVehicle.resultTypes;
headers = {'CheckType', ... 
    'Vehicle', 'Vehicle STD', ...
    'Crickets', 'Crickets STD', ... 
    'Rain', 'Rain STD', ...
    'Thunder', 'Thunder STD', ...
    'Vehicle_Crickets_Rain', 'Vehicle_Crickets_Rain STD' 
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
    fs0xRes.labelSubsetVehicleCricketsRain.values(normal, 1), ...
    fs0xRes.labelSubsetVehicleCricketsRain.values(std, 1), ...
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
    fs0xRes.labelSubsetVehicleCricketsRain.values(normal, 1), ...
    fs0xRes.labelSubsetVehicleCricketsRain.values(std, 1), ...
    'VariableNames', headers ...
    );
disp(t);
writetable(t, sprintf("%s/loon_identified_sound_fs1.csv", dirResult));


