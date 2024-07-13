clc; close all; clear all;

%% CONFIGURATION

featuresCount = 11;
featSize = 120;
sampleRate = "fs1";

audioDir = "../downloadAllAudible/datasetAll";
labelsDir = './labels';
anomalousAudioDir = "./anomalousAudioData";
anomalousAudioResultDir = sprintf("./%s/result", anomalousAudioDir);
templatesDirPath = sprintf("./templates_%ss", sampleRate);
matrixFeaturesName = "matrixAllFeatures.mat";

threadsCount = 8;
clearResultDir = 1;

baseAudioUrl = "http://colecciones.humboldt.org.co/rec/sonidos/publicaciones/MAP/JDT-Yataros";

%% FUNCTIONS

function args = printVarargin(varargin) 
    args = '';
    for i = 1:2:length(varargin)
        varName = varargin{1,i};
        varValue = varargin{1,i+1};
        if ischar(varValue); placeHolder = "%s";
        elseif mod(varValue, 0) == 0; placeHolder = "%d";
        else; placeHolder = "%0.5f";
        end
        args = strcat(args, sprintf(strcat(" %s = ", placeHolder, " "), varName, varValue));
        if i+1 ~= length(varargin); args = strcat(args, ", "); end
    end
    if ~isempty(args); args = sprintf("args [%s]", args); end
end

% Wrap of Iforest function:
%   arg: CategoricalPredictors - sublist to process, default []
%   arg: ContaminationFraction - threshold of suspected objs to consider anomalies, default 0
%   arg: NumLearners - trees count, default 100
function result = myIforest(executionId, X, varargin)
    args = printVarargin(varargin{:});
    ticIForest = tic;
    [mdl, tf, scores] = iforest(X, varargin{:});
    elapsed = toc(ticIForest);
    result = struct('mdl', mdl, 'tf', tf, 'scores', scores);
    fprintf("> %s: iforest terminated in %0.5f sec, %s [ anomalies:%d, threshold:%0.5f, scoresMean:%0.5f, scoresStd:%0.5f ] \n", ...
        executionId, elapsed, args, sum(tf), mdl.ScoreThreshold, mean(scores), std(scores));
end
% Wrap of Local Outlier Factor function
function result = myLof(executionId, X, varargin)
    args = printVarargin(varargin{:});
    ticIForest = tic;
    [mdl, tf, scores] = lof(X, varargin{:});
    elapsed = toc(ticIForest);
    result = struct('mdl', mdl, 'tf', tf, 'scores', scores);
    fprintf("> %s: lof terminated in %0.5f sec, %s [ anomalies:%d, threshold:%0.5f, scoresMean:%0.5f, scoresStd:%0.5f ] \n", ...
        executionId, elapsed, args, sum(tf), mdl.ScoreThreshold, mean(scores), std(scores));
end
% Wrap of one class support vector machine function
function result = myOcsvm(executionId, X, varargin)
    args = printVarargin(varargin{:});
    ticIForest = tic;
    [mdl, tf, scores] = ocsvm(X, varargin{:});
    elapsed = toc(ticIForest);
    result = struct('mdl', mdl, 'tf', tf, 'scores', scores);
    fprintf("> %s: ocsvm terminated in %0.5f sec, %s [ anomalies:%d, threshold:%0.5f, scoresMean:%0.5f, scoresStd:%0.5f ] \n", ...
        executionId, elapsed, args, sum(tf), mdl.ScoreThreshold, mean(scores), std(scores));
end

%% PREPARING EXECUTION

if ~exist(anomalousAudioResultDir, 'dir'); mkdir(anomalousAudioResultDir); end

mtx = load(sprintf("%s/%s", templatesDirPath, matrixFeaturesName));
data = mtx.data;
audioDataMtx = load(sprintf("./%s/audio_data.mat", labelsDir));
audioData = audioDataMtx.audioData;

if size(data,2) ~= (featuresCount*featSize); error("invalid feature size"); end

%% FEATURES DEFINITION

function featuresIdxs = getFeaturesIdx(featSize)

featuresIdxs.allFeaturesIdxs = 1:(featSize*11);

