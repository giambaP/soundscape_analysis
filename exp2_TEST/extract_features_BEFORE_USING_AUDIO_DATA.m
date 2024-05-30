clc; clear all; close all

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

sourceDir = "../downloadAllAudible/datasetAll";
targetDir = './templates/';

yats = [1 2 3];
years = 2020;
months = [3 4 5];
days = 1:31;
hours = 0:23;
minutes = [00 30];

tic;

parpool(4);

parfor fs=1:featuresCount
    featureName = featureNames{fs};
    fprintf('%2d. %s: starting \n', fs, featureName);

    featureFilePath = sprintf("%s_%s.mat", targetDir, featureName);
    if exist(featureFilePath, "file")
        fprintf('%2d. %s: already exists, skipped \n', fs, featureName);
    else
        featuresSet = [];

        counterRow = 1;

        % yat
        for YAT = yats
            fprintf('%2d. %s, YAT %d: starting  \n', fs, featureName, YAT);
            for year = years
                for month = months
                    for day = days
                        for hour = hours
                            for minute = minutes
                                audioName = sprintf("%04d%02d%02d_%02d%02d%02d.WAV", year, month, day, hour, minute, "0");
                                audioFilePath = sprintf("%s/YAT%dAudible/%s", sourceDir, YAT, audioName);
                                
                                fprintf('%d) %s\n', counterRow, audioName);

                                if ~exist(audioFilePath, "file")
                                    fprintf("WARN - file not found: file name '%s' \n", audioFilePath);
                                else
                                    iBlockLength = 4096 * 8;
                                    iHopLength = 2048 * 8;

                                    [y, f_s] = audioread(audioFilePath);

                                    [X, f, t] = ComputeSpectrogram(y, f_s, [], iBlockLength, iHopLength);
                                    % fprintf('Spectrogram - X: [ %0.f, %0.f ] \n', size(X, 1), size(X, 2));
                                    % fprintf('Spectrogram - f: [ %0.f, %0.f ] \n', size(f, 1), size(f, 2));
                                    % fprintf('Spectrogram - t: [ %0.f, %0.f ] \n', size(t, 1), size(t, 2));
                                    % Spectrogram - X: [ 16385, 176 ]
                                    % Spectrogram - f: [ 1, 16385 ]
                                    % Spectrogram - t: [ 1, 176 ]
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
                        end
                    end
                end
            end
            fprintf('%2d. %s, YAT %d: ended  \n', fs, featureName, YAT);
        end
        save(featureFilePath, 'featuresSet');

        fprintf('%2d. %s: ending \n', fs, featureName);
    end
end

elapsed = toc;
fprintf('Exec time in %.6f sec\n', elapsed);

data = [];
% concating all feature horizontally
for fs=1:featuresCount
    clear featuresSet

    featureName = featureNames{fs};
    fprintf('Creating feature %s \n', featureName);

    featureFilePath = sprintf("%s_%s.mat", targetDir, featureName);
    if ~exist(featureFilePath, "file")
        error("feature file not exist: feature '%s'\n", featureName);
    end
    load(featureFilePath);

    data = [data featuresSet];
    save('./templates/matrix.mat', 'data');
end