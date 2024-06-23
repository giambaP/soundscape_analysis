clc; clear all; close all;

sourceDir = './labels/';
targetDir = './labels/';

matrixFileName = "audio_data.mat";
labelsYatFileName = "labelsYAT.mat";
labelsDNFileName = "labelsDN.mat";

audioMatrixDataPath = sprintf("%s%s", sourceDir, matrixFileName);

if ~exist(targetDir, "dir")
    fprintf('>> target dir not exists, check "%s"\n', targetDir);
elseif ~exist(audioMatrixDataPath, "file")
    fprintf('>> audio file name matrix not exists, name "%s"\n', matrixFileName);
end

% audioData structure
uniqueNameColumn = AudioDataColumnIndex.UniqueName.index;
audioNameColumn = AudioDataColumnIndex.AudioName.index;
audioNameNoExtensionColumn = AudioDataColumnIndex.AudioNameNoExtension.index;
yatColumn = AudioDataColumnIndex.Yat.index;
yearColumn = AudioDataColumnIndex.Year.index;
monthColumn = AudioDataColumnIndex.Month.index;
dayColumn = AudioDataColumnIndex.Day.index;
hourColumn = AudioDataColumnIndex.Hour.index;
minuteColumn = AudioDataColumnIndex.Minute.index;

%% EXECUTION

load(audioMatrixDataPath);

%% YAT

% column yat
labelsYAT = cell2mat(audioData(:, yatColumn));
save(sprintf("%s/labels_Yat.mat", targetDir), "-fromstruct", struct("labels", labelsYAT));

%% DAY / NIGHT

% filtering hour column, then by day hours range 6 -> 17:59
hoursColumnData = cell2mat(audioData(:, hourColumn));
dayTimeRowsIndx = hoursColumnData >= 6 & hoursColumnData <= 17;
lablesDayNight = zeros(size(hoursColumnData, 1), 1);
lablesDayNight(dayTimeRowsIndx) = 1;
save(sprintf("%s/labels_DayNight.mat", targetDir), "-fromstruct", struct("labels", lablesDayNight));

%% SUNRISE / SUNSET

% filtering hour column, 2 classes, sunrise 5-6-7 and sunset 18-19-20 from
% the rest of the day
hoursColumnData = cell2mat(audioData(:, hourColumn));
hourValues = [5, 6, 7, 18, 19, 20];
labelsSunriseSunset = ismember(hoursColumnData, hourValues);
save(sprintf("%s/labels_SunriseSunset.mat", targetDir), "-fromstruct", struct("labels", labelsSunriseSunset));

%% SUNRISE / SUNSET / DAY / NIGHT

% filtering hour column, 4 classes, sunrise 5-6-7, sunset 18-19-20, rest of
% day and rest of night
hoursColumnData = cell2mat(audioData(:, hourColumn));
sunRiseValues = [5, 6, 7];
dayValues = 8:17;
sunSetValues = [18, 19, 20];
nightValues = [21:23, 0:4];
labelsSunriseSunsetDayNight = zeros(size(hoursColumnData, 1), 1);
labelsSunriseSunsetDayNight(ismember(hoursColumnData, sunRiseValues) == 1) = 1;
labelsSunriseSunsetDayNight(ismember(hoursColumnData, dayValues) == 1) = 2;
labelsSunriseSunsetDayNight(ismember(hoursColumnData, sunSetValues) == 1) = 3;
labelsSunriseSunsetDayNight(ismember(hoursColumnData, nightValues) == 1) = 4;
save(sprintf("%s/labels_SunriseSunsetDayNight.mat", targetDir), "-fromstruct", struct("labels", labelsSunriseSunsetDayNight));

%% MONTH

% column month
labelMonth = cell2mat(audioData(:, monthColumn));
save(sprintf("%s/labels_Month.mat", targetDir), "-fromstruct", struct("labels", labelMonth));

%% HALF MONTH

% filtering day  column, days 1-15 value 1, range 
dayColumnData = cell2mat(audioData(:, dayColumn));
halfMonthDaysValues = 1:15;
labelsHalfMonth = ismember(dayColumnData, halfMonthDaysValues);
save(sprintf("%s/labels_HalfMonth.mat", targetDir), "-fromstruct", struct("labels", labelsHalfMonth));




%% FINAL CHECKS

rangeData = [1:20,600:620,2000:2030,4000:5015,8030:8045];

yatData = cell2mat(audioData(:, yatColumn));
monthData = cell2mat(audioData(:, monthColumn));
dayData = cell2mat(audioData(:, dayColumn));
hourData = cell2mat(audioData(:, hourColumn));

disp(table(yatData(rangeData), labelsYAT(rangeData), 'VariableNames', ["Yat", "LabelYat"]));
disp("\n");
disp(table(monthData(rangeData), labelMonth(rangeData), 'VariableNames', ["Month", "LabelMonth"]));
disp("\n");
disp(table(dayData(rangeData), labelsHalfMonth(rangeData), 'VariableNames', ["Day", "HalfMonth"]));
disp("\n");
disp(table(hourData(rangeData), lablesDayNight(rangeData), labelsSunriseSunset(rangeData), labelsSunriseSunsetDayNight(rangeData), ...
    'VariableNames', ["Hours", "LabelDay/Night", "LabelSunrise/Sunset", "LabelSunrise/Sunset/Day/Night"]));