featuresIdxs.spectralCentroidIdxs = 1:featSize;
featuresIdxs.spectralCrestFactorIdxs = (featSize*1+1):(featSize*2);
featuresIdxs.spectralDecreaseIdxs = (featSize*2+1):(featSize*3);
featuresIdxs.spectralFlatnessIdxs = (featSize*3+1):(featSize*4);
featuresIdxs.spectralFluxIdxs = (featSize*4+1):(featSize*5);
featuresIdxs.spectralRolloffIdxs = (featSize*5+1):(featSize*6);
featuresIdxs.spectralSpreadIdxs = (featSize*6+1):(featSize*7);
featuresIdxs.spectralTonalPowerRatioIdxs = (featSize*7+1):(featSize*8);
featuresIdxs.timeZeroCrossingRateIdxs = (featSize*8+1):(featSize*9);
featuresIdxs.timeAcfCoeffIdxs = (featSize*9+1):(featSize*10);
featuresIdxs.timeMaxAcfIdxs = (featSize*10+1):(featSize*11);

featuresIdxs.featuresSpectralIdxs = [
    featuresIdxs.spectralCentroidIdxs, ...
    featuresIdxs.spectralDecreaseIdxs, ...
    featuresIdxs.spectralFluxIdxs, ...
    featuresIdxs.spectralRolloffIdxs, ...
    featuresIdxs.spectralSpreadIdxs ...
];
featuresIdxs.featuresTonalessIdxs = [
    featuresIdxs.spectralCrestFactorIdxs, ...
    featuresIdxs.spectralFlatnessIdxs, ...
    featuresIdxs.spectralTonalPowerRatioIdxs
];
featuresIdxs.featuresTimeIdxs = [
    featuresIdxs.timeZeroCrossingRateIdxs, 
    featuresIdxs.timeAcfCoeffIdxs, 
    featuresIdxs.timeMaxAcfIdxs
    ];

featuresIdxs.featuresAvgSpectralIdxs = [1, 3, 5, 6, 7];
featuresIdxs.featuresAvgTonalessIdxs = [2, 4, 8];
featuresIdxs.featuresAvgTimeIdxs = [9, 10, 11];
end

function featuresMean = calcFeaturesMean(data, featuresCount) 
    rowsSize = size(data, 1);
    featSize = size(data, 2) / featuresCount;
    featuresMean = zeros(rowsSize, 11);
    for j = 1 : rowsSize
        for i = 0 : (featuresCount-1)
            featuresMean(j, i+1) = mean(data(j, (featSize*i+1):(featSize*(i+1))));
        end
    end
end

function commonValues = multiIntersect(arrays)
    commonValues = arrays{1};
    for i = 2:length(arrays)
        commonValues = intersect(commonValues, arrays{i});
    end
end

%% MULTITHREADING
%
ticWorkers = tic;
fprintf("> try to init workers \n");
% overriding workers
localCluster = parcluster('local');
localCluster.NumWorkers = threadsCount;
saveProfile(localCluster);
% retrieving pool if exists
pool = gcp('nocreate');
if isempty(pool)
    fprintf('> no existing pool found, creating new pool with %d workers\n', threadsCount);
    parpool('local', threadsCount);
else    
    if pool.NumWorkers == threadsCount
        fprintf('> using existing pool with %d workers\n', pool.NumWorkers);
    else
        fprintf('> existing pool has %d workers, deleting it\n', pool.NumWorkers);
        delete(pool);
        parpool('local', threadsCount);
        fprintf('> created new pool with %d workers\n', threadsCount);
    end
end
elapsed = toc(ticWorkers);
fprintf('> startup %d workers in %.4f sec\n', threadsCount, elapsed);

%}

%% SHOW FOREST CHART
%{
mtx = load(sprintf("%s/%s", templatesDirPath, matrixFeaturesName));
iForestChartData = myIforest("chart", data);
figure;
histogram(iForestChartData.scores);
title("IForest - trees 100");
xlabel("scores");
ylabel("occurences");
xline(iForestChartData.mdl.ScoreThreshold,"r-",["Threshold" iForestChartData.mdl.ScoreThreshold]);
savefig(sprintf('%s/%s_%s.fig', anomalousAudioDir, "anomalies_histogram", sampleRate));
%}

