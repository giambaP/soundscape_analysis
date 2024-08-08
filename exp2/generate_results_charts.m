clc; clear all; close all;

%% CONFIGURATION

chartsDir = "./result_charts";

resultExp2DirPath = "./result_classification_exp2";
resultExp2For0XfsFileName = "result_classification_exp2_fs0Xsec.dat";
resultExp2For1fsFileName = "result_classification_exp2_fs1sec.dat";

resultExp2IdentSoundDirPath = "./result_classification_exp2_identified_sound";
resultExp2IdentSoundFor0XfsFileName = "result_classification_exp2_identified_sound_fs0Xsec.dat";
resultExp2IdentSoundFor1fsFileName = "result_classification_exp2_identified_sound_fs1sec.dat";

resultBestFilters0XfsDirPath = "./result_best_filters_0Xsec";
resultBestFilters1fsDirPath = "./result_best_filters_1sec";
bestFilter0XfsFileName = "result_best_filters_0Xsec_all.csv";
bestFilter1fsFileName = "result_best_filters_1sec_all.csv";

fsWindowTypes = [ "fs 0.x sec", "fs 1 sec" ];
dataStatus = ["normal", "standardized"];
featuresLabels = [
    "conc feat all", ...
    "conc feat spectral", ...
    "conc feat spectral", ...
    "conc feat time", ...
    "conc avg feat all", ...
    "conc avg feat spectral", ...
    "conc avg feat tonaless", ...
    "conc avg feat time", ...
    "feature SpectralCentroid", ...
    "feature SpectralCrestFactor", ...
    "feature SpectralDecrease", ...
    "feature SpectralFlatness", ...
    "feature SpectralFlux", ...
    "feature SpectralRolloff", ...
    "feature SpectralSpread", ...
    "feature SpectralTonalPowerRatio", ...
    "feature TimeZeroCrossingRate", ...
    "feature TimeAcfCoeff", ...
    "feature TimeMaxAcf"
    ];
groupsLabels = [
    "Yat", ...
    "Day/Night", ...
    "Sunrise/Sunset", ...
    "Sunrise/Sunset/Day/Night", ...
    "Month", ...
    "Half Month"
    ];
groupsLabelsIdentifiedSound = [
    "Vehicle", ...
    "Crickets", ...
    "Rain", ...
    "Thunder"
    ];

[f, g] = meshgrid(fsWindowTypes, dataStatus);
fsWindowTypesWithDataStatus = strcat(f(:), " - ", g(:));

[f, g] = meshgrid(groupsLabels, dataStatus);
groupLabelsWithDataTypes = strcat(f(:), " - ", g(:));

[f, g] = meshgrid(groupsLabelsIdentifiedSound, dataStatus);
groupLabelsIdentifiedSoundWithDataTypes = strcat(f(:), " - ", g(:));


%% FUNCTION

function limit = calcLimit(arr1, arr2, offset)
res = [arr1,arr2];
limit = [ min(res, [], "all")-offset, max(res, [], "all")+offset ];
end

%% PREPARING CONTEXT

if ~exist(chartsDir, 'dir'); mkdir(chartsDir); end

% classification data
result0XfsTable = readtable(sprintf("%s/%s", resultExp2DirPath, resultExp2For0XfsFileName));
result1fsTable = readtable(sprintf("%s/%s", resultExp2DirPath, resultExp2For1fsFileName));
result0XfsData = result0XfsTable{:,:};
result1fsData = result1fsTable{:,:};

% classification data
result0XfsTable = readtable(sprintf("%s/%s", resultExp2IdentSoundDirPath, resultExp2IdentSoundFor0XfsFileName));
result1fsTable = readtable(sprintf("%s/%s", resultExp2IdentSoundDirPath, resultExp2IdentSoundFor1fsFileName));
result0XfsIdentSoundData = result0XfsTable{:,:};
result1fsIdentSoundData = result1fsTable{:,:};

% classification with filter data
resultBestFilter0XfsTable = readtable(sprintf("%s/%s", resultBestFilters0XfsDirPath, bestFilter0XfsFileName));
resultBestFilter1fsTable = readtable(sprintf("%s/%s", resultBestFilters1fsDirPath, bestFilter1fsFileName));
% n.b first row header, second and third upper and lower filter, first
% column has feature selection 2-20 normal, 21-39 standardized
resultBestFilter0XfsData = table2array(resultBestFilter0XfsTable(:,2:end));
resultBestFilter1fsData = table2array(resultBestFilter1fsTable(:,2:end));

