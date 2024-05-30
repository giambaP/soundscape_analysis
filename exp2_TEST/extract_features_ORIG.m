clc; clear all; close all

numOfDays = 31;

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
%nomefs{12} = 'SpectralMfccs';

featuresCount = length(nomefs);

templatesDir = './TEST_templates_OLD';

tic; % total

expectedFiles = 96;

for fs=1:featuresCount
    featureName = nomefs{fs};
    fprintf('%2d. %s: starting \n', fs, featureName);

    featureFilePath = sprintf("%s/%s.mat", templatesDir, featureName);
    if ~exist(featureFilePath, "file")
        featuresSet = [];

        counterRow = 1;

        for YAT = 1
            fprintf('%2d. %s, YAT %d: starting  \n', fs, featureName, YAT);
            % audio per days
            for i = 1:2
                % audio per hours
                for j = 0:23
                    %create file name
                    flName = '202003';
                    if i < 10
                        flName = strcat(flName,'0',num2str(i));
                    else
                        flName = strcat(flName,num2str(i));
                    end
                    % audio per half hour
                    for h = [0 3]
                        if j < 10
                            nm = strcat(flName,'_0',num2str(j), num2str(h),'000.WAV');
                        else
                            nm = strcat(flName,'_',num2str(j), num2str(h),'000.WAV');
                        end

                        audioName = strcat('./TEST_database/YAT', num2str(YAT),'Audible/', nm);
                        fprintf('%d) %s\n',counterRow, audioName);

                        if ~exist(audioName, "file")
                            fprintf("WARN - file not found: file name '%s' \n", audioName);
                        else
                            iBlockLength = 4096 * 8;
                            iHopLength = 2048 * 8;

                            [y, f_s] = audioread(audioName);
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
                end
            end

            if counterRow ~= expectedFiles+1
                error("wrong files count: expected %d, found %d", expectedFiles, counterRow);
            end

            fprintf('%2d. %s, YAT %d: ended  \n', fs, featureName, YAT);
        end
        save(featureFilePath, 'featuresSet');
    end
end

data = [];
% concating all feature horizontally
for fs=1:featuresCount
    clear featuresSet

    featureName = nomefs{fs};
    fprintf('Creating feature %s \n', featureName);

    featureFilePath = sprintf("%s/%s.mat", templatesDir, featureName);
    if ~exist(featureFilePath, "file")
        error("feature file not exist: feature '%s'\n", featureName);
    end
    load(featureFilePath);

    data = [data featuresSet];
    save('./TEST_templates/matriceTEST.mat', 'data');
end

elapsed = toc;
fprintf('Exec time in %.4f sec: %d files * %d features = %d files, so %.4f file/s\n', ...
elapsed, expectedFiles, featuresCount, (expectedFiles*featuresCount), (expectedFiles*featuresCount)/elapsed);



% %% checking compatibility
% disp("");
% disp("-----  CHECKING COMPATIBILITY ----");
% dirTemplateNew = "./templatesYAT";
% dirTemplateOriginal = "./templatesYAT_ORIG";
% fileList = dir(dirTemplateOriginal);
% fileList = fileList(~[fileList.isdir]);
% for i=1:length(fileList)
%     fileName = fileList(i, :).name;
%     fprintf("%d. checking file %s\n", i, fileName);
%
%     origFilePath = sprintf("%s/%s", dirTemplateOriginal, fileName);
%     newFilePath = sprintf("%s/%s", dirTemplateNew, fileName);
%     if ~exist(newFilePath , "file")
%         error("feature file not exist final path: feature '%s'\n", fileName);
%     else
%         data1 = load(origFilePath);
%         data2 = load(newFilePath);
%
%         fields1 = fieldnames(data1);
%         fields2 = fieldnames(data2);
%
%         if ~isequal(fields1, fields2)
%             error("feature content files are different: file '%s', field '%s'", fileName, fields1);
%         else
%             isEqual = true;
%             for j = 1:length(fields1)
%                 d1 = data1.(fields1{j});
%                 d2 = data2.(fields2{j});
%                 if ~isequal(d1, d2)
%                     error("feature content fields are different: file '%s', field '%s', posJ:'%d'", ...
%                         fileName, fields1{j}, j);
%                 end
%             end
%         end
%     end
% end