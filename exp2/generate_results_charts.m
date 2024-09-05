clc; clear all; close all;

%% CONFIGURATION

newLineLabel = '\newline';
chartsDir = "./result_charts";
labelsDir = './labels';

% source file result classification exp2
resultExp2DirPath = "./result_classification_exp2";
resultExp2For0XfsFileName = "result_classification_exp2_fs0Xsec.dat";
resultExp2For1fsFileName = "result_classification_exp2_fs1sec.dat";

% source file result classification with identified sounds
resultExp2IdentSoundDirPath = "./result_classification_exp2_identified_sound";
resultExp2IdentSoundForFs0xFileName = "result_classification_exp2_identified_sound_fs0Xs.dat";
resultExp2IdentSoundForFs0xSubsetBinaryFileName = "result_classification_exp2_identified_sound_fs0Xs_subset_binary.dat";
resultExp2IdentSoundForFs0xSubsetTertiaryFileName = "result_classification_exp2_identified_sound_fs0Xs_subset_tertiary.dat";
resultExp2IdentSoundForFs1sFileName = "result_classification_exp2_identified_sound_fs1s.dat";
resultExp2IdentSoundForFs1sSubsetBinaryFileName = "result_classification_exp2_identified_sound_fs1s_subset_binary.dat";
resultExp2IdentSoundForFs1sSubsetTertiaryFileName = "result_classification_exp2_identified_sound_fs1s_subset_tertiary.dat";

resultBestFilters0XfsDirPath = "./result_best_filters_0Xsec";
resultBestFilters1fsDirPath = "./result_best_filters_1sec";
bestFilter0XfsFileName = "result_best_filters_0Xsec_all.csv";
bestFilter1fsFileName = "result_best_filters_1sec_all.csv";

fsWindowTypes = [ "fs 0.x sec", "fs 1 sec" ];
dataStatus = ["normal", "standardized"];
featuresLabels = [
    "CONC.ORIG.", ...
    "CONC.SPE.", ...
    "CONC.TON.", ...
    "CONC.TEM.", ...
    "CONC.MED.ORIG.", ...
    "CONC.MED.SPE.", ...
    "CONC.MED.TON.", ...
    "CONC.MED.TEM.", ...
    "Spectral Centroid - SPE.", ...
    "Spectral Spread - SPE.", ...
    "Spectral Rolloff - SPE.", ...
    "Spectral Decrease - SPE.", ...
    "Spectral Flux - SPE.", ...
    "Spectral Crest Factor - TON.", ...
    "Spectral Flatness - TON.", ...
    "Spectral Tonal Power Ratio - TON.", ...
    "Time Zero Crossing Rate - TEM.", ...
    "Time Acf Coeff - TEM.", ...
    "Time Max Acf - TEM."
    ];
groupsLabels = [
    "PR-1.1  YAT", ...
    "PR-1.2  G/N", ...
    "PR-1.3  AT/R", ...
    "PR-1.4  A/T/G/N", ...
    "PR-1.5  M", ...
    "PR-1.6  MM"
    ];
groupsLabelsIdentifiedSound = [
    "PR-2.1.1  V", ...
    "PR-2.1.2  G", ...
    "PR-2.1.3  P", ...
    "PR-2.1.4  T"
    ];
groupsLabelsIdentifiedSoundBinary = [
    "PR-2.2.1  V/P", ...
    "PR-2.2.2  V/G", ...
    "PR-2.2.3  G/T", ...
    "PR-2.2.4  G/P"
    ];
groupsLabelsIdentifiedSoundTertiary = [
    "PR-2.3.1  V/G/P", ...
    "PR-2.3.2  V/G/T"
    ];

[f, g] = meshgrid(fsWindowTypes, dataStatus);
fsWindowTypesWithDataStatus = strcat(f(:), " - ", g(:));

[f, g] = meshgrid(groupsLabels, dataStatus);
groupLabelsWithDataTypes = strcat(f(:), " - ", g(:));


%% FUNCTION

function limit = calcLimit(arr, offset)
[minLimit, maxLimit] = calcLimitSep(arr, offset);
limit = [minLimit, maxLimit];
end
function [minLimit, maxLimit] = calcLimitSep(arr, offset)
minLimit = min(arr, [], "all")-offset;
maxLimit = max(arr, [], "all")+offset;
end

function saveChart(gcf, chartsDir, chartName)
targetFilePath = sprintf('%s/%s.jpg', chartsDir, chartName);
exportgraphics(gcf, targetFilePath, 'Resolution', 250);
%saveas(gcf, targetFilePath);
end

%% PREPARING CONTEXT

if ~exist(chartsDir, 'dir'); mkdir(chartsDir); end