%% CLASSIFICATION: AVG ERROR BY FEATURE - PLOT
%{
result0XfsMean = mean(result0XfsData, 2);
result1fsMean = mean(result1fsData, 2);
objects = 1:size(result0XfsData, 1);

fig = figure;
hold on;

plot(result0XfsMean, '-o', 'LineWidth',1);
plot(result1fsMean, '-o', 'LineWidth',1);

title('LOO KNN - Average % results by feature - plot');
xlabel('Features');
ylabel('Avg % Error');

ylim( calcLimit(result0XfsMean, result1fsMean, 0.01) );
set(gca, 'XTick', objects, 'XTickLabel', featuresLabels, 'FontSize', 7);
xtickangle(40);
legend(fsWindowTypes, 'Location', 'bestoutside');
grid on;
hold off;
saveas(fig,sprintf('%s/chart_classif_avg_error_per_feature_plot.jpg', chartsDir));
%}

%% CLASSIFICATION: AVG ERROR BY FEATURE - BAR
%{
result0XfsMean = mean(result0XfsData, 2);
result1fsMean = mean(result1fsData, 2);
objects = 1:size(result0XfsData, 1);

fig = figure;
hold on;

bar([result0XfsMean(:),result1fsMean(:)]);

title('LOO KNN - Average % results by feature - bar');
xlabel('Features');
ylabel('Avg % Error');

ylim( calcLimit(result0XfsMean, result1fsMean, 0.01) );
set(gca, 'XTick', objects, 'XTickLabel', featuresLabels, 'FontSize', 7);
xtickangle(40);
legend(fsWindowTypes, 'Location', 'northeastoutside');
grid on;
hold off;
saveas(fig,sprintf('%s/chart_classif_avg_error_per_feature_bar.jpg', chartsDir));
%}

%% CLASSIFICATION: AVG ERROR BY FEATURE - BAR WITH PLOT
%{
result0XfsMean = mean(result0XfsData, 2);
result1fsMean = mean(result1fsData, 2);
objects = 1:size(result0XfsData, 1);

fig = figure;
hold on;

bar([result0XfsMean(:) result1fsMean(:)]);

plot(result0XfsMean, '-o', 'LineWidth',1);
plot(result1fsMean, '-o', 'LineWidth',1);

title('LOO KNN - Average % results by feature - bar plot');
xlabel('Features');
ylabel('Avg % Error');

ylim( calcLimit(result0XfsMean, result1fsMean, 0.01) );
set(gca, 'XTick', objects, 'XTickLabel', featuresLabels, 'FontSize', 7);
xtickangle(40);
legend(fsWindowTypes, 'Location', 'northeastoutside');
grid on;
hold off;
saveas(fig,sprintf('%s/chart_classif_avg_error_per_feature_barplot.jpg', chartsDir));
%}

%% CLASSIFICATION: AVG ERROR BY LABEL TYPE - PLOT
%{
result0XfsMean = mean(result0XfsData, 1);
result1fsMean = mean(result1fsData, 1);
objects = 1:size(result0XfsData, 2);

fig = figure;
hold on;

plot(result0XfsMean, '-o', 'LineWidth',1);
plot(result1fsMean, '-o', 'LineWidth',1);

title('LOO KNN - Average % errors by label type - plot');
xlabel('Group Labels');
ylabel('Avg % Error');

ylim( calcLimit(result0XfsMean, result1fsMean, 0.01) );
set(gca, 'XTick', objects, 'XTickLabel', groupLabelsWithDataTypes, 'FontSize', 7);
xtickangle(40);
legend(fsWindowTypes, 'Location', 'northeastoutside');
grid on;
hold off;
saveas(fig,sprintf('%s/chart_classif_avg_error_per_label_type_plot.jpg', chartsDir));
%}

%% CLASSIFICATION: AVG ERROR BY LABEL TYPE - BAR
%{
result0XfsMean = mean(result0XfsData, 1);
result1fsMean = mean(result1fsData, 1);
objects = 1:size(result0XfsData, 2);

fig = figure;
hold on;

bar([result0XfsMean(:),result1fsMean(:)]);

title('LOO KNN - Average % errors by label type - bar');
xlabel('Group Labels');
ylabel('Avg % Error');

ylim( calcLimit(result0XfsMean, result1fsMean, 0.01) );
set(gca, 'XTick', objects, 'XTickLabel', groupLabelsWithDataTypes, 'FontSize', 7);
xtickangle(40);
legend(fsWindowTypes, 'Location', 'northeastoutside');
grid on;
hold off;
saveas(fig,sprintf('%s/chart_classif_avg_error_per_label_type_bar.jpg', chartsDir));
%}

