clc; clear all; close all

%% CONFIGURATION
audioDir = "../downloadAllAudible/datasetAll";
spectrogramDir = './spectrogram';
templateDir = './templates';

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

featuresCount = length(featureNames);


%% EXECUTION

load("./templates/audio_data.mat");
filesCount = 30; %%%size(audioData, 1);

tic;

for fileId = 1:filesCount
    uniqueName = audioData{fileId, 1};
    audioName = audioData{fileId, 2};
    audioNameNoExtension = audioData{fileId, 3};
    yat = audioData{fileId, 4};
    year = audioData{fileId, 5};
    month = audioData{fileId, 6};
    day = audioData{fileId, 7};
    hour = audioData{fileId, 8};
    minute = audioData{fileId, 9};
    second = audioData{fileId, 10};

    audioFilePath = sprintf("%s/YAT%dAudible/%s", audioDir, yat, audioName);

    fprintf('%4d) processing %s\n', fileId, audioName);

    if ~exist(audioFilePath, "file")
        error("WARN file not found: file name '%s' in path '%s' \n", audioName, audioFilePath);
    else
        [y, f_s] = audioread(audioFilePath);

        iBlockLength = 4096 * 8;
        iHopLength = 2048 * 8;

        [X, f, t] = ComputeSpectrogram(y, f_s, [], iBlockLength, iHopLength);

        fsval = [];
        switch fs
            case 1
                fsval = FeatureSpectralCentroid(X, f_s);
            case 2
                fsval = FeatureSpectralCrestFactor(X, f_s);
            case 3
                fsval = FeatureSpectralDecrease(X, f_s);
            case 4
                fsval = FeatureSpectralFlatness(X, f_s);
            case 5
                fsval = FeatureSpectralFlux(X, f_s);
            case 6
                fsval = FeatureSpectralRolloff(X, f_s);
            case 7
                fsval = FeatureSpectralSpread(X, f_s);
            case 8
                fsval = FeatureSpectralTonalPowerRatio(X, f_s);
            case 9
                fsval = FeatureTimeZeroCrossingRate(y, iBlockLength, iHopLength, f_s);
            case 10
                fsval = FeatureTimeAcfCoeff(y, iBlockLength, iHopLength, f_s);
            case 11
                fsval = FeatureTimeMaxAcf(y, iBlockLength, iHopLength, f_s);
        end

        featuresSet(counterRow,:) = fsval;

        counterRow = counterRow + 1;
    end
end

elapsed = toc;
fprintf('>> saved %d spectrogram in %.4f sec, %.4f files/s\n', filesCount, elapsed, filesCount/elapsed);


%% CONCATENATION OF FEATURES FILES

data = [];
% concating all feature horizontally
for featureId=1:featuresCount
    clear featuresSet

    featureName = featureNames{featureId};
    fprintf('Creating feature %s \n', featureName);

    featureFilePath = sprintf("%s/%s.mat", templateDir, featureName);
    if ~exist(featureFilePath, "file")
        error("feature file not exist: feature '%s'\n", featureName);
    end
    load(featureFilePath);

    data = [data featuresSet];
    save('./templates/matrix.mat', 'data');
end