%% RETRIEVE CONTAMINATION PERCENTAGE FROM SCORES
%{
mtx = load(sprintf("%s/%s", templatesDirPath, matrixFeaturesName));
contamination = 0.01;
iForRes = myIforest("test", data, ContaminationFraction=contamination);
anomaliesIdx = find(iForRes.tf == 1);
threshold = quantile(iForRes.scores, 1 - contamination);
tfReplica = iForRes.scores > threshold;
anomaliesReplicaIdx = find(tfReplica == 1);
%}

%% COPYING ALL ANOMALOUS DATA
%{
    anomalousAudioData = audioDataMtx.audioData(anomalousAudioFilteredIdx, :);
    for j = 1:size(anomalousAudioData, 1)
        audioDataFileName = anomalousAudioData{j, AudioDataColumnIndex.AudioName.index};
        yat = anomalousAudioData{j, AudioDataColumnIndex.Yat.index};

        sourceAudioPath = sprintf("%s/YAT%dAudible/%s", audioDir, yat, audioDataFileName);
        anomalousAudioPath = sprintf("%s/contamination_%0.2f/YAT%dAudible/", anomalousAudioResultDir, c, yat);

        if ~exist(anomalousAudioPath, 'dir'); mkdir(anomalousAudioPath); end
        copyfile(sourceAudioPath, anomalousAudioPath, 'f');
    end
%}

%% MIX MULTIPLE RESULT ALL FEATURES
%
function stdData = standardizeData(data)
    a = std(data);
    keep = a > 0;
    data = data(:,keep);
    stdData = zscore(data);
end

function resultsTable = writeAnomaliesInFile(algoType, samplingRate, checkType, audioData, data, standardize, conf)
    algoLabel = ["iforest","lof","ocsvm"];

    rowsSize = size(data, 1);
    
    if standardize
        data = standardizeData(data);
    end

    results = zeros(rowsSize, conf.executionCount);
    parfor i = 1:conf.executionCount
        executionId = sprintf("%s, execution %d started", checkType, i);
        switch algoType
            case 0 % iforest
                fprintf("> %s: iforest \n", executionId);
                mdl = myIforest(executionId, data);                
            case 1 % local outlier factor
                fprintf("> %s: local outlier factor \n", executionId);
                mdl = myLof(executionId, data);
            case 2 % ocsvm
                fprintf("> %s: ocsvm \n", executionId);
                mdl = myOcsvm(executionId, data);
            otherwise
                error("Algo type %s not supported!", algoType);
        end
        results(:, i) = mdl.scores;
    end
    resultsMean = mean(results, 2);
    
    % rows
    algoTypes(1:rowsSize, 1) = algoLabel(algoType+1);
    samplingRates(1:rowsSize, 1) = samplingRate;
    filesCount(1:rowsSize, 1) = rowsSize;
    checkType(1:rowsSize, 1) = checkType;
    rowIndex(1:rowsSize, 1) = num2cell(1:rowsSize);
    yats = audioData(:,AudioDataColumnIndex.Yat.index);
    years = audioData(:,AudioDataColumnIndex.Year.index);
    months = audioData(:,AudioDataColumnIndex.Month.index);
    days = audioData(:,AudioDataColumnIndex.Day.index);
    hours = audioData(:,AudioDataColumnIndex.Hour.index);
    minutes = audioData(:,AudioDataColumnIndex.Minute.index);
    audioNames = audioData(:,AudioDataColumnIndex.AudioName.index);
    resultsMeanCell = num2cell(resultsMean);
    audioUrl = cell(rowsSize, 1);
    uniqueNames = audioData(:,AudioDataColumnIndex.UniqueName.index);
    for i = 1:rowsSize
        audioUrl{i} = sprintf('%s/YAT%dAudible/%s', conf.baseAudioUrl, yats{i,1}, audioNames{i,1});
    end    
    rows = horzcat(algoTypes, samplingRates, filesCount, checkType, rowIndex, yats, years, months, days, hours, minutes, ...
        audioNames, resultsMeanCell, audioUrl, uniqueNames);
    % header
    header = ["AlgoType" "SmplRate" "#Files" "Check Type" "Index" "Yat" "Year" "Month" "Day" "Hour" "Minute" ...
        "AudioName" sprintf("ScoresMeanOn%d", conf.executionCount) "AudioUrl", "UniqueName"];

    % top scores
    [~, sortedIdx] = sort(resultsMean(:,1), 1, 'descend');
    rows = rows(sortedIdx, :);
    rows = rows(1:conf.topScoresCount, :);
    
    % write file with table
    resultsTable = array2table(rows, 'VariableNames', header);
    writetable(resultsTable, conf.resultFilePath, "WriteMode", "append");