% classification data
result0XfsTable = readtable(sprintf("%s/%s", resultExp2DirPath, resultExp2For0XfsFileName));
result1fsTable = readtable(sprintf("%s/%s", resultExp2DirPath, resultExp2For1fsFileName));
result0XfsData = result0XfsTable{:,:};
result1fsData = result1fsTable{:,:};

% classification data
result0XfsTable = readtable(sprintf("%s/%s", resultExp2IdentSoundDirPath, resultExp2IdentSoundForFs0xFileName));
result1fsTable = readtable(sprintf("%s/%s", resultExp2IdentSoundDirPath, resultExp2IdentSoundForFs1sFileName));
result0XfsIdentSoundData = result0XfsTable{:,:};
result1fsIdentSoundData = result1fsTable{:,:};
result0XfsBinaryTable = readtable(sprintf("%s/%s", resultExp2IdentSoundDirPath, resultExp2IdentSoundForFs0xSubsetBinaryFileName));
result1fsBinaryTable = readtable(sprintf("%s/%s", resultExp2IdentSoundDirPath, resultExp2IdentSoundForFs1sSubsetBinaryFileName));
result0XfsIdentSoundBinaryData = result0XfsBinaryTable{:,:};
result1fsIdentSoundBinaryData = result1fsBinaryTable{:,:};
result0XfsTertiaryTable = readtable(sprintf("%s/%s", resultExp2IdentSoundDirPath, resultExp2IdentSoundForFs0xSubsetTertiaryFileName));
result1fsTertiaryTable = readtable(sprintf("%s/%s", resultExp2IdentSoundDirPath, resultExp2IdentSoundForFs1sSubsetTertiaryFileName));
result0XfsIdentSoundTertiaryData = result0XfsTertiaryTable{:,:};
result1fsIdentSoundTertiaryData = result1fsTertiaryTable{:,:};


% classification with filter data
resultBestFilter0XfsTable = readtable(sprintf("%s/%s", resultBestFilters0XfsDirPath, bestFilter0XfsFileName));
resultBestFilter1fsTable = readtable(sprintf("%s/%s", resultBestFilters1fsDirPath, bestFilter1fsFileName));
% n.b first row header, second and third upper and lower filter, first
% column has feature selection 2-20 normal, 21-39 standardized
resultBestFilter0XfsData = table2array(resultBestFilter0XfsTable(:,2:end));
resultBestFilter1fsData = table2array(resultBestFilter1fsTable(:,2:end));


%% CLASSIFICATION: AVG ERROR BY LABEL TYPE - BAR GROUPS COMPACT
%
result0XfsMean = mean(result0XfsData, 1);
result1fsMean = mean(result1fsData, 1);
objects = 1:size(result0XfsData, 2);

figure("Name","Avg % error by label type");
hold on;

bar(horzcat(reshape(result0XfsMean, 2, [])', reshape(result1fsMean, 2, [])'));

title('LOO KNN - Errore medio per contesto', 'Interpreter','latex');
xlabel('Contesto', 'Interpreter','latex');
ylabel('Errore medio', 'Interpreter','latex');

ylim( calcLimit([result0XfsMean, result1fsMean], 0.01) );
set(gca, 'XTick', objects, 'XTickLabel', groupsLabels);
xtickangle(40);
legend(fsWindowTypesWithDataStatus, 'Location', 'northwest', 'Interpreter', 'latex', 'FontSize', 7);
grid on;
hold off;

saveChart(gcf, chartsDir, '1.chart_CLASS_CONTEXT_avg_error_per_label_type_small_bar');
%}

%% CLASSIFICATION: AVG ERROR BY FEATURE - BAR
%
result0XfsMean = mean(result0XfsData, 2);
result1fsMean = mean(result1fsData, 2);
objects = 1:size(result0XfsData, 1);

figure("Name","avg % error by feature");
hold on;

bar([result0XfsMean(:),result1fsMean(:)]);

title('LOO KNN - Class. prima fase - Errore medio per feature', "Interpreter",'latex');
xlabel('Features', "Interpreter",'latex');
ylabel('Errore medio', "Interpreter",'latex');

ylim( calcLimit([result0XfsMean, result1fsMean], 0.01) );
set(gca, 'XTick', objects, 'XTickLabel', featuresLabels, 'FontSize', 7);
xtickangle(40);
legend(fsWindowTypes, 'Location', 'northwest', 'Interpreter', 'latex');
grid on;
hold off;

saveChart(gcf, chartsDir, '2.chart_CLASS_FEATURE_classif_avg_error_per_feature_bar');
%}

