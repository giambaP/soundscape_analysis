clc; clear all; close all
addpath("functions/");

%% configuration

audioDir = "../downloadAllAudible/datasetAll";
labelsDir = './labels';
resultDir = './result_best_filters_1sec';
resultFileName = 'result_best_filters_1sec';

% spectrogram conf
iBlockLength = 48000;
iHopLength = 48000 / 2;

% block execution
threadsCount = 8;
% elements of each feature
elementsPerFeature = 120;
featuresCount = 11;

%% setup context

% create result dir if not exists
if ~exist(resultDir, 'dir'); mkdir(resultDir); end

load(sprintf("./%s/audio_data.mat", labelsDir));

% filtering files on march with 2,6,8,12,18,22 hours
monthColumn = 6;
monthColumnData = cell2mat(audioData(:, monthColumn));
monthValues = 3;
monthIndexes = find(ismember(monthColumnData, monthValues) == 1);
hourColumn = 8;
hoursColumnData = cell2mat(audioData(:, hourColumn));
hourValues = [2, 6, 10, 14, 18, 22];
hoursIndexes = find(ismember(hoursColumnData, hourValues) == 1);
minutesColumn = 9;
minutesColumnData = cell2mat(audioData(:, minutesColumn));
minutesValues = 0;
minutesIndexes = find(ismember(minutesColumnData, minutesValues) == 1);
filesIndexes = intersect(monthIndexes, hoursIndexes);
filesIndexes = intersect(filesIndexes, minutesIndexes);

% filesIndexes = filesIndexes([ 1:15 400:410 ],:);
% filesIndexes = filesIndexes([ 1:15 150:160 220:230 340:350 430:440 540:550 ],:);

audioData = audioData(filesIndexes, :);
load(sprintf("./%s/labels_Yat.mat", labelsDir));
labels = labels(filesIndexes, :);

filesCount = size(audioData, 1);

%% preparing execution

fprintf("> execution start \n");
fprintf("> parallel threads %d \n", threadsCount);

% workers
ticWorkers = tic;
fprintf("> try to init workers \n");
% overriding workers
localCluster = parcluster('local');
localCluster.NumWorkers = threadsCount;
saveProfile(localCluster);
% removing existent pool
pool = gcp('nocreate');
if ~isempty(pool); delete(pool); delete(localCluster.Jobs); end
parpool('local', threadsCount);
elapsed = toc(ticWorkers);
fprintf('> startup %d workers in %.4f sec\n', threadsCount, elapsed);

ticStart = tic;


%% filtering, concatenation and LOON execution for each filter

upperFilters = [ 20 30 40 ]; %0:5:15;
lowerFilters = [ 20 30 40 ]; %0:5:15;
filtersCount = numel(upperFilters) * numel(lowerFilters);

% LOONN result
% rows: 1 is header + 38 LOONN tests
% cols: 1 result type + 1 normal/std + filtersCount
resultsRows = 1+38;
resultsCols = 1+1+filtersCount;
results = cell(resultsRows, resultsCols);

firstResult = 1;

