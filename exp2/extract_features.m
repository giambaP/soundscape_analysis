clc; clear all; close all;

%% CONFIGURATION

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

audioDir = "../downloadAllAudible/datasetAll";
templatesDir = './templates';

elementsPerFeature = 176;

%% EXECUTION

tic; % general

featuresCount = length(featureNames);

load("./templates/audio_data.mat");
filesCount = size(audioData, 1);

currentTime = datetime('now', 'Format', 'HH:mm:ss.SSS');
fprintf(">> starting elaboration at %s\n", currentTime);

tic;

poolobj = gcp("nocreate");
if ~isempty(poolobj)
    delete(poolobj);
end
c = parcluster('local');
c.NumWorkers = 4; 
saveProfile(c);

parpool(c, c.NumWorkers);


parfor fs=1:featuresCount
    featureName = featureNames{fs};

    currentTime = datetime('now', 'Format', 'HH:mm:ss.SSS');
    fprintf('>> %2d. %s: start -> %s\n', fs, featureName, currentTime);

    featureFilePath = sprintf("%s/%s.mat", templatesDir, featureName);
    if exist(featureFilePath, "file")
        fprintf('>> %2d. %s: already exists, skipped \n', fs, featureName);
    else

        featuresSet = zeros(filesCount, elementsPerFeature);

        tic;
        for fileId = 1:filesCount
            uniqueName = audioData{fileId, 1};
            audioName = audioData{fileId, 2};
            audioNameNoExtension = audioData{fileId, 3};
            yat = audioData{fileId, 4};
            year = audioData{fileId, 5};
            month = audioData{fileId, 6};
            day = audioData{fileId, 7};

            audioFilePath = sprintf("%s/YAT%dAudible/%s", audioDir, yat, audioName);

            if ~exist(audioFilePath, "file")
                fprintf("WARN - file not found: file name '%s' \n", audioNameNoExtension);
            else
                [y, f_s] = audioread(audioFilePath);

                iBlockLength = 4096 * 8;
                iHopLength = 2048 * 8;
                [X, ~, ~] = ComputeSpectrogram(y, f_s, [], iBlockLength, iHopLength);

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
                % clear X y f_s

                featuresSet(fileId, :) = fsval;
            end

            if mod(fileId, 100) == 0
                elapsedTime = toc;
                fprintf('  %2d. %-20s | %4d YAT %1d, MONTH %1d, DAY %2d, %s | elapsed %.4f s, %.4f files/s \n', ...
                    fs, featureName, fileId, yat, month, day, audioName, elapsedTime, fileId/elapsedTime);
            end
        end
        s = struct("featuresSet",featuresSet);
        save(featureFilePath, "-fromstruct", s);
        % save(featureFilePath, "featuresSet");

        currentTime = datetime('now', 'Format', 'HH:mm:ss.SSS');
        fprintf('>> %2d. %s: end -> %s\n', fs, featureName, currentTime);
    end
end

elapsedFeatures = toc;
currentTime = datetime('now', 'Format', 'HH:mm:ss.SSS');
fprintf('>> created all %d features files in %.4f sec: %d files per %d features, total %.4f files/s -> %s \n', ...
    filesCount, elapsedFeatures, filesCount, featuresCount, ((filesCount*featuresCount)/elapsedFeatures), currentTime);



% concating all feature horizontally
tic;
data = [];
fprintf('>> create final matrix: start\n');
for fs=1:featuresCount
    clear featuresSet

    featureName = featureNames{fs};
    fprintf('adding feature %s \n', featureName);

    featureFilePath = sprintf("%s/%s.mat", templatesDir, featureName);
    if ~exist(featureFilePath, "file")
        error("feature file not exist: feature '%s'\n", featureName);
    end
    load(featureFilePath);

    data = [data featuresSet];
    save('./templates/matrixAllFeatures.mat', 'data');
end
fprintf('>> create final matrix: end \n');
elapsedConcatenation = toc;
fprintf('>> features file created in %.4f sec\n', elapsedConcatenation);


elapsed = toc;
currentTime = datetime('now', 'Format', 'HH:mm:ss.SSS');
fprintf('>> TOTAL elaboration time %.4f sec: %d files on %d features -> %s\n', ...
    elapsedConcatenation + elapsedFeatures, filesCount, featuresCount, currentTime);