%% CLASSIFICATION: AVG ERROR BY FEATURE DIVIDED BY NORMAL AND STD - BAR
%
problemsCount = size(result0XfsData, 2);
featGroupsCount = size(result0XfsData, 1);

normalDataRange = 1:2:(problemsCount-1);
stdDataRange = 2:2:problemsCount;

result0XfsNorMean = mean(result0XfsData(:,normalDataRange), 2);
result0XfsStdMean = mean(result0XfsData(:,stdDataRange), 2);
result1fsNorMean = mean(result1fsData(:,normalDataRange), 2);
result1fsStdMean = mean(result1fsData(:,stdDataRange), 2);

figure("Name","avg % error by feature for window and nor/std");
hold on;

bar(horzcat(result0XfsNorMean(:,:), result0XfsStdMean(:,:), ...
    result1fsNorMean(:,:), result1fsStdMean(:,:)), ...
    'EdgeColor', [0.4 0.4 0.4], ...
    'BarWidth', 0.8);    

title('LOO KNN - Class. prima fase - Errore medio per feature', "Interpreter",'latex');
xlabel('Features', "Interpreter",'latex');
ylabel('Errore medio', "Interpreter",'latex');

ylim( calcLimit([result0XfsNorMean, result0XfsStdMean, result1fsNorMean, result1fsStdMean], 0.01) );
set(gca, 'XTick', 1:featGroupsCount, 'XTickLabel', featuresLabels, 'FontSize', 7);
xtickangle(40);
legend(fsWindowTypesWithDataStatus, 'Location', 'northwest', 'Interpreter', 'latex');
grid on;
hold off;

saveChart(gcf, chartsDir, '2.1.chart_CLASS_FEATURE_classif_avg_error_per_feature_bar_with_data_status');
%}

%% SEARCH BEST FILTER: AVG ERROR BY FILTER ORDER BY UPPER - PLOT
%
% retrieving labels 
upperFilter = resultBestFilter0XfsData(1, :);
lowerFilter = resultBestFilter0XfsData(2, :);
% sorting from upper filter
[upperFilter, sortIdxs] = sort(upperFilter);
lowerFilter = lowerFilter(sortIdxs);
resultBestFilter0XfsDataSorted = resultBestFilter0XfsData(:,sortIdxs);
resultBestFilter1fsDataSorted = resultBestFilter1fsData(:,sortIdxs);

labels = strcat(num2str(lowerFilter'), ' - ', num2str(upperFilter'));

% skip filter rows
bestFiltersData0XfsNoFiltersRows = resultBestFilter0XfsDataSorted(3:end, :);
bestFiltersData1fsNoFiltersRows = resultBestFilter1fsDataSorted(3:end, :);
% dividing between normal (row 1:19) and standardized(20:38)
normalRange = 1:19;
stdData = 20:38;
bestFiltersData0XfsNormal = bestFiltersData0XfsNoFiltersRows(normalRange, :);
bestFiltersData0XfsStd = bestFiltersData0XfsNoFiltersRows(stdData, :);
bestFiltersData1fsNormal = bestFiltersData1fsNoFiltersRows(normalRange, :);
bestFiltersData1fsStd = bestFiltersData1fsNoFiltersRows(stdData, :);

result0XfsNormalMean = mean(bestFiltersData0XfsNormal, 1);
result0XfsStdMean = mean(bestFiltersData0XfsStd, 1);
result1fsNormalMean = mean(bestFiltersData1fsNormal, 1);
result1fsStdMean = mean(bestFiltersData1fsStd, 1);

figure("Name","Avg % error by filter order by upper");
hold on;

plot([ result0XfsNormalMean' result0XfsStdMean' result1fsNormalMean' result1fsStdMean'], '-o', 'LineWidth',0.8);

title('LOO KNN - filtraggio frequenze - ordinato per filtro superiore', 'Interpreter','latex');
xlabel('Frequenze filtrate [ superiore - inferiore ]', 'Interpreter','latex');
ylabel('Errore medio', 'Interpreter','latex');

set(gca, 'XTick', 1:size(labels,1), 'XTickLabel', labels, 'FontSize', 7);
xtickangle(40);
legend(fsWindowTypesWithDataStatus, 'Location', 'southeast');
grid on;
hold off;

saveChart(gcf, chartsDir, '3.chart_FILTERING_best_filter_avg_error_per_feature_order_by_upper_plot');
%}

%% SEARCH BEST FILTER: AVG ERROR BY FILTER ORDER BY LOWER - PLOT
%
% retrieving labels (already orderd by lower filter)
upperFilter = resultBestFilter0XfsData(1, :); 
lowerFilter = resultBestFilter0XfsData(2, :);
labels = strcat(num2str(upperFilter'), ' - ', num2str(lowerFilter'));

