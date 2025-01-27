
clc; clear all; close all

%% configuration

audioDir = "../downloadAllAudible/datasetAll";
spectrogramDir = './TEST_spectrogram';
templateDir = './TEST_templates_NEW';

% spectrogram conf
iBlockLength = 4096 * 8;
iHopLength = 2048 * 8;

% block execution
threadsCount = 10;
blockSize = 96; % files processed in every block

% features names
featureNames{1} = 'SpectralCentroid';
featureNames{2} = 'SpectralCrestFactor';
featureNames{3} = 'SpectralDecrease';
featureNames{4} = 'SpectralFlatness';
featureNames{5} = 'SpectralFlux';
featureNames{6} = 'SpectralRolloff';
featureNames{7} = 'SpectralSpread';
featureNames{8} = 'SpectralTonalPowerRatio';
featureNames{9} = 'TimeZeroCrossingRate';
featureNames{10} = 'TimeAcfCoeff';
featureNames{11} = 'TimeMaxAcf';

%% functions

function [startIdx, endIdx] = calcRange(rangeId, rangeSize, totalSize)
startIdx = 1 + (rangeId * rangeSize);
endIdx = min((rangeId+1) * rangeSize, totalSize);
end

%% setup context

featuresCount = length(featureNames);

% create result dir if not exists
if ~exist(spectrogramDir, 'dir'); mkdir(spectrogramDir); end
if ~exist(templateDir, 'dir'); mkdir(templateDir); end

load("./templates/audio_data.mat");
filesCount = 96; %size(audioData, 1); %%%____________TODOOOO__________________

% block checks
blockSize = min(blockSize, filesCount);
blockCount = max(ceil(filesCount/blockSize), 1);

% features result structures
featureSpectralCentroid = zeros(filesCount, 176);
featureSpectralCrestFactor= zeros(filesCount, 176);
featureSpectralDecrease= zeros(filesCount, 176);
featureSpectralFlatness= zeros(filesCount, 176);
featureSpectralFlux= zeros(filesCount, 176);
featureSpectralRolloff= zeros(filesCount, 176);
featureSpectralSpread= zeros(filesCount, 176);
featureSpectralTonalPowerRatio = zeros(filesCount, 176);
featureTimeZeroCrossingRate = zeros(filesCount, 176);
featureTimeAcfCoeff = zeros(filesCount, 176);
featureTimeMaxAcf = zeros(filesCount, 176);

%% execution

fprintf("> execution start \n");
fprintf("> parallel threads %d \n", threadsCount);
fprintf("> %d files divided into %d blocks of size %d for \n", filesCount, blockCount, blockSize);

% delete all files in temp dir
delete(sprintf("%s/*.mat", spectrogramDir));
fprintf("> cleaned temp dir \n");

% workers
ticWorkers = tic;
fprintf("> try to init workers \n");
% overriding workers
localCluster = parcluster('local');
localCluster.NumWorkers = threadsCount;
saveProfile(localCluster);
% removing existent pool
pool = gcp('nocreate');
if ~isempty(pool)
    delete(pool);
end
parpool('local', threadsCount);
elapsed = toc(ticWorkers);
fprintf('> startup %d workers in %.4f sec\n', threadsCount, elapsed);

ticStart = tic;

ticBlocks = tic;