filterIndex = 0;
for lowerFilter = lowerFilters
    for upperFilter = upperFilters    
        filterIndex = filterIndex + 1;

        ticSingleExecution = tic;
        dateTimeString = char(datetime('now'));

        filterId = sprintf("%3d. FILTER [ UPP=%3d , LOW=%3d ]", filterIndex, upperFilter, lowerFilter);
        fprintf("%s - starting at %s - %d files per %d filters \n", filterId, dateTimeString, filesCount, filtersCount);

        %% filtering data

        ticFiltering = tic;

        featureSpectralCentroid = zeros(filesCount, elementsPerFeature);
        featureSpectralCrestFactor= zeros(filesCount, elementsPerFeature);
        featureSpectralDecrease= zeros(filesCount, elementsPerFeature);
        featureSpectralFlatness= zeros(filesCount, elementsPerFeature);
        featureSpectralFlux= zeros(filesCount, elementsPerFeature);
        featureSpectralRolloff= zeros(filesCount, elementsPerFeature);
        featureSpectralSpread= zeros(filesCount, elementsPerFeature);
        featureSpectralTonalPowerRatio = zeros(filesCount, elementsPerFeature);
        featureTimeZeroCrossingRate = zeros(filesCount, elementsPerFeature);
        featureTimeAcfCoeff = zeros(filesCount, elementsPerFeature);
        featureTimeMaxAcf = zeros(filesCount, elementsPerFeature);

        parfor fileId = 1:filesCount
            uniqueName = audioData{fileId, 1};
            audioName = audioData{fileId, 2};
            audioNameNoExtension = audioData{fileId, 3};
            yat = audioData{fileId, 4};

            audioFilePath = sprintf("%s/YAT%dAudible/%s", audioDir, yat, audioName);
            if ~exist(audioFilePath, "file")
                error("WARN file not found: file name '%s' in path '%s' \n", audioName, audioFilePath);
            end

            [y, f_s] = audioread(audioFilePath);
            [X, f, t] = ComputeSpectrogram(y, f_s, [], iBlockLength, iHopLength);

            % upper filter
            if upperFilter ~= 0
                X(1:upperFilter, :) = 0;
            end
            % lower filter
            if lowerFilter ~= 0
                X(end-lowerFilter:end, :) = 0;
            end

            featureSpectralCentroid(fileId,:) = FeatureSpectralCentroid(X, f_s);
            featureSpectralCrestFactor(fileId,:) = FeatureSpectralCrestFactor(X, f_s);
            featureSpectralDecrease(fileId,:) = FeatureSpectralDecrease(X, f_s);
            featureSpectralFlatness(fileId,:) = FeatureSpectralFlatness(X, f_s);
            featureSpectralFlux(fileId,:) = FeatureSpectralFlux(X, f_s);
            featureSpectralRolloff(fileId,:) = FeatureSpectralRolloff(X, f_s);
            featureSpectralSpread(fileId,:) = FeatureSpectralSpread(X, f_s);
            featureSpectralTonalPowerRatio(fileId,:) = FeatureSpectralTonalPowerRatio(X, f_s);
            featureTimeZeroCrossingRate(fileId,:) = FeatureTimeZeroCrossingRate(y, iBlockLength, iHopLength, f_s);
            featureTimeAcfCoeff(fileId,:) = FeatureTimeAcfCoeff(y, iBlockLength, iHopLength, f_s);
            featureTimeMaxAcf(fileId,:) = FeatureTimeMaxAcf(y, iBlockLength, iHopLength, f_s);
            
            if mod(fileId, 30) == 0 % some of thread could reach it but real status could be a little bit different
                elapsed = toc(ticFiltering);
                fprintf('%s - [%3d] fileId reached at %s, elapsed time %.3f (%.2f min)\n', ...
                    filterId, fileId, char(datetime('now')), elapsed, elapsed/60);            
            end
        end

        elapsed = toc(ticFiltering);
        fprintf('%s - filtering spectrum and calc features in %.4f sec (%.2f min) for %d files, %.4f file/s\n', ...
            filterId, elapsed, elapsed/60, filesCount, filesCount/elapsed);


        %% concatenation of all features files into one matrix

        ticConcatFiles = tic;

        data = zeros(filesCount, featuresCount * elementsPerFeature);
        % concating all feature horizontally
        for featureId = 1:featuresCount
            featureName = Features.getEnumByIndex(featureId).Name;
            featureVarName = sprintf("feature%s", featureName);
            featureSet = eval(featureVarName);

            colStart = (featureId - 1) * elementsPerFeature + 1;
            colEnd = featureId * elementsPerFeature;

            data(:, colStart:colEnd) = featureSet;
        end

        elapsed = toc(ticConcatFiles);
        fprintf('%s - concatenation time in %.4f sec for %d features, %.4f feature/s\n', ...
            filterId, elapsed, featuresCount, filesCount/elapsed);


        %% LOONN result

        ticLoonResult = tic;

        resultSingleLoonn = executeLOONN(featuresCount, elementsPerFeature, data, labels, 1, 0);

        % setting first rows
        if firstResult == 1
            firstResult = 0;
            resultTypes = [resultSingleLoonn{:,1}]';
            isStandardized = [resultSingleLoonn{:,3}]';

            results(2:resultsRows, 1) = cellstr(resultTypes);
            results(2:resultsRows, 2) = num2cell(isStandardized);
            results{1, 1} = 'RESULT TYPE';
            results{1, 2} = 'STD';
        end

        values = [resultSingleLoonn{:,2}]';
        results{1, 2+filterIndex} = sprintf('UPP-%d,LOW-%d', upperFilter, lowerFilter);
        results(2:resultsRows, 2+filterIndex) = num2cell(values);

        elapsed = toc(ticLoonResult);
        fprintf('%s - loon executed in %.4f sec for %d files, %.4f file/s\n', ...
            filterId, elapsed, filesCount, filesCount/elapsed);

        %% execution statistics

        elapsed = toc(ticSingleExecution);
        fprintf("%s - completed, %d of %d filters, single execution time %.4f sec (%.2f min), extimated missing time %.4f sec (%.2f min) \n", ...
            filterId, filterIndex, filtersCount, elapsed, elapsed/60, elapsed*(filtersCount-filterIndex), (elapsed*(filtersCount-filterIndex))/60);

    end
end

resultsTable = cell2table(results(2:end,:), 'VariableNames', results(1,:));
writetable(resultsTable, sprintf('%s/%s.csv', resultDir, resultFileName));

%% conclusion

elapsed = toc(ticStart);
fprintf('> TOTAL EXECUTION TIME %.4f sec (%.1f min) for %d files, speed %.4f files/s\n', ...
    elapsed, elapsed/60, filesCount, filesCount/elapsed);