% skip filter rows
bestFiltersData0XfsNoFiltersRows = resultBestFilter0XfsData(3:end, :);
bestFiltersData1fsNoFiltersRows = resultBestFilter1fsData(3:end, :);
% dividing between normal (row 1:19) and standardized(20:38)
normalRange = 1:19;
stdData = 20:38;
bestFiltersData0XfsNormal = bestFiltersData0XfsNoFiltersRows(normalRange, :);
bestFiltersData0XfsStd = bestFiltersData0XfsNoFiltersRows(stdData, :);
bestFiltersData1fsNormal = bestFiltersData1fsNoFiltersRows(normalRange, :);
bestFiltersData1fsStd = bestFiltersData1fsNoFiltersRows(stdData, :);

result0XfsNormalMean = mean(bestFiltersData0XfsNormal, 1);
result0XfsStdMean = mean(bestFiltersData0XfsStd, 1);
result1fsNormalMean = mean(bestFiltersData1fsNormal, 1);
result1fsStdMean = mean(bestFiltersData1fsStd, 1);

figure("Name","avg % error by filter order by lower");
hold on;

plot([ result0XfsNormalMean' result0XfsStdMean' result1fsNormalMean' result1fsStdMean'], '-o', 'LineWidth',0.8);

title('LOO KNN - filtraggio frequenze - ordinato per filtro inferiore', 'Interpreter','latex');
xlabel('Frequenze filtrate [ inferiore - superiore ]', 'Interpreter','latex');
ylabel('Errore medio', 'Interpreter','latex');

set(gca, 'XTick', 1:size(labels,1), 'XTickLabel', labels, 'FontSize', 7);
xtickangle(40);
legend(fsWindowTypesWithDataStatus, 'Location', 'southeast');
grid on;
hold off;

saveChart(gcf, chartsDir, '4.chart_FILTERING_best_filter_avg_error_per_feature_order_by_lower_plot');
%}

%% DATASET IDENTIFIED SOUND 
%
dataSounds = readtable(sprintf("./%s/audio_data_identified_with_labels.dat", labelsDir));

% percentage of sound for each hour
allSounds = [dataSounds.vehicle, dataSounds.birds, dataSounds.crickets, dataSounds.river_waterfall, dataSounds.rain, dataSounds.thunder, dataSounds.noise, dataSounds.unknown];
soundColumns = {'veicoli V', 'uccelli U', 'grilli G', 'fiume/cascata C', 'pioggia P', 'tuono T', 'interferenza I', 'non identificato S'};
numSounds = length(soundColumns);

time = datetime(dataSounds.year, dataSounds.month, dataSounds.day, dataSounds.hours, dataSounds.minutes, dataSounds.seconds);
uniqueHours = unique(dataSounds.hours);
numHours = length(uniqueHours);
percentages = zeros(numHours, numSounds);

for i = 1:numHours
    hour = uniqueHours(i);
    totalRecords = sum(dataSounds.hours == hour);
    for j = 1:numSounds
        soundData = allSounds(:, j);
        percentages(i, j) = sum(soundData(dataSounds.hours == hour)) / totalRecords * 100;
    end
end

figure;
hold on;

bar(uniqueHours, percentages, 'grouped');

title('Dataset 2 - Distribuzione percentuale suoni per fascia oraria', 'Interpreter','latex');
xlabel('Ora', 'Interpreter','latex', 'Interpreter','latex');
ylabel('Attivit\''a in percentuale', 'Interpreter','latex');

xticks(uniqueHours);
xtickangle(40);
xticklabels({'02:00', '06:00', '10:00', '14:00', '18:00', '22:00'});
legend(soundColumns, 'Location', 'northeastoutside', 'Interpreter','latex');

grid on;
hold off;
saveChart(gcf, chartsDir, '5.chart_DATASET_IDENT_SOUND_sound_in_the_month');


% percentage of sound on month
percentages = zeros(1, numSounds);
totalRecords = size(allSounds,1);
for j = 1:numSounds
    soundData = allSounds(:, j);
    percentages(1, j) = sum(soundData) / totalRecords * 100;
end

figure;
hold on;

bar(soundColumns, percentages);

title('Dataset 2 - Distribuzione percentuale suoni per mese', 'Interpreter','latex');
xlabel('Tipo di suono', 'Interpreter','latex');
ylabel('Attivit\''a in percentuale', 'Interpreter','latex');
xtickangle(40);

grid on;
hold off;
saveChart(gcf, chartsDir, '6.chart_DATASET_IDENT_SOUND_sound_per_hours');

%}

%% CLASSIFICATION IDENTIFIED SOUND - SINGLE: AVG ERROR BY LABEL TYPE - BAR GROUPS COMPACT
%
result0XfsMean = mean(result0XfsIdentSoundData, 1);
result1fsMean = mean(result1fsIdentSoundData, 1);
objects = 1:size(result0XfsIdentSoundData, 2);

figure("Name","Ident Sound: avg error by label - single - bar");
hold on;

bar(horzcat(reshape(result0XfsMean, 2, [])', reshape(result1fsMean, 2, [])'));

title({'LOO KNN - Class. seconda fase - binaria pos/neg';'Errore medio per contesto'}, 'Interpreter','latex');
xlabel('Contesto', 'Interpreter','latex');
ylabel('Errore medio', 'Interpreter','latex');

ylim( calcLimit([result0XfsMean, result1fsMean], 0.01) );
set(gca, 'XTick', objects, 'XTickLabel', groupsLabelsIdentifiedSound);
xtickangle(40);
legend(fsWindowTypesWithDataStatus, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 7);
grid on;
hold off;

saveChart(gcf, chartsDir, '7.chart_CLASS_CONTEXT_IDENT_SOUND_classif_avg_error_per_label');
%}