end

function results = execIforest(samplingRate, checkType, audioData, data, standardize, conf)
    results = writeAnomaliesInFile(0, samplingRate, checkType, audioData, data, standardize, conf);
end
function results = execLocalOutlierFactor(samplingRate, checkType, audioData, data, standardize, conf)
    results = writeAnomaliesInFile(1, samplingRate, checkType, audioData, data, standardize, conf);
end
function results = execOcsvm(samplingRate, checkType, audioData, data, standardize, conf)
    results = writeAnomaliesInFile(2, samplingRate, checkType, audioData, data, standardize, conf);
end


featuresMean = calcFeaturesMean(data, featuresCount);

% removing old result file path
resultFilePath = sprintf("%s/anomalies_result_%s_top_scores.csv", anomalousAudioDir, sampleRate);
delete(resultFilePath);

% executing anomaly detection for multiple 
function writeAnomalies(algoType, sampleRate, audioData, data, featuresMean, featuresCount, featSize, featIdxs, standardize, conf)
    dataTypes = [ "normal" "zscore" ];
    dataType = dataTypes(standardize+1);

    writeAnomaliesInFile(algoType, sampleRate, "conc feat all (" + dataType + ")", audioData, data(:,featIdxs.allFeaturesIdxs), standardize, conf);
    writeAnomaliesInFile(algoType, sampleRate, "conc feat spectral (" + dataType + ")", audioData, data(:,featIdxs.featuresSpectralIdxs), standardize, conf);
    writeAnomaliesInFile(algoType, sampleRate, "conc feat spectral (" + dataType + ")", audioData, data(:,featIdxs.featuresTonalessIdxs), standardize, conf);
    writeAnomaliesInFile(algoType, sampleRate, "conc feat time (" + dataType + ")", audioData, data(:,featIdxs.featuresTimeIdxs), standardize, conf);
    writeAnomaliesInFile(algoType, sampleRate, "conc avg feat all (" + dataType + ")", audioData, featuresMean(:,1:(featuresCount)), standardize, conf);
    writeAnomaliesInFile(algoType, sampleRate, "conc avg feat spectral (" + dataType + ")", audioData, featuresMean(:,featIdxs.featuresAvgSpectralIdxs), standardize, conf);
    writeAnomaliesInFile(algoType, sampleRate, "conc avg feat tonaless (" + dataType + ")", audioData, featuresMean(:,featIdxs.featuresAvgTonalessIdxs), standardize, conf);
    writeAnomaliesInFile(algoType, sampleRate, "conc avg feat time (" + dataType + ")", audioData, featuresMean(:,featIdxs.featuresAvgTimeIdxs), standardize, conf);
    for i = 0 : (featuresCount-1)
        featureName = Features.getEnumByIndex(i+1).Name;
        features = (featSize*i+1):(featSize*(i+1));
        writeAnomaliesInFile(algoType, sampleRate, sprintf("feature '%s' (%s)", featureName, dataType), audioData, data(:,features), standardize, conf);
    end
end

stdOff = 0;
stdOn = 1;
conf.executionCount = 1;
conf.resultFilePath = resultFilePath;
conf.baseAudioUrl = baseAudioUrl;
conf.topScoresCount = 10;

featIdxs = getFeaturesIdx(featSize);

% fprintf("\n--- SEARCHING ANOMALIES NORMAL ------------------------\n");
% writeAnomalies(0, sampleRate, audioData, data, featuresMean, featuresCount, featSize, featIdxs, stdOff, conf);
% fprintf("\n--- SEARCHING ANOMALIES WITH STANDARDIZATION ----------\n");
% writeAnomalies(0, sampleRate, audioData, data, featuresMean, featuresCount, featSize, featIdxs, stdOn, conf);


%  -------   SUBSET DATA yat1, march, h 2, 6, 10, 14, 18, 22, mm 00  test -----------------------------

