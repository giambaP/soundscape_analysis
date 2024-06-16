clc; close all; clear all;

%% CONFIGURATION

clearResultDir = 1;
fsType = "fs0X";
audioDir = "../downloadAllAudible/datasetAll";
labelsDir = './labels';
anomalousAudioDir = "./anomalousAudioData";
anomalousAudioResultDir = sprintf("./%s/result", anomalousAudioDir);
templatesDirPath = sprintf("./templates_%ss", fsType);
matrixFeaturesName = "matrixAllFeatures.mat";
% baseUrl = "http://colecciones.humboldt.org.co/rec/sonidos/publicaciones/MAP/JDT-Yataros/YAT3Audible/20200301_000000.WAV"
baseUrl = "http://colecciones.humboldt.org.co/rec/sonidos/publicaciones/MAP/JDT-Yataros";

%% FUNCTIONS

% Wrap of Iforest function:
%   arg: CategoricalPredictors - sublist to process, default []
%   arg: ContaminationFraction - threshold of suspected objs to consider anomalies, default 0
%   arg: NumLearners - trees count, default 100
function result = myIforest(X, varargin)
args = "";
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

fprintf("iforest START - args [ %s ] \n", args);
ticIForest = tic;

[mdl, tf, scores] = iforest(X, varargin{:});
result = struct('mdl', mdl, 'tf', tf, 'scores', scores);
threshold = mdl.ScoreThreshold;
scoresMean = mean(scores);
scoresStd = std(scores);
countAnomalies = sum(tf);

elapsed = toc(ticIForest);
fprintf("iforest result { threshold: %0.5f, anomalies: %d, scores mean: %0.5f, scores std: %0.5f } \n", threshold, countAnomalies, scoresMean, scoresStd);
fprintf("iforest END, %0.5f s \n", elapsed);
end


%% PREPARING EXECUTION

if ~exist(anomalousAudioResultDir, 'dir'); mkdir(anomalousAudioResultDir); end


%% EXECUTION

mtx = load(sprintf("%s/%s", templatesDirPath, matrixFeaturesName));

% SHOW FOREST CHART
% iForestChartData = myIforest(mtx.data);
% figure;
% histogram(iForestChartData.scores);
% title("IForest - trees 100, no contamination");
% xline(iForestChartData.mdl.ScoreThreshold,"r-",["Threshold" iForestChartData.mdl.ScoreThreshold]);

% COMPARISON OF DIFFERENT TREES
% disp("> Comparison different trees: ");
% iforTree100 = myIforest(mtx.data, ContaminationFraction=0.03, NumLearners=100);
% iforTree200 = myIforest(mtx.data, ContaminationFraction=0.03, NumLearners=200);
% iforTree300 = myIforest(mtx.data, ContaminationFraction=0.03, NumLearners=300);
% iforTree300 = myIforest(mtx.data, ContaminationFraction=0.03, NumLearners=400);
% if ~isequal(iforTree100.tf, iforTree200.tf); disp("100 vs 200 NOT EQUAL");
% elseif ~isequal(iforTree100.tf, iforTree300.tf); disp("100 vs 200 NOT EQUAL");
% elseif ~isequal(iforTree100.tf, iforTree400.tf); disp("100 vs 200 NOT EQUAL");
% else; disp("100, 200, 300, 400 trees have same results");
% end

% RETRIEVE CONTAMINATION PERCENTAGE FROM SCORES
% contamination = 0.01;
% iForRes = myIforest(mtx.data, ContaminationFraction=contamination);
% anomaliesIdx = find(iForRes.tf == 1);
% threshold = quantile(iForRes.scores, 1 - contamination);
% tfReplica = iForRes.scores > threshold;
% anomaliesReplicaIdx = find(tfReplica == 1);