%% CLASSIFICATION IDENTIFIED SOUND - SINGLE: AVG ERROR BY FEATURE - BAR
%
result0XfsMean = mean(result0XfsIdentSoundData, 2);
result1fsMean = mean(result1fsIdentSoundData, 2);
objects = 1:size(result0XfsIdentSoundData, 1);

figure("Name","Ident Sound: avg error by feature - single - bar");
hold on;

bar([result0XfsMean(:),result1fsMean(:)]);

title({'LOO KNN - Class. seconda fase - binaria positivo/negativo - Errore medio per feature'}, 'Interpreter','latex');
xlabel('Feature', 'Interpreter','latex');
ylabel('Errore medio', 'Interpreter','latex');

ylim( calcLimit([result0XfsIdentSoundData,result1fsIdentSoundData], 0.01) );
set(gca, 'XTick', objects, 'XTickLabel', featuresLabels, 'FontSize', 7);
xtickangle(40);
legend(fsWindowTypes, 'Location', 'northwest', 'Interpreter', 'latex');
grid on;
hold off;

saveChart(gcf, chartsDir, '8.chart_CLASS_FEATURE_IDENT_SOUND_classif_avg_error_per_feature');
%}

%% CLASSIFICATION IDENTIFIED SOUND - SINGLE - 4 WINDOWS: AVG ERROR BY FEATURE - BAR
%
problemsCount = size(result0XfsIdentSoundData, 2);
featGroupsCount = size(result0XfsIdentSoundData, 1);

normalDataRange = 1:2:(problemsCount-1);
stdDataRange = 2:2:problemsCount;

result0XfsNorMean = mean(result0XfsIdentSoundData(:,normalDataRange), 2);
result0XfsStdMean = mean(result0XfsIdentSoundData(:,stdDataRange), 2);
result1fsNorMean = mean(result1fsIdentSoundData(:,normalDataRange), 2);
result1fsStdMean = mean(result1fsIdentSoundData(:,stdDataRange), 2);

figure("Name","Ident Sound: avg error by feature - single with 4 window - bar");
hold on;

bar(horzcat(result0XfsNorMean(:,:), result0XfsStdMean(:,:), ...
    result1fsNorMean(:,:), result1fsStdMean(:,:)), ...
    'EdgeColor', [0.4 0.4 0.4], ...
    'BarWidth', 0.8);    

title({'LOO KNN - Class. seconda fase - binaria positivo/negativo - Errore medio per feature'}, 'Interpreter','latex');
xlabel('Feature', 'Interpreter','latex');
ylabel('Errore medio', 'Interpreter','latex');

ylim( calcLimit([result0XfsNorMean, result0XfsStdMean, result1fsNorMean, result1fsStdMean], 0.01) );
set(gca, 'XTick', 1:featGroupsCount, 'XTickLabel', featuresLabels, 'FontSize', 7);
xtickangle(40);
legend(fsWindowTypesWithDataStatus, 'Location', 'northwest', 'Interpreter', 'latex');
grid on;
hold off;

saveChart(gcf, chartsDir, '8.1.chart_CLASS_FEATURE_IDENT_SOUND_4_WINDOWS_classif_avg_error_per_feature');
%}

%% CLASSIFICATION IDENTIFIED SOUND - BINARY: AVG ERROR BY LABEL TYPE - BAR GROUPS COMPACT
%
result0XfsMean = mean(result0XfsIdentSoundBinaryData, 1);
result1fsMean = mean(result1fsIdentSoundBinaryData, 1);
objects = 1:size(result0XfsIdentSoundBinaryData, 2);

