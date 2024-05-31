clc; clear all; close all

%% CONFIGURATION

audioDir = "../downloadAllAudible/datasetAll";
spectrogramDir = './TEST_spectrogram';
templateDir = './TEST_templates_NEW';

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

% spectrogram conf
iBlockLength = 4096 * 8;
iHopLength = 2048 * 8;


%% EXECUTION

if ~exist(spectrogramDir, 'dir')
    mkdir(spectrogramDir);
end
if ~exist(templateDir, 'dir')
    mkdir(templateDir);
end

ticStart = tic; % general

load("./templates/audio_data.mat");

filesPerBlock = 24; % impostare minimo
filesCount = 96; %size(audioData, 1);

filesPerBlock = min(filesPerBlock, filesCount);
blockCount = max(filesCount/filesPerBlock, 1);
if mod(filesCount,filesPerBlock) ~= 0
    blockCount = blockCount + 1;
end


for b = 1:blockCount
    startIdx = 1 + (b * filesPerBlock);
    endIdx = min((b+1) * filesPerBlock, filesCount);
    
    ticSpectrogram; % creation of spectrogram

    parfor fileId = 1:filesPerBlock
        
        uniqueName = audioData{fileId, 1};
        audioName = audioData{fileId, 2};
        audioNameNoExtension = audioData{fileId, 3};
        yat = audioData{fileId, 4};

        audioFilePath = sprintf("%s/YAT%dAudible/%s", audioDir, yat, audioName);

        fprintf('%4d) processing %s\n', fileId, audioName);

        if ~exist(audioFilePath, "file")
            error("WARN file not found: file name '%s' in path '%s' \n", audioName, audioFilePath);
        else
            spectrogramName = sprintf("spectrogram_%s.mat", uniqueName);
            spectrogramFilePath = sprintf("%s/%s", spectrogramDir, spectrogramName);

            if exist(spectrogramFilePath, "file")
                fprintf('%4d) spectrogram on file "%s" already exists, skipped \n', fileId, audioName);
            else
                [y, f_s] = audioread(audioFilePath);
                [X, f, t] = ComputeSpectrogram(y, f_s, [], iBlockLength, iHopLength);
                
                save(spectrogramFilePath, '-fromstruct', struct('X', X, 'f', f, 't', t, 'f_s', f_s, 'y', y));
            end
        end
    end
    elapsed = toc(ticSpectrogram);
    fprintf('>> saved %d spectrogram in %.4f sec, %.4f files/s\n', filesCount, elapsed, filesCount/elapsed);

end



%% CREATIONG OF FEATURES
tic;

featureSpectralCentroid.featuresSet = zeros(filesCount, 176);
featureSpectralCrestFactor.featuresSet = zeros(filesCount, 176);
featureSpectralDecrease.featuresSet = zeros(filesCount, 176);
featureSpectralFlatness.featuresSet = zeros(filesCount, 176);
featureSpectralFlux.featuresSet = zeros(filesCount, 176);
featureSpectralRolloff.featuresSet = zeros(filesCount, 176);
featureSpectralSpread.featuresSet = zeros(filesCount, 176);
featureSpectralTonalPowerRatio.featuresSet = zeros(filesCount, 176);
featureTimeZeroCrossingRate.featuresSet = zeros(filesCount, 176);
featureTimeAcfCoeff.featuresSet = zeros(filesCount, 176);
featureTimeMaxAcf.featuresSet = zeros(filesCount, 176);