% COPYING ALL ANOMALOUS DATA
% clearing anomalous audio dir
% if clearResultDir && isfolder(anomalousAudioResultDir)
%     rmdir(sprintf("%s", anomalousAudioResultDir), "s");
% end
%
% % iforest with different contamination params
% audioDataMtx = load(sprintf("./%s/audio_data.mat", labelsDir));
% allAnomalousAudioIdx = []; %zeros(0, 2);
% contaminationParams = 0.01:0.01:1;
% iForRes = myIforest(mtx.data);
% for c = contaminationParams
%     threshold = quantile(iForRes.scores, 1 - c);
%     tf = iForRes.scores > threshold;
%     anomalousAudioIdx = find(tf == 1);
%
%     % filtering indexes already processed
%     anomalousAudioFilteredIdx = setdiff(anomalousAudioIdx, allAnomalousAudioIdx);
%     % updating all array with new indexes
%     allAnomalousAudioIdx = sort(vertcat(anomalousAudioFilteredIdx, allAnomalousAudioIdx));
%
%     % copying audio to anomalous audio dir
%     anomalousAudioData = audioDataMtx.audioData(anomalousAudioFilteredIdx, :);
%     for j = 1:size(anomalousAudioData, 1)
%         audioDataFileName = anomalousAudioData{j, AudioDataColumnIndex.AudioName.index};
%         yat = anomalousAudioData{j, AudioDataColumnIndex.Yat.index};
%
%         sourceAudioPath = sprintf("%s/YAT%dAudible/%s", audioDir, yat, audioDataFileName);
%         anomalousAudioPath = sprintf("%s/contamination_%0.2f/YAT%dAudible/", anomalousAudioResultDir, c, yat);
%
%         if ~exist(anomalousAudioPath, 'dir'); mkdir(anomalousAudioPath); end
%         copyfile(sourceAudioPath, anomalousAudioPath, 'f');
%     end
% end

% MIX MULTIPLE RESULT 9000x1936
executionCount = 20;
objCount = size(mtx.data, 1);
results = cell(objCount, executionCount * 2); % 2 values per execution: contamination, score
for e = 1:executionCount
    allAnomalousAudioIdx = [];
    fprintf("execution %3d\n",i);
    iForRes = myIforest(mtx.data);

    contaminationParams = 0.01:0.01:1;
    for c = contaminationParams
        threshold = quantile(iForRes.scores, 1 - c);
        tf = iForRes.scores > threshold;
        anomalousAudioIdx = find(tf == 1);

        % filtering indexes already processed
        anomalousAudioFilteredIdx = setdiff(anomalousAudioIdx, allAnomalousAudioIdx);
        % updating all array with new indexes
        allAnomalousAudioIdx = sort(vertcat(anomalousAudioFilteredIdx, allAnomalousAudioIdx));

        filteredScores = iForRes.scores(anomalousAudioFilteredIdx);
        results(anomalousAudioFilteredIdx, (e * 2)-1) = num2cell(c * ones(size(anomalousAudioFilteredIdx, 1), 1));
        results(anomalousAudioFilteredIdx, (e * 2) ) = num2cell(filteredScores);
    end
end

audioDataMtx = load(sprintf("./%s/audio_data.mat", labelsDir));

rowIndex = cell(objCount, 1);
rowIndex(1:objCount, 1) = num2cell(1:objCount);
yats = audioDataMtx.audioData(:,AudioDataColumnIndex.Yat.index);
audioNames = audioDataMtx.audioData(:,AudioDataColumnIndex.AudioName.index);

headerContamination = cell(1, length(0:2:((executionCount * 2)-1)));
for i = 1:length(headerContamination)
    headerContamination{i} = sprintf('Cont_%d', i);
end
headerScores = cell(1, length(1:2:(executionCount * 2)));
for i = 1:length(headerScores)
    headerScores{i} = sprintf('Score_%d', i);
end
additionalColumnsBefore = 3;
additionalColumnsAfter = 1;
% index, yat, audioName, (contamination/score)-> 2*n, url 
header = strings(1, additionalColumnsBefore + (executionCount * 2) + additionalColumnsAfter); 
header(1, 1:3) = [{"Index"} {"Yat"} {"AudioName"}];
header(1, additionalColumnsBefore + ((0 + 1):2:(executionCount * 2))) = headerContamination;
header(1, additionalColumnsBefore + ((1 + 1):2:(executionCount * 2))) = headerScores;
header(1, end) = {"AudioUrl"};

audioUrl = cell(objCount, 1);
for i = 1:objCount
    yat = audioDataMtx.audioData(i,AudioDataColumnIndex.Yat.index);
    audioName = audioDataMtx.audioData(i,AudioDataColumnIndex.AudioName.index);
    audioUrl{i} = sprintf('%s/YAT%dAudible/%s', baseUrl, yats{i,1}, audioNames{i,1});
end

rows = horzcat(rowIndex, yats, audioNames, results, audioUrl);
resultsTable = cell2table(rows, 'VariableNames', header);
writetable(resultsTable, sprintf('%s/%s_%s.csv', anomalousAudioDir, "anomalies_result", fsType));