figure("Name","Ident Sound: avg error by label - binary - bar");
hold on;

bar(horzcat(reshape(result0XfsMean, 2, [])', reshape(result1fsMean, 2, [])'));

title({'LOO KNN - Class. seconda fase - binaria';'Errore medio per contesto'}, 'Interpreter','latex');
xlabel('Contesto', 'Interpreter','latex');
ylabel('Errore medio', 'Interpreter','latex');

ylim( calcLimit([result0XfsMean, result1fsMean], 0.01) );
set(gca, 'XTick', objects, 'XTickLabel', groupsLabelsIdentifiedSoundBinary);
xtickangle(40);
legend(fsWindowTypesWithDataStatus, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 7);
grid on;
hold off;

saveChart(gcf, chartsDir, '9.chart_CLASS_CONTEXT_IDENT_SOUND_BINARY_classif_avg_error_per_label');
%}

%% CLASSIFICATION IDENTIFIED SOUND - BINARY: AVG ERROR BY FEATURE - BAR
%
result0XfsMean = mean(result0XfsIdentSoundBinaryData, 2);
result1fsMean = mean(result1fsIdentSoundBinaryData, 2);
objects = 1:size(result0XfsIdentSoundBinaryData, 1);

figure("Name","Ident Sound: avg error by feature - binary - bar");
hold on;

bar([result0XfsMean(:),result1fsMean(:)]);

title('LOO KNN - Class. seconda fase - binaria - Errore medio per feature', 'Interpreter','latex');
xlabel('Feature', 'Interpreter','latex');
ylabel('Errore medio', 'Interpreter','latex');

ylim( calcLimit([result0XfsMean, result1fsMean], 0.01) );
set(gca, 'XTick', objects, 'XTickLabel', featuresLabels, 'FontSize', 7);
xtickangle(40);
legend(fsWindowTypes, 'Location', 'northwest', 'Interpreter', 'latex');
grid on;
hold off;

saveChart(gcf, chartsDir, '10.chart_CLASS_CONTEXT_IDENT_SOUND_BINARY_classif_avg_error_per_label');
%}

%% CLASSIFICATION IDENTIFIED SOUND - BINARY - 4 WINDOWS: AVG ERROR BY FEATURE - BAR
%
problemsCount = size(result0XfsIdentSoundBinaryData, 2);
featGroupsCount = size(result0XfsIdentSoundBinaryData, 1);

normalDataRange = 1:2:(problemsCount-1);
stdDataRange = 2:2:problemsCount;

result0XfsNorMean = mean(result0XfsIdentSoundBinaryData(:,normalDataRange), 2);
result0XfsStdMean = mean(result0XfsIdentSoundBinaryData(:,stdDataRange), 2);
result1fsNorMean = mean(result1fsIdentSoundBinaryData(:,normalDataRange), 2);
result1fsStdMean = mean(result1fsIdentSoundBinaryData(:,stdDataRange), 2);

figure("Name","Ident Sound: avg error by feature - binary with 4 window - bar");
hold on;

bar(horzcat(result0XfsNorMean(:,:), result0XfsStdMean(:,:), ...
    result1fsNorMean(:,:), result1fsStdMean(:,:)), ...
    'EdgeColor', [0.4 0.4 0.4], ...
    'BarWidth', 0.8);    

title('LOO KNN - Class. seconda fase - binaria - Errore medio per feature', 'Interpreter','latex');
xlabel('Feature', 'Interpreter','latex');
ylabel('Errore medio', 'Interpreter','latex');

ylim( calcLimit([result0XfsNorMean, result0XfsStdMean, result1fsNorMean, result1fsStdMean], 0.01) );
set(gca, 'XTick', 1:featGroupsCount, 'XTickLabel', featuresLabels, 'FontSize', 7);
xtickangle(40);
legend(fsWindowTypesWithDataStatus, 'Location', 'northwest', 'Interpreter', 'latex');
grid on;
hold off;

saveChart(gcf, chartsDir, '10.1.chart_CLASS_CONTEXT_IDENT_SOUND_BINARY_4_WINDOWS_classif_avg_error_per_label');
%}

%% CLASSIFICATION: AVG ERROR BY LABEL TYPE TERTIARY - BAR GROUPS COMPACT
%
result0XfsMean = mean(result0XfsIdentSoundTertiaryData, 1);
result1fsMean = mean(result1fsIdentSoundTertiaryData, 1);
objects = 1:size(result0XfsIdentSoundTertiaryData, 2);

figure("Name","Ident Sound: avg error by label - tertiary - bar");
hold on;

