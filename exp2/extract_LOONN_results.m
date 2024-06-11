clc; clear all; close all;

featuresCount = 11;
dirLabels = "labels";

dataFileName = "matrixAllFeatures.mat";
labelYatFileName = "labels_Yat.mat";
labelDayNightFileName = "labels_DayNight.mat";
labelSunriseSunsetFileName = "labels_SunriseSunset.mat";
labelSunriseSunsetDayNightFileName = "labels_SunriseSunsetDayNight.mat";
labelMonthFileName = "labels_Month.mat";
labelHalfMonthFileName = "labels_HalfMonth.mat";

%% function: load data, labels and exec LOON

function results = LOONN(featuresCount, elementsPerFeature, dirData, dataFileName, dirLabel, labelFileName)
fprintf("------  EXECUTE %s with %s --------------------\n", dirData, labelFileName);

dirResult = 'result_loonn';
if ~exist(dirResult, 'dir')
    mkdir(dirResult);
end
resultFile = sprintf("./%s/%s_%s", dirResult, dirData, labelFileName);
if exist(resultFile, 'file')
    fprintf("loonn skipped for %s in %s\n",dirData, labelFileName);
else
    tic;

    dataFilePath = sprintf("./%s/%s", dirData, dataFileName);
    d = load(dataFilePath);
    fprintf("loaded audio data from '%s'\n", dataFilePath);

    labelFilePath = sprintf("./%s/%s", dirLabel, labelFileName);
    l = load(labelFilePath);
    fprintf("loaded labels data from '%s'\n", labelFilePath);

    results = executeLOONN(featuresCount, elementsPerFeature, d.data, l.labels, 0, 0);

    resultTypes = [results{:,1}];
    values = [results{:,2}];
    isStandardized = [results{:,3}];
    save(resultFile, '-fromstruct', struct('results', resultTypes', 'values', values', 'isStandardized', isStandardized'));

    toc;
end
results = load(resultFile);
end

%% LOONN all features, fs 0.Xs, no filters

dirFs0Xs = "templates_fs0Xs";
elementsPerFeature = 176;

fprintf("> LOONN 0.Xs, no filters: start\n");
resultsFs0XsYat = LOONN(featuresCount, elementsPerFeature, dirFs0Xs, dataFileName, dirLabels, labelYatFileName);
resultsFs0XsDayNight = LOONN(featuresCount, elementsPerFeature, dirFs0Xs, dataFileName, dirLabels, labelDayNightFileName);
resultsFs0XsSunriseSunset = LOONN(featuresCount, elementsPerFeature, dirFs0Xs, dataFileName, dirLabels, labelSunriseSunsetFileName);
resultsFs0XsSunriseSunsetDayNight = LOONN(featuresCount, elementsPerFeature, dirFs0Xs, dataFileName, dirLabels, labelSunriseSunsetDayNightFileName);
resultsFs0XsMonth = LOONN(featuresCount, elementsPerFeature, dirFs0Xs, dataFileName, dirLabels, labelMonthFileName);
resultsFs0XsHalfMonth = LOONN(featuresCount, elementsPerFeature, dirFs0Xs, dataFileName, dirLabels, labelHalfMonthFileName);

fprintf("> LOONN 0.Xs, no filters: end\n\n");


%% LOONN all features, fs 1s, no filters

dirFs1s = "templates_fs1s";
elementsPerFeature = 120;

fprintf("> LOONN 1s, no filters: start\n");
resultsFs1sYat = LOONN(featuresCount, elementsPerFeature, dirFs1s, dataFileName, dirLabels, labelYatFileName);
resultsFs1sDayNight = LOONN(featuresCount, elementsPerFeature, dirFs1s, dataFileName, dirLabels, labelDayNightFileName);
resultsFs1sSunriseSunset = LOONN(featuresCount, elementsPerFeature, dirFs1s, dataFileName, dirLabels, labelSunriseSunsetFileName);
resultsFs1sSunriseSunsetDayNight = LOONN(featuresCount, elementsPerFeature, dirFs1s, dataFileName, dirLabels, labelSunriseSunsetDayNightFileName);
resultsFs1sMonth = LOONN(featuresCount, elementsPerFeature, dirFs1s, dataFileName, dirLabels, labelMonthFileName);
resultsFs1sHalfMonth = LOONN(featuresCount, elementsPerFeature, dirFs1s, dataFileName, dirLabels, labelHalfMonthFileName);
fprintf("> LOONN 1s, no filters: end\n");


%% RESULTS TABLE
resultType = resultsFs0XsYat.results;
isStandardized = resultsFs0XsYat.isStandardized;
headers = {'CheckType', 'IsStandardized', 'Yat', 'DayNight', 'SunriseSunset', 'SunriseSunsetDayNight', 'Month', 'HalfMonth'};

fprintf("> CHECKS LOONN all features, fs 0.Xs, no filters\n\n");
disp(table(resultType, ...
            isStandardized, ...
            resultsFs0XsYat.values, ...
            resultsFs0XsDayNight.values, ...
            resultsFs0XsSunriseSunset.values, ...
            resultsFs0XsSunriseSunsetDayNight.values, ...
            resultsFs0XsMonth.values, ...
            resultsFs0XsHalfMonth.values, ...
            'VariableNames', headers) ...
    );

fprintf("> CHECKS LOONN all features, fs 1s, no filters\n\n");
disp(table(resultType, ...
            isStandardized, ...
            resultsFs1sYat.values, ...
            resultsFs1sDayNight.values, ...
            resultsFs1sSunriseSunset.values, ...
            resultsFs1sSunriseSunsetDayNight.values, ...
            resultsFs1sMonth.values, ...
            resultsFs1sHalfMonth.values, ...
            'VariableNames', headers) ...
    );