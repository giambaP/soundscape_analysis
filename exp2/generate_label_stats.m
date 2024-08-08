clc; clear all; close all;

sourceDir = './labels/';
targetDir = './labels/';

matrixFileName = "audio_data.mat";

audioMatrixDataPath = sprintf("%s%s", sourceDir, matrixFileName);
if ~exist(audioMatrixDataPath, "file")
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

[count, groupNames] = groupcounts(labelsYAT);
disp(" ");
disp(table(groupNames, count, 'VariableNames', ["YAT TYPE", "Count"]));

%% DAY / NIGHT

% filtering hour column, then by day hours range 6 -> 17:59
hoursColumnData = cell2mat(audioData(:, hourColumn));
dayTimeRowsIndx = hoursColumnData >= 6 & hoursColumnData <= 17;
lablesDayNight = zeros(size(hoursColumnData, 1), 1);
lablesDayNight(dayTimeRowsIndx) = 1; % night 0,  day 1

[count, ~] = groupcounts(lablesDayNight);
disp(" ");
disp(table(["Night", "Day"]', count, 'VariableNames', ["D/N TYPE", "Count"]));

%% SUNRISE / SUNSET ( with the rest of day)

% filtering hour column, 2 classes, sunrise 5-6-7 and sunset 18-19-20 from
% the rest of the day
hoursColumnData = cell2mat(audioData(:, hourColumn));
hourValues = [5, 6, 7, 18, 19, 20];
labelsSunriseSunset = ismember(hoursColumnData, hourValues);
% sr/ss 1, rest 0

[count, ~] = groupcounts(labelsSunriseSunset);
disp(" ");
disp(table(["Rest of day", "Sunrise/sunset"]', count, 'VariableNames', ["(SR|SS)/rest of day", "Count"]));


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

[count, groupNames] = groupcounts(labelsSunriseSunsetDayNight);
disp(" ");
disp(table(["Sunrise", "Day", "Sunset", "Night"]', count, 'VariableNames', ["Sunrise/Sunset/Day/Night", "Count"]));

%% MONTH

% column month
labelMonth = cell2mat(audioData(:, monthColumn));

[count, groupNames] = groupcounts(labelMonth);
disp(" ");
disp(table(["March", "April", "May"]', count, 'VariableNames', ["Month", "Count"]));


%% HALF MONTH

% filtering day  column, days 1-15 value 1, range 
dayColumnData = cell2mat(audioData(:, dayColumn));
halfMonthDaysValues = 1:15;
labelsHalfMonth = ismember(dayColumnData, halfMonthDaysValues);

[count, groupNames] = groupcounts(labelsHalfMonth);
disp(" ");
disp(table(["First half", "Second Half"]', count, 'VariableNames', ["Half Month", "Count"]));