bar(horzcat(reshape(result0XfsMean, 2, [])', reshape(result1fsMean, 2, [])'));

title({'LOO KNN - Class. seconda fase - ternaria';'Errore medio per contesto'}, 'Interpreter','latex');
xlabel('Contesto', 'Interpreter','latex');
ylabel('Errore medio', 'Interpreter','latex');

ylim( calcLimit([result0XfsMean, result1fsMean], 0.01) );
set(gca, 'XTick', objects, 'XTickLabel', groupsLabelsIdentifiedSoundTertiary);
xtickangle(40);
legend(fsWindowTypesWithDataStatus, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 7);
grid on;
hold off;

saveChart(gcf, chartsDir, '11.chart_CLASS_CONTEXT_IDENT_SOUND_TERTIARY_classif_avg_error_per_label');
%}

%% CLASSIFICATION IDENTIFIED SOUND TERTIARY: AVG ERROR BY FEATURE - BAR
%
result0XfsMean = mean(result0XfsIdentSoundTertiaryData, 2);
result1fsMean = mean(result1fsIdentSoundTertiaryData, 2);
objects = 1:size(result0XfsIdentSoundTertiaryData, 1);

figure("Name","Ident Sound: avg error by feature - tertiary - bar");
hold on;

bar([result0XfsMean(:),result1fsMean(:)]);

title('LOO KNN - Class. seconda fase - ternaria - Errore medio per feature', 'Interpreter','latex');
xlabel('Features', 'Interpreter','latex');
ylabel('Errore medio', 'Interpreter','latex');

ylim( calcLimit([result0XfsMean, result1fsMean], 0.01) );
set(gca, 'XTick', objects, 'XTickLabel', featuresLabels, 'FontSize', 7);
xtickangle(40);
legend(fsWindowTypes, 'Location', 'northwest', 'Interpreter', 'latex');
grid on;
hold off;

saveChart(gcf, chartsDir, '12.chart_CLASS_FEATURE_IDENT_SOUND_TERTIARY_classif_avg_error_per_feature');
%}

%% CLASSIFICATION IDENTIFIED SOUND TERTIARY - 4 WINDOWS: AVG ERROR BY FEATURE - BAR
%
problemsCount = size(result0XfsIdentSoundTertiaryData, 2);
featGroupsCount = size(result0XfsIdentSoundTertiaryData, 1);

normalDataRange = 1:2:(problemsCount-1);
stdDataRange = 2:2:problemsCount;

result0XfsNorMean = mean(result0XfsIdentSoundTertiaryData(:,normalDataRange), 2);
result0XfsStdMean = mean(result0XfsIdentSoundTertiaryData(:,stdDataRange), 2);
result1fsNorMean = mean(result1fsIdentSoundTertiaryData(:,normalDataRange), 2);
result1fsStdMean = mean(result1fsIdentSoundTertiaryData(:,stdDataRange), 2);

figure("Name","Ident Sound: avg error by feature - tertiary with 4 windows - bar");
hold on;

bar(horzcat(result0XfsNorMean(:,:), result0XfsStdMean(:,:), ...
    result1fsNorMean(:,:), result1fsStdMean(:,:)), ...
    'EdgeColor', [0.4 0.4 0.4], ...
    'BarWidth', 0.8);    

title('LOO KNN - Class. seconda fase - ternaria - Errore medio per feature', 'Interpreter','latex');
xlabel('Features', 'Interpreter','latex');
ylabel('Errore medio', 'Interpreter','latex');

ylim( calcLimit([result0XfsNorMean, result0XfsStdMean, result1fsNorMean, result1fsStdMean], 0.01) );
set(gca, 'XTick', 1:featGroupsCount, 'XTickLabel', featuresLabels, 'FontSize', 7);
xtickangle(40);
legend(fsWindowTypesWithDataStatus, 'Location', 'northwest', 'Interpreter', 'latex');
grid on;
hold off;

saveChart(gcf, chartsDir, '12.1.chart_CLASS_FEATURE_IDENT_SOUND_TERTIARY_4_WINDOWS_classif_avg_error_per_feature');
%}


%% CLASSIFICATION IDENTIFIED SOUND - MIX SINGLE,BINARY,TERTIARY: AVG ERROR BY LABEL TYPE SCALED - BAR GROUPS COMPACT
%
function res = downScale(A, threshold, scalingFactor)
for i=1:size(A, 1)
    for j=1:size(A, 2)
        if A(i,j) >= threshold
            A(i,j) = A(i,j) - scalingFactor; 
        end
    end
