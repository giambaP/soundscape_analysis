clc; close all; clear all;

%% CONFIGURATION

featuresCount = 11;
featSize = 176;
fsType = "fs0X";

audioDir = "../downloadAllAudible/datasetAll";
labelsDir = './labels';
anomalousAudioDir = "./anomalousAudioData";
anomalousAudioResultDir = sprintf("./%s/result", anomalousAudioDir);
templatesDirPath = sprintf("./templates_%ss", fsType);
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


%% PREPARING EXECUTION

if ~exist(anomalousAudioResultDir, 'dir'); mkdir(anomalousAudioResultDir); end

mtx = load(sprintf("%s/%s", templatesDirPath, matrixFeaturesName));
data = mtx.data;
audioDataMtx = load(sprintf("./%s/audio_data.mat", labelsDir));
audioData = audioDataMtx.audioData;

if size(data,2) ~= (featuresCount*featSize); error("invalid feature size"); end

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
savefig(sprintf('%s/%s_%s.fig', anomalousAudioDir, "anomalies_histogram", fsType));
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

function results = writeAnomaliesInFile(checkType, audioData, data, standardize, conf)
    rowsSize = size(data, 1);
    
    if standardize
        data = standardizeData(data);
    end

    results = zeros(rowsSize, conf.executionCount);
    parfor i = 1:conf.executionCount
        executionId = sprintf("%s, execution %d started", checkType, i);
        fprintf("> %s: iforest \n", executionId);
        iForRes = myIforest(executionId, data);
        results(:, i) = iForRes.scores;
    end
    resultsMean = mean(results, 2);
    
    % header
    header = ["Check Type" "Index" "Yat" "Year" "Month" "Day" "Hour" "Minute" ...
        "AudioName" sprintf("ScoresMeanOn%d", conf.executionCount) "AudioUrl"];
    % rows
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
    for i = 1:rowsSize
        audioUrl{i} = sprintf('%s/YAT%dAudible/%s', conf.baseAudioUrl, yats{i,1}, audioNames{i,1});
    end    
    rows = horzcat(checkType, rowIndex, yats, years, months, days, hours, minutes, audioNames, resultsMeanCell, audioUrl);
    
    % top scores
    [~, sortedIdx] = sort(resultsMean(:,1), 1, 'descend');
    rows = rows(sortedIdx, :);
    rows = rows(1:conf.topScoresCount, :);
    
    % write file with table
    resultsTable = array2table(rows, 'VariableNames', header);
    writetable(resultsTable, conf.resultFilePath, "WriteMode", "append");
end

% basic configuration
allFeaturesIdxs = 1:(featSize*11);

spectralCentroidIdxs = 1:featSize;
spectralCrestFactorIdxs = (featSize*1+1):(featSize*2);
spectralDecreaseIdxs = (featSize*2+1):(featSize*3);
spectralFlatnessIdxs = (featSize*3+1):(featSize*4);
spectralFluxIdxs = (featSize*4+1):(featSize*5);
spectralRolloffIdxs = (featSize*5+1):(featSize*6);
spectralSpreadIdxs = (featSize*6+1):(featSize*7);
spectralTonalPowerRatioIdxs = (featSize*7+1):(featSize*8);
timeZeroCrossingRateIdxs = (featSize*8+1):(featSize*9);
timeAcfCoeffIdxs = (featSize*9+1):(featSize*10);
timeMaxAcfIdxs = (featSize*10+1):(featSize*11);

featuresSpectralIdxs = [spectralCentroidIdxs, spectralDecreaseIdxs, spectralFluxIdxs, spectralRolloffIdxs, spectralSpreadIdxs];
featuresTonalessIdxs = [spectralCrestFactorIdxs, spectralFlatnessIdxs, spectralTonalPowerRatioIdxs];
featuresTimeIdxs = [timeZeroCrossingRateIdxs, timeAcfCoeffIdxs, timeMaxAcfIdxs];

featuresAvgSpectralIdxs = [1, 3, 5, 6, 7];
featuresAvgTonalessIdxs = [2, 4, 8];
featuresAvgTimeIdxs = [9, 10, 11];

rowsSize = size(data, 1);

% average features
featuresMean = zeros(rowsSize, 11);
for j = 1 : rowsSize
    for i = 0 : (featuresCount-1)
        featuresMean(j, i+1) = mean(data(j, (featSize*i+1):(featSize*(i+1))));
    end
end
disp("> features mean completed\n");

% removing old result file path
resultFilePath = sprintf("%s/anomalies_result_%s_top_scores.csv", anomalousAudioDir, fsType);
delete(resultFilePath);

% executing anomaly detection
function writeAnomalies(audioData, data, featuresMean, featuresCount, standardize, conf)
    dataTypes = [ "normal" "zscore" ];
    dataType = dataTypes(standardize+1);

    % writeAnomaliesInFile("conc feat all (" + dataType + ")", audioData, data(:,allFeaturesIdxs), standardize, conf);
    % writeAnomaliesInFile("conc feat spectral (" + dataType + ")", audioData, data(:,featuresSpectralIdxs), standardize, conf);
    % writeAnomaliesInFile("conc feat spectral (" + dataType + ")", audioData, data(:,featuresTonalessIdxs), standardize, conf);
    % writeAnomaliesInFile("conc feat time (" + dataType + ")", audioData, data(:,featuresTimeIdxs), standardize, conf);
    writeAnomaliesInFile("conc avg feat all (" + dataType + ")", audioData, featuresMean(:,1:(featuresCount)), standardize, conf);
    % writeAnomaliesInFile("conc avg feat spectral (" + dataType + ")", audioData, featuresMean(:,featuresAvgSpectralIdxs), standardize, conf);
    % writeAnomaliesInFile("conc avg feat tonaless (" + dataType + ")", audioData, featuresMean(:,featuresAvgTonalessIdxs), standardize, conf);
    % writeAnomaliesInFile("conc avg feat time (" + dataType + ")", audioData, featuresMean(:,featuresAvgTimeIdxs), standardize, conf);
    % for i = 0 : (featuresCount-1)
    %     featureName = Features.getEnumByIndex(i+1).Name;
    %     features = (featSize*i+1):(featSize*(i+1));
    %     writeAnomaliesInFile(sprintf("feature '%s' (%s)", featureName, dataType), audioData, data(:,features), standardize, conf);
    % end
end

% filtering data
%

%}

stdOff = 0;
stdOn = 1;
conf.executionCount = 30;
conf.resultFilePath = resultFilePath;
conf.baseAudioUrl = baseAudioUrl;
conf.topScoresCount = 10;

% fprintf("\n--- SEARCHING ANOMALIES NORMAL ------------------------\n");
% writeAnomalies(audioData, data, featuresMean, featuresCount, stdOff, conf);

fprintf("\n--- SEARCHING ANOMALIES WITH STANDARDIZATION ----------\n");
writeAnomalies(audioData, data, featuresMean, featuresCount, stdOn, conf);



%}