clc; clear all; close all;

featuresCount = 11;

dirLabels = "labels";
labelsFileName = "audio_data_identified_with_labels.dat";
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

%% LOONN all features

% retrieving labels
dataSounds = readtable(sprintf("%s/%s", dirLabels, labelsFileName));
labelsVehicle = dataSounds.vehicle;
labelBirds = dataSounds.birds;
labelsCrickets = dataSounds.crickets;
labelsRiverWaterfall = dataSounds.river_waterfall;
labelsRain = dataSounds.rain;
labelsThunder = dataSounds.thunder;
labelsNoise = dataSounds.noise;
labelsUnknown = dataSounds.unknown;

% retrieving identified sounds (186 audio)
audioDataMtx = load(sprintf("./%s/%s", dirLabels, audioDataFileName));
audioData = audioDataMtx.audioData;
uniqueNameColumnData = audioData(:, AudioDataColumnIndex.UniqueName.index);
uniqueNameColumnDataMtx = [uniqueNameColumnData{:}]';
uniqueNameSubset = convertCharsToStrings(dataSounds.uniqueName);
audioIdxs = find(ismember(uniqueNameColumnDataMtx, uniqueNameSubset) == 1);

% fs 0Xs 
mtx = load(sprintf("./%s/%s", templatesfs0xsDirPath, dataFileName));
data = mtx.data(audioIdxs, :);
elementsPerFeature = 176;
fprintf("> LOONN fs0X: start\n");
fs0xRes.resultsVehicle = LOONN(featuresCount, elementsPerFeature, data, labelsVehicle);
fs0xRes.resultsBirds = LOONN(featuresCount, elementsPerFeature, data, labelBirds);
fs0xRes.resultsCrickets = LOONN(featuresCount, elementsPerFeature, data, labelsCrickets);
fs0xRes.resultsRiverWaterfall = LOONN(featuresCount, elementsPerFeature, data, labelsRiverWaterfall);
fs0xRes.resultsRain = LOONN(featuresCount, elementsPerFeature, data, labelsRain);
fs0xRes.resultsThunder = LOONN(featuresCount, elementsPerFeature, data, labelsThunder);
fs0xRes.resultsNoise = LOONN(featuresCount, elementsPerFeature, data, labelsNoise);
fs0xRes.resultsUnknown = LOONN(featuresCount, elementsPerFeature, data, labelsUnknown);
fprintf("> LOONN fs0Xs: end\n\n");

% fs 1s 
mtx = load(sprintf("./%s/%s", templatesfs1sDirPath, dataFileName));
data = mtx.data(audioIdxs, :);
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
fprintf("> LOONN fs1: end\n\n");


%% RESULTS TABLE
resultType = fs0xRes.resultsVehicle.resultTypes;
isStandardized = fs0xRes.resultsVehicle.isStandardized;
headers = {'CheckType', 'IsStandardized', 'Vehicle', 'Birds', 'Crickets', 'River/Waterfall', ...
    'Rain', 'Thunder', 'Noise', 'Unknown'};

fprintf("> CHECKS LOONN all features, fs 0Xs\n\n");
disp(table(resultType, ...
    isStandardized, ...
    fs0xRes.resultsVehicle.values, ...
    fs0xRes.resultsBirds.values, ...
    fs0xRes.resultsCrickets.values, ...
    fs0xRes.resultsRiverWaterfall.values, ...
    fs0xRes.resultsRain.values, ...
    fs0xRes.resultsThunder.values, ...
    fs0xRes.resultsNoise.values, ...
    fs0xRes.resultsUnknown.values, ...
    'VariableNames', headers) ...
    );

fprintf("> CHECKS LOONN all features, fs 1s\n\n");
disp(table(resultType, ...
    isStandardized, ...
    fs1sRes.resultsVehicle.values, ...
    fs1sRes.resultsBirds.values, ...
    fs1sRes.resultsCrickets.values, ...
    fs1sRes.resultsRiverWaterfall.values, ...
    fs1sRes.resultsRain.values, ...
    fs1sRes.resultsThunder.values, ...
    fs1sRes.resultsNoise.values, ...
    fs1sRes.resultsUnknown.values, ...
    'VariableNames', headers) ...
    );