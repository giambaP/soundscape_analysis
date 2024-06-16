clc; close all; clear all;

%% CONFIGURATION

audioDir = "../downloadAllAudible/datasetAll";
labelsDir = './labels';
anomalousAudioDir = "./anomalousAudio";
templatesDirPath = "./templates_fs0Xs";
matrixFeaturesName = "matrixAllFeatures.mat";


%% FUNCTIONS

% Wrap of function Iforest
function [mdl, tf, scores] = myIforest(X, varargin)
args = "";
for i = 1:2:length(varargin)
    varName = varargin{1,i};
    varValue = varargin{1,i+1};
    placeHolder = "%s";
    if isnumeric(varValue); placeHolder = "%0.5f"; end
    args = strcat(args, sprintf(strcat(" %s = ", placeHolder, " "), varName, varValue));
    if i+1 ~= length(varargin); args = strcat(args, ", "); end        
end

fprintf("> iforest: START - [ %s ] \n", args);
ticIForest = tic;

[mdl, tf, scores] = iforest(X, varargin{:});

threshold = mdl.ScoreThreshold;
scoresMean = mean(scores);
scoresStd = std(scores);
countAnomalies = sum(tf);

elapsed = toc(ticIForest);
fprintf("\t threshold: %0.5f, anomalies: %d, scores mean: %0.5f, scores std: %0.5f \n", threshold, countAnomalies, scoresMean, scoresStd);
fprintf("> iforest: END, %0.5f s \n", elapsed);
end


%% PREPARING EXECUTION

if ~exist(anomalousAudioDir, 'dir'); mkdir(anomalousAudioDir); end


%% EXECUTION

% compare per features e gruppi di features
% compare per vari parametri di iforest
% compare per vari algoritmi
% incrociare tutto

mtx = load(sprintf("%s/%s", templatesDirPath, matrixFeaturesName));


% show iforest graph
[mdl, ~, scores] = myIforest(mtx.data);
histogram(scores);
xline(mdl.ScoreThreshold,"r-",["Threshold" mdl.ScoreThreshold]);


% clearing anomalous audio dir
rmdir(sprintf("%s/*", anomalousAudioDir), "s")

% iforest with different contamination params
audioDataMtx = load(sprintf("./%s/audio_data.mat", labelsDir));
allAnomalousAudioIdx = []; %zeros(0, 2);
contaminationParams = 0.01:0.01:0.05;
for c = contaminationParams
    [mdl, tf, scores] = myIforest(mtx.data, ContaminationFraction=c);

    % searching anomalous files
    anomalousAudioIdx = find(tf == 1);
    anomalousAudioData = audioDataMtx.audioData(anomalousAudioIdx, :);

    % filtering indexes already processed
    anomalousAudioIdx = setdiff(anomalousAudioIdx, allAnomalousAudioIdx);
    % updating all array with new indexes
    allAnomalousAudioIdx = sort(vertcat(anomalousAudioIdx, allAnomalousAudioIdx));

    % copying audio to anomalous audio dir
    for j = 1:size(anomalousAudioData, 1)
        audioDataFileName = anomalousAudioData{j, AudioDataColumnIndex.AudioName.index};
        yat = anomalousAudioData{j, AudioDataColumnIndex.Yat.index};

        sourceAudioPath = sprintf("%s/YAT%dAudible/%s", audioDir, yat, audioDataFileName);
        anomalousAudioPath = sprintf("%s/contamination_%0.2f/YAT%dAudible/", anomalousAudioDir, c, yat);

        if ~exist(anomalousAudioPath, 'dir'); mkdir(anomalousAudioPath); end
        copyfile(sourceAudioPath, anomalousAudioPath, 'f');
    end
end