%% CLASSIFICATION: AVG ERROR BY LABEL TYPE - BAR PLOT
%{
result0XfsMean = mean(result0XfsData, 1);
result1fsMean = mean(result1fsData, 1);
objects = 1:size(result0XfsData, 2);

fig = figure;
hold on;

bar([result0XfsMean(:),result1fsMean(:)]);

plot(result0XfsMean, '-o', 'LineWidth',1);
plot(result1fsMean, '-o', 'LineWidth',1);

title('LOO KNN - Average % errors by label type - bar plot');
xlabel('Group Labels');
ylabel('Avg % Error');

ylim( calcLimit(result0XfsMean, result1fsMean, 0.01) );
set(gca, 'XTick', objects, 'XTickLabel', groupLabelsWithDataTypes, 'FontSize', 7);
xtickangle(40);
legend(fsWindowTypes, 'Location', 'northeastoutside');
grid on;
hold off;
saveas(fig,sprintf('%s/chart_classif_avg_error_per_label_type_bar_plot.jpg', chartsDir));
%}

%% CLASSIFICATION: AVG ERROR BY LABEL TYPE - BAR GROUPS COMPACT
%{
result0XfsMean = mean(result0XfsData, 1);
result1fsMean = mean(result1fsData, 1);
objects = 1:size(result0XfsData, 2);

fig = figure;
hold on;

bar(horzcat(reshape(result0XfsMean, 2, [])', reshape(result1fsMean, 2, [])'));

title('LOO KNN - Average % errors by label type - bar small');
xlabel('Group Labels');
ylabel('Avg % Error');

ylim( calcLimit(result0XfsMean, result1fsMean, 0.01) );
set(gca, 'XTick', objects, 'XTickLabel', groupsLabels);
xtickangle(40);
legend(fsWindowTypesWithDataStatus, 'Location', 'northeastoutside', 'FontSize', 7);
grid on;
hold off;
saveas(fig,sprintf('%s/chart_classif_avg_error_per_label_type_small_bar.jpg', chartsDir));
%}

%% CLASSIFICATION: AVG ERROR BY LABEL TYPE - BAR MEAN GROUPS
%{
result0XfsMean = mean(result0XfsData, 1);
result1fsMean = mean(result1fsData, 1);
objects = 1:size(result0XfsData, 2) / 2;

fig = figure;
hold on;

res = horzcat(reshape(result0XfsMean, 2, [])', reshape(result1fsMean, 2, [])');
bar(mean(res, 2));

title('LOO KNN - Average % errors by label type - bar compact');
xlabel('Group Labels');
ylabel('Avg % Error');

ylim( calcLimit(result0XfsMean, result1fsMean, 0.01) );
set(gca, 'XTick', objects, 'XTickLabel', groupsLabels, 'FontSize', 7);
xtickangle(40);
grid on;
hold off;
saveas(fig,sprintf('%s/chart_classif_avg_error_per_label_type_mean_bar.jpg', chartsDir));
%}



%% SEARCH BEST FILTER: AVG ERROR BY FILTER ORDER BY LOWER - PLOT
%{
% retrieving labels 
upperFilter = resultBestFilter0XfsData(1, :);
lowerFilter = resultBestFilter0XfsData(2, :);
labels = strcat("UPP ", num2str(upperFilter'), " - LOW ", num2str(lowerFilter'));

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

fig = figure;
hold on;

plot([ result0XfsNormalMean' result0XfsStdMean' result1fsNormalMean' result1fsStdMean'], '-o', 'LineWidth',1);

title('LOO KNN with various filter - order by lower filter asc');
xlabel('Filters');
ylabel('Avg % errors');

% ylim( calcLimit(resultBestFilter0XfsData, resultBestFilter1fsData, 0.01) );
set(gca, 'XTick', 1:size(labels,1), 'XTickLabel', labels, 'FontSize', 7);
xtickangle(40);
legend(fsWindowTypesWithDataStatus, 'Location', 'bestoutside');
grid on;
hold off;
saveas(fig,sprintf('%s/chart_best_filter_avg_error_per_feature_order_by_lower_plot.jpg', chartsDir));
%}

