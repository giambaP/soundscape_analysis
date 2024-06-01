clc; clear all; close all;

sourceDir = './templates/';
targetDir = './templates/';

matrixFileName = "audio_data.mat";
labelsYatFileName = "labelsYAT.mat";
labelsDNFileName = "labelsDN.mat";

audioMatrixDataPath = sprintf("%s%s", sourceDir, matrixFileName);

if ~exist(targetDir, "dir")
    fprintf('>> target dir not exists, check "%s"\n', targetDir);
elseif ~exist(audioMatrixDataPath, "file")
    fprintf('>> audio file name matrix not exists, name "%s"\n', matrixFileName);
end

load(audioMatrixDataPath);

% audioData structure
uniqueNameColumn = 1;
audioNameColumn = 2;
audioNameNoExtensionColumn = 3;
yatColumn = 4;
yearColumn = 5;
monthColumn = 6;
dayColumn = 7;
hourColumn = 8;
minuteColumn = 9;

% labels yat: filtering on relative column
labelsYAT = audioData(:, yatColumn);
labelsYAT = cell2mat(labelsYAT);
save(sprintf("%s/labelsYAT.mat", targetDir), "-fromstruct", struct("labelsYAT", labelsYAT));

% labels day night: filtering hour column, then by day hours range 6 -> 17:59
hoursColumnData = audioData(:, hourColumn);
hoursColumnData = cell2mat(hoursColumnData);
dayTimeRowsIndx = find(hoursColumnData >= 6 & hoursColumnData <= 17);
labelsDN = zeros(size(hoursColumnData, 1), 1);
labelsDN(dayTimeRowsIndx) = 1;
save(sprintf("%s/labelsDN.mat", targetDir), "-fromstruct", struct("labelsDN", labelsDN));