% blocks of file to execute, for each block:
%   1. calc and save specrogram for block files
%   2. load files, calc all features and save their result in memory var
for b = 0:(blockCount-1)
    startIdx = 1 + (b * blockSize);
    endIdx = min((b+1) * blockSize, filesCount);

    blockFinalSize = endIdx - startIdx + 1;


    ticSpectrogram = tic; % creation of spectrogram

    % parallel execution: calc spectrogram and save to file
    parfor fileId = startIdx:endIdx
        uniqueName = audioData{fileId, 1};
        audioName = audioData{fileId, 2};
        audioNameNoExtension = audioData{fileId, 3};
        yat = audioData{fileId, 4};

        fprintf('%4d) processing %s\n', fileId, audioName);

        audioFilePath = sprintf("%s/YAT%dAudible/%s", audioDir, yat, audioName);
        if ~exist(audioFilePath, "file")
            error("WARN file not found: file name '%s' in path '%s' \n", audioName, audioFilePath);
        end

        spectrogramName = sprintf("spectrogram_%s.mat", uniqueName);
        spectrogramFilePath = sprintf("%s/%s", spectrogramDir, spectrogramName);

        if exist(spectrogramFilePath, "file")
            error(['%4d) spectrogram on file "%s" already exists, ' ...
                'unique file name "%s" \n'], fileId, uniqueName);
        end

        [y, f_s] = audioread(audioFilePath);
        [X, f, t] = ComputeSpectrogram(y, f_s, [], iBlockLength, iHopLength);

        save(spectrogramFilePath, '-fromstruct', struct('X', X, 'f', f, 't', t, 'f_s', f_s, 'y', y));
    end

    elapsed = toc(ticSpectrogram);
    fprintf('> computed and saved %d spectrogram in %.4f sec ( %.4f files/s )\n', blockFinalSize, elapsed, blockFinalSize/elapsed);


    ticFeatures = tic;

    % load files, calc all features and save their result in memory var
    parfor fileId = startIdx:endIdx
        uniqueName = audioData{fileId, 1};
        audioName = audioData{fileId, 2};
        audioNameNoExtension = audioData{fileId, 3};
        yat = audioData{fileId, 4};

        spectrogramName = sprintf("spectrogram_%s.mat", uniqueName);
        spectrogramFilePath = sprintf("%s/%s", spectrogramDir, spectrogramName);

        sptg = load(spectrogramFilePath);

        featureSpectralCentroid(fileId,:) = FeatureSpectralCentroid(sptg.X, sptg.f_s);
        featureSpectralCrestFactor(fileId,:) = FeatureSpectralCrestFactor(sptg.X, sptg.f_s);
        featureSpectralDecrease(fileId,:) = FeatureSpectralDecrease(sptg.X, sptg.f_s);
        featureSpectralFlatness(fileId,:) = FeatureSpectralFlatness(sptg.X, sptg.f_s);
        featureSpectralFlux(fileId,:) = FeatureSpectralFlux(sptg.X, sptg.f_s);
        featureSpectralRolloff(fileId,:) = FeatureSpectralRolloff(sptg.X, sptg.f_s);
        featureSpectralSpread(fileId,:) = FeatureSpectralSpread(sptg.X, sptg.f_s);
        featureSpectralTonalPowerRatio(fileId,:) = FeatureSpectralTonalPowerRatio(sptg.X, sptg.f_s);
        featureTimeZeroCrossingRate(fileId,:) = FeatureTimeZeroCrossingRate(sptg.y, iBlockLength, iHopLength, sptg.f_s);
        featureTimeAcfCoeff(fileId,:) = FeatureTimeAcfCoeff(sptg.y, iBlockLength, iHopLength, sptg.f_s);
        featureTimeMaxAcf(fileId,:) = FeatureTimeMaxAcf(sptg.y, iBlockLength, iHopLength, sptg.f_s);

        fprintf('%4d) processed feature for file "%s" \n', fileId, audioName);
    end

    elapsed = toc(ticFeatures);
    fprintf('> block %d of %d completed: calc features for %d files in %.4f sec ( %.4f files/s )\n', ...
        b + 1, blockCount, blockFinalSize, elapsed, blockFinalSize/elapsed);

    % delete all files in temp dir
    delete(sprintf("%s/*.mat", spectrogramDir));
end

elapsed = toc(ticBlocks);
fprintf('> processed all blocks for %d files in %.4f sec ( %.4f files/s ) \n', filesCount, elapsed, filesCount/elapsed);

clear audioData;

%% SAVING FEATURES MATRICES

ticSavingMatrix = tic;

% saving all files
for featureId = 1:featuresCount
    featureName = featureNames{featureId};
    featureVarName = sprintf("feature%s", featureName);
    featureSet = eval(featureVarName);
    save(sprintf("%s/%s.mat", templateDir, featureName), "-fromstruct", struct("featuresSet", featureSet));
    clear(featureVarName);
end
clear featureSet;

elapsed = toc(ticSavingMatrix);
fprintf('> saved all files in %.4f sec, %.4f featureFile/s\n', elapsed, featuresCount/elapsed);

%% CONCATENATION OF ALL FEATURES IN ONE MATRIX

ticConcatFiles = tic;

data = [];
% concating all feature horizontally
for featureId = 1:featuresCount
    featureName = featureNames{featureId};
    fprintf('Adding feature %s to result matrix \n', featureName);

    featureFilePath = sprintf("%s/%s.mat", templateDir, featureName);
    if ~exist(featureFilePath, "file")
        error("feature file not exist: feature '%s'\n", featureName);
    end
    load(featureFilePath);

    data = [data featuresSet];
    save(sprintf('./%s/matrixAllFeatures.mat', templateDir), 'data');
end

elapsed = toc(ticConcatFiles);
fprintf('> concatenation time in %.4f sec for %d files and %d features, %.4f featureFile/s\n', ...
    elapsed, filesCount, featuresCount, (filesCount*featuresCount)/elapsed);


%% CONCLUSION
elapsed = toc(ticStart);
fprintf('> TOTAL EXECUTION TIME %.4f sec for %d files and %d features, speed %.4f featureFile/s\n', ...
    elapsed, filesCount, featuresCount, (filesCount*featuresCount)/elapsed);