%% SEARCH BEST FILTER: AVG ERROR BY FILTER ORDER BY UPPER - PLOT
%{
% retrieving labels 
upperFilter = resultBestFilter0XfsData(1, :);
lowerFilter = resultBestFilter0XfsData(2, :);
% sorting from upper filter
[upperFilter, sortIdxs] = sort(upperFilter);
lowerFilter = lowerFilter(sortIdxs);
resultBestFilter0XfsDataSorted = resultBestFilter0XfsData(:,sortIdxs);
resultBestFilter1fsDataSorted = resultBestFilter1fsData(:,sortIdxs);

labels = strcat("LOW ", num2str(lowerFilter'), " - UPP ", num2str(upperFilter'));

% skip filter rows
bestFiltersData0XfsNoFiltersRows = resultBestFilter0XfsDataSorted(3:end, :);
bestFiltersData1fsNoFiltersRows = resultBestFilter1fsDataSorted(3:end, :);
% dividing between normal (row 1:19) and standardized(20:38)
bestFiltersData0XfsNormal = bestFiltersData0XfsNoFiltersRows(1:19, :);
bestFiltersData0XfsStd = bestFiltersData0XfsNoFiltersRows(20:38, :);
bestFiltersData1fsNormal = bestFiltersData1fsNoFiltersRows(1:19, :);
bestFiltersData1fsStd = bestFiltersData1fsNoFiltersRows(20:38, :);

result0XfsNormalMean = mean(bestFiltersData0XfsNormal, 1);
result0XfsStdMean = mean(bestFiltersData0XfsStd, 1);
result1fsNormalMean = mean(bestFiltersData1fsNormal, 1);
result1fsStdMean = mean(bestFiltersData1fsStd, 1);
objects = 1:size(result0XfsData, 1);

fig = figure;
hold on;

plot([ result0XfsNormalMean' result0XfsStdMean' result1fsNormalMean' result1fsStdMean'], '-o', 'LineWidth',1);

title('LOO KNN with various filter - order by upper filter asc');
xlabel('Filters');
ylabel('Avg % errors');

% ylim( calcLimit(resultBestFilter0XfsData, resultBestFilter1fsData, 0.01) );
set(gca, 'XTick', 1:size(labels,1), 'XTickLabel', labels, 'FontSize', 7);
xtickangle(40);
legend(fsWindowTypesWithDataStatus, 'Location', 'bestoutside');
grid on;
hold off;
saveas(fig,sprintf('%s/chart_best_filter_avg_error_per_feature_order_by_upper_plot.jpg', chartsDir));
%}

%% CLASSIFICATION IDENTIFIED SOUND: AVG ERROR BY FEATURE - BAR
%
result0XfsMean = mean(result0XfsIdentSoundData, 2);
result1fsMean = mean(result1fsIdentSoundData, 2);
objects = 1:size(result0XfsIdentSoundData, 1);

fig = figure;
hold on;

bar([result0XfsMean(:),result1fsMean(:)]);

title('LOO KNN - Average % results by feature - bar');
xlabel('Features');
ylabel('Avg % Error');

ylim( calcLimit(result0XfsMean, result1fsMean, 0.01) );
set(gca, 'XTick', objects, 'XTickLabel', featuresLabels, 'FontSize', 7);
xtickangle(40);
legend(fsWindowTypes, 'Location', 'northeastoutside');
grid on;
hold off;
saveas(fig,sprintf('%s/chart_classif_avg_error_per_feature_bar_identified_sound.jpg', chartsDir));
%}

%% CLASSIFICATION: AVG ERROR BY LABEL TYPE - BAR GROUPS COMPACT
%
result0XfsMean = mean(result0XfsIdentSoundData, 1);
result1fsMean = mean(result1fsIdentSoundData, 1);
objects = 1:size(result0XfsIdentSoundData, 2);

fig = figure;
hold on;

bar(horzcat(reshape(result0XfsMean, 2, [])', reshape(result1fsMean, 2, [])'));

title('LOO KNN - Average % errors by label type - bar small');
xlabel('Group Labels');
ylabel('Avg % Error');

ylim( calcLimit(result0XfsMean, result1fsMean, 0.01) );
set(gca, 'XTick', objects, 'XTickLabel', groupsLabelsIdentifiedSound);
xtickangle(40);
legend(fsWindowTypesWithDataStatus, 'Location', 'northeastoutside', 'FontSize', 7);
grid on;
hold off;
saveas(fig,sprintf('%s/chart_classif_avg_error_per_label_type_small_bar_identified_sound.jpg', chartsDir));
%}