end
res = A;
end
function res = upScale(A, threshold, scalingFactor)
for i=1:size(A, 1)
    for j=1:size(A, 2)
        if A(i,j) >= threshold
            A(i,j) = A(i,j) + scalingFactor; 
        end
    end
end
res = A;
end

threshold = 0.445;
scalingFactor = 0.09;

result0XfsOrigMean = mean(result0XfsIdentSoundData, 1);
result0xfsBinaryOrigMean = mean(result0XfsIdentSoundBinaryData, 1);
result0xfsTernaryOrigMean = mean(result0XfsIdentSoundTertiaryData, 1);
result1fsOrigMean = mean(result1fsIdentSoundData, 1);
result1fsBinaryOrigMean = mean(result1fsIdentSoundBinaryData, 1);
result1fsTernaryOrigMean = mean(result1fsIdentSoundTertiaryData, 1);

result0XfsMean = downScale(result0XfsOrigMean, threshold, scalingFactor);
result0xfsBinaryMean = downScale(result0xfsBinaryOrigMean, threshold, scalingFactor);
result0xfsTernaryMean = downScale(result0xfsTernaryOrigMean, threshold, scalingFactor);
result1fsMean = downScale(result1fsOrigMean, threshold, scalingFactor);
result1fsBinaryMean = downScale(result1fsBinaryOrigMean, threshold, scalingFactor);
result1fsTernaryMean = downScale(result1fsTernaryOrigMean, threshold, scalingFactor);

figure("Name","Ident Sound: avg error by label - mix single, binary, tertiary - bar");
hold on;

barData = vertcat( ...
    horzcat( reshape(result0XfsMean, 2, [])', reshape(result1fsMean, 2, [])' ), ...
    horzcat( reshape(result0xfsBinaryMean, 2, [])', reshape(result1fsBinaryMean, 2, [])' ), ...
    horzcat( reshape(result0xfsTernaryMean, 2, [])', reshape(result1fsTernaryMean, 2, [])' ) ...
);
bar(barData);

title({'LOO KNN - Class. seconda fase - binaria pos/neg, binaria, ternaria';'Errore medio per contesto'}, 'Interpreter','latex');
xlabel('Contesto', 'Interpreter','latex');
ylabel('Errore medio', 'Interpreter','latex');

[yMinLimit, yMaxLimit] = calcLimitSep(barData, 0.01);
ylim([round(yMinLimit, 2), round(yMaxLimit,2)]);
labels = horzcat(groupsLabelsIdentifiedSound, groupsLabelsIdentifiedSoundBinary, groupsLabelsIdentifiedSoundTertiary);
objects = 1:size(barData, 1); % objs per group
set(gca, 'XTick', objects, 'XTickLabel', labels);
xtickangle(40);
yTicks = round(yMinLimit,2):0.01:round(yMaxLimit,2);
yTicksUpScaled = upScale(yTicks, threshold, scalingFactor);
yticklabels(yTicksUpScaled);
yticks(yTicks);

% drawing separator line
y1 = threshold+0.002;
y2 = threshold-0.002;
yline(y1, ':', 'LineWidth', 1, 'DisplayName', '');
yline(y2, ':', 'LineWidth', 1, 'DisplayName', '');
xLimits = xlim;
x1 = xLimits(1);
x2 = xLimits(2);
patch([x1 x2 x2 x1], [y1 y1 y2 y2], ...
    'k', 'FaceAlpha', 0.09, 'EdgeColor', 'none', 'DisplayName', '');
% show oblique lines
lineSpacing = 0.5;
lineCount = x2 / lineSpacing;
for i = 0:(lineCount - 1)
    xStart = x1 + i * lineSpacing;
    xEnd = xStart + 0.2;  
    if xEnd > x2
        break;
    end
    line([xStart, xEnd], [y1, y2], 'LineStyle', ':', 'Color', [0.5 0.5 0.5], 'LineWidth', 1);
end

% bold y tick of two lines
ax = gca;
ylabels = string(yTicksUpScaled); 
bold_indices_y = string([0.44, 0.54]);  

for i = 1:length(ylabels)
    value = ylabels(i);
    if ismember(value, bold_indices_y)
        ylabels(i) = '\bf' + ylabels(i);
    end
end
ax.YTickLabel = ylabels;  
% ax.YAxis.FontSize = 9;

legend(fsWindowTypesWithDataStatus, 'Location', 'northwest', 'Interpreter', 'latex', 'FontSize', 7);
grid on;
hold off;

saveChart(gcf, chartsDir, '13.chart_CLASS_CONTEXT_IDENT_SOUND_MIX_SINGLE_BINARY_TERTIARY_SCALED_classif_avg_error_per_label');
%}

%% in order to close all charts
close all; 