for fileId = 1:filesCount
    uniqueName = audioData{fileId, 1};
    audioName = audioData{fileId, 2};
    audioNameNoExtension = audioData{fileId, 3};
    yat = audioData{fileId, 4};

    spectrogramName = sprintf("spectrogram_%s.mat", uniqueName);
    spectrogramFilePath = sprintf("%s/%s", spectrogramDir, spectrogramName);

    sptg = load(spectrogramFilePath);

    featureSpectralCentroid.featuresSet(fileId,:) = FeatureSpectralCentroid(sptg.X, sptg.f_s);
    featureSpectralCrestFactor.featuresSet(fileId,:) = FeatureSpectralCrestFactor(sptg.X, sptg.f_s);
    featureSpectralDecrease.featuresSet(fileId,:) = FeatureSpectralDecrease(sptg.X, sptg.f_s);
    featureSpectralFlatness.featuresSet(fileId,:) = FeatureSpectralFlatness(sptg.X, sptg.f_s);
    featureSpectralFlux.featuresSet(fileId,:) = FeatureSpectralFlux(sptg.X, sptg.f_s);
    featureSpectralRolloff.featuresSet(fileId,:) = FeatureSpectralRolloff(sptg.X, sptg.f_s);
    featureSpectralSpread.featuresSet(fileId,:) = FeatureSpectralSpread(sptg.X, sptg.f_s);
    featureSpectralTonalPowerRatio.featuresSet(fileId,:) = FeatureSpectralTonalPowerRatio(sptg.X, sptg.f_s);
    featureTimeZeroCrossingRate.featuresSet(fileId,:) = FeatureTimeZeroCrossingRate(sptg.y, iBlockLength, iHopLength, sptg.f_s);
    featureTimeAcfCoeff.featuresSet(fileId,:) = FeatureTimeAcfCoeff(sptg.y, iBlockLength, iHopLength, sptg.f_s);
    featureTimeMaxAcf.featuresSet(fileId,:) = FeatureTimeMaxAcf(sptg.y, iBlockLength, iHopLength, sptg.f_s);

    fprintf('%4d) featured file "%s" \n', fileId, audioName);
end

elapsed = toc;
fprintf('>> created %d single feature matrix in %.4f sec, %.4f files/s\n', ...
    filesCount, elapsed, filesCount/elapsed);

%% SAVING MATRIX

ticSavingMatrix = tic;

% saving all files
save(sprintf("%s/%s.mat", templateDir, featureNames{1}), '-struct', "featureSpectralCentroid");
save(sprintf("%s/%s.mat", templateDir, featureNames{2}), '-struct', "featureSpectralCrestFactor");
save(sprintf("%s/%s.mat", templateDir, featureNames{3}), '-struct', "featureSpectralDecrease");
save(sprintf("%s/%s.mat", templateDir, featureNames{4}), '-struct', "featureSpectralFlatness");
save(sprintf("%s/%s.mat", templateDir, featureNames{5}), '-struct', "featureSpectralFlux");
save(sprintf("%s/%s.mat", templateDir, featureNames{6}), '-struct', "featureSpectralRolloff");
save(sprintf("%s/%s.mat", templateDir, featureNames{7}), '-struct', "featureSpectralSpread");
save(sprintf("%s/%s.mat", templateDir, featureNames{8}), '-struct', "featureSpectralTonalPowerRatio");
save(sprintf("%s/%s.mat", templateDir, featureNames{9}), '-struct', "featureTimeZeroCrossingRate");
save(sprintf("%s/%s.mat", templateDir, featureNames{10}), '-struct', "featureTimeAcfCoeff");
save(sprintf("%s/%s.mat", templateDir, featureNames{11}), '-struct', "featureTimeMaxAcf");

% clearing space
clear featureSpectralCentroid;
clear featureSpectralCrestFactor;
clear featureSpectralDecrease;
clear featureSpectralFlatness;
clear featureSpectralFlux;
clear featureSpectralRolloff;
clear featureSpectralSpread;
clear featureSpectralTonalPowerRatio;
clear featureTimeZeroCrossingRate;
clear featureTimeAcfCoeff;
clear featureTimeMaxAcf;

elapsed = toc(ticSavingMatrix);
fprintf('>> saved all files in %.4f sec, %.4f featureFile/s\n', ...
    elapsed, featuresCount/elapsed);

%% CONCATENATION
ticConcatFiles = tic;
data = [];
% concating all feature horizontally
for featureId=1:featuresCount
    featureName = featureNames{featureId};
    fprintf('Adding feature %s to result matrix \n', featureName);

    featureFilePath = sprintf("%s/%s.mat", templateDir, featureName);
    if ~exist(featureFilePath, "file")
        error("feature file not exist: feature '%s'\n", featureName);
    end
    load(featureFilePath);

    data = [data featuresSet];
    save(sprintf('./%s/matriceTEST.mat', templateDir), 'data');
end
elapsed = toc(ticConcatFiles);
fprintf('>> concatenation time in %.4f sec,  %.4f featureFile/s\n', ...
    elapsed, filesCount, featuresCount, (filesCount*featuresCount)/elapsed);


elapsed = toc(ticStart);
fprintf('>> exec time in %.4f sec,  %.4f featureFile/s\n', ...
    elapsed, filesCount, featuresCount, (filesCount*featuresCount)/elapsed);