% test1 yat1,march,2/6/10/14/18/22,00
uniqueNameColumn = AudioDataColumnIndex.UniqueName.index;
yatColumn = AudioDataColumnIndex.Yat.index;
yearColumn = AudioDataColumnIndex.Year.index;
monthColumn = AudioDataColumnIndex.Month.index;
dayColumn = AudioDataColumnIndex.Day.index;
hourColumn = AudioDataColumnIndex.Hour.index;
minuteColumn = AudioDataColumnIndex.Minute.index;

yatsColumnData = cell2mat(audioData(:, yatColumn));
yat1Idxs = find(yatsColumnData == 1);
monthColumnData = cell2mat(audioData(:, monthColumn));
monthIdxs = find(monthColumnData == 3);
hoursColumnData = cell2mat(audioData(:, hourColumn));
hourValues = [2, 6, 10, 14, 18, 22];
hourIdxs = find(ismember(hoursColumnData, hourValues) == 1);
minutesColumnData = cell2mat(audioData(:, minuteColumn));
minutesValues = find(minutesColumnData == 0);

filteredYat1Idxs = multiIntersect({yat1Idxs, monthIdxs, hourIdxs, minutesValues});
dataFiltered = data(filteredYat1Idxs , :);
featuresMean = calcFeaturesMean(dataFiltered, featuresCount);
audioDataFiltered = audioData(filteredYat1Idxs , :);

conf.executionCount = 30;
conf.topScoresCount = 3;
conf.resultFilePath = sprintf("%s/anomalies_detection_result_%s_all_features_all_algo.csv", anomalousAudioDir, sampleRate);
delete(conf.resultFilePath);

dataType = "zscore";
% iforest std off/on
writeAnomalies(0, sampleRate, audioDataFiltered, dataFiltered, featuresMean, featuresCount, featSize, featIdxs, stdOff, conf);
writeAnomalies(0, sampleRate, audioDataFiltered, dataFiltered, featuresMean, featuresCount, featSize, featIdxs, stdOn, conf);
% lof std off/on
writeAnomalies(1, sampleRate, audioDataFiltered, dataFiltered, featuresMean, featuresCount, featSize, featIdxs, stdOff, conf);
writeAnomalies(1, sampleRate, audioDataFiltered, dataFiltered, featuresMean, featuresCount, featSize, featIdxs, stdOn, conf);
% ocssm std off/on
writeAnomalies(2, sampleRate, audioDataFiltered, dataFiltered, featuresMean, featuresCount, featSize, featIdxs, stdOff, conf);
writeAnomalies(2, sampleRate, audioDataFiltered, dataFiltered, featuresMean, featuresCount, featSize, featIdxs, stdOn, conf);


% TEST 2: prendere un audio veicolo e altri che non lo presentano per
% vedere se viene rilevato come anomalia
%{
dataSounds = readtable(".labels/audio_data_identified_with_labels.dat");
idxsVehicle = find(dataSounds.vehicle == 1);
idxsNoVehicle = setdiff(1:size(dataSounds.vehicle,1), find(dataSounds.vehicle == 1));

audioNoVehicle = featuresMean(idxsNoVehicle,:);
matches = 0;
conf.topScoresCount = 3;
for i = 1:length(idxsVehicle)
    audioName = audioData{i, uniqueNameColumn};
    idxVehicle = idxsVehicle(i,:);
    audioVehicle = featuresMean(idxVehicle,:);
    
    data1 = vertcat(audioVehicle, audioNoVehicle);
    audioData1 = vertcat(audioData(idxVehicle,:), audioData(idxsNoVehicle,:));
    res = execIforest(sampleRate, sprintf("conc avg feat all (%)", dataType), audioData1, data1(:,1:(featuresCount)), standardize, conf);

    for j=1:size(res,1)
        row = res(j,:);
        if row.UniqueName == audioName
            matches = matches + 1;
        end
    end
end
%}


disp("> EXECUTION COMPLETE");
%}


%% CHARTS
%{
dataSounds = readtable(sprintf("./%s/audio_data_identified_with_labels.dat", labelsDir));

allSounds = [dataSounds.vehicle, dataSounds.birds, dataSounds.crickets, dataSounds.river_waterfall, dataSounds.rain, dataSounds.thunder, dataSounds.noise, dataSounds.unknown];
time = datetime(dataSounds.year, dataSounds.month, dataSounds.day, dataSounds.hours, dataSounds.minutes, dataSounds.seconds);

% figure;
% heatmap(time, {'Vehicle', 'Birds', 'Crickets', 'River/Waterfall', 'Rain', 'Thunder', 'Noise', 'Unknown'}, allSounds');
% xlabel('Time');
% ylabel('Sound Type');
% title('Heatmap of Sound Presence Over Time');

% figure;
% bar(time, allSounds, 'stacked');
% xlabel('Time');
% ylabel('Presence');
% legend({'Vehicle', 'Birds', 'Crickets', 'River/Waterfall', 'Rain', 'Thunder', 'Noise', 'Unknown'});
% title('Stacked Bar Chart of Sound Presence Over Time');

% vehicle_presence = find(dataSounds.vehicle==1);
% unique_hours = unique(dataSounds.hours); % Trova le ore uniche
% figure;
% hold on;
% scatter(dataSounds.day(vehicle_presence), dataSounds.hours(vehicle_presence), 100, 'filled');
% xlabel('Giorni di Marzo');
% ylabel('Ore del Giorno');
% yticks(unique_hours); % Imposta i tick dell'asse y alle ore uniche
% yticklabels({'02:00', '06:00', '10:00', '14:00', '18:00', '22:00'}); % Etichette delle ore
% title('Presenza del Suono dei Veicoli in Marzo');
% hold off;

% 
% vehicle_presence = dataSounds.vehicle;
% days_of_march = sort(unique(dataSounds.day));
% vehicle_counts = zeros(1, 31);
% % for day = days_of_march'
%     vehicle_counts(day) = sum(vehicle_presence(dataSounds.day == day));
% end
% figure;
% bar(days_of_march, vehicle_counts, 'FaceColor', [0.2, 0.6, 0.8]);
% xlabel('Giorni di Marzo');
% ylabel('Numero di Momenti (ogni 4 ore) con Suono dei Veicoli');
% title('Presenza del Suono dei Veicoli in Marzo');
% xlim([1 31]);
% ylim([0 6]);
% grid on;

% percentage of sound for each hour
% allSounds = [dataSounds.vehicle, dataSounds.birds, dataSounds.crickets, dataSounds.river_waterfall, dataSounds.rain, dataSounds.thunder, dataSounds.noise, dataSounds.unknown];
% soundColumns = {'Vehicle', 'Birds', 'Crickets', 'River/Waterfall', 'Rain', 'Thunder', 'Noise', 'Unknown'};
% numSounds = length(soundColumns);
% 
% uniqueHours = unique(dataSounds.hours);
% numHours = length(uniqueHours);
% 
% percentages = zeros(numHours, numSounds);
% 
% for i = 1:numHours
%     hour = uniqueHours(i);
%     totalRecords = sum(dataSounds.hours == hour);
%     for j = 1:numSounds
%         soundData = allSounds(:, j);
%         percentages(i, j) = sum(soundData(dataSounds.hours == hour)) / totalRecords * 100;
%     end
% end
% 
% figure;
% hold on;
% bar(uniqueHours, percentages, 'grouped');
% xlabel('Hours');
% ylabel('% per hours');
% title('Sound per hours');
% xticks(uniqueHours);
% xticklabels({'02:00', '06:00', '10:00', '14:00', '18:00', '22:00'});
% legend(soundColumns, 'Location', 'northeastoutside');
% grid on;
% hold off;

% percentage of sound on month
% soundColumns = {'Vehicle', 'Birds', 'Crickets', 'River/Waterfall', 'Rain', 'Thunder', 'Noise', 'Unknown'};
% numSounds = length(soundColumns);
% 
% percentages = zeros(1, numSounds);
% totalRecords = size(allSounds,1);
% 
% for j = 1:numSounds
%     soundData = allSounds(:, j);
%     percentages(1, j) = sum(soundData) / totalRecords * 100;
% end
% 
% figure;
% hold on;
% b = bar(soundColumns, percentages);
% xlabel('Sound');
% ylabel('%');
% title('% sound in the month');
% xlegend(soundColumns, 'Location', 'northeastoutside');
% grid on;
% hold off;

%}



