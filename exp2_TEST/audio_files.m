clc; clear all; close all

sourceDir = "../downloadAllAudible/datasetAll";
targetDir = './templates/';

matrixFileName = "audio_data.mat";

yats = [1 2 3];
years = 2020;
months = [3 4 5];
days = 1:31;
hours = 0:23;
minutes = [00 30];


audioMatrixDataPath = sprintf("%s%s", targetDir, matrixFileName);

if exist(audioMatrixDataPath, "file")
    fprintf('>> result already exists, generation of "%s" skipped \n', matrixFileName);
elseif ~exist(targetDir, "dir")    
    fprintf('>> target dir not exists, check "%s"\n', targetDir);
else
    % approximate value
    filesCount = length(yats) * length(years) * length(months) * length(days) * length(hours) * length(minutes);
    % rows: { files }, 
    % column: { 1.uniqueName(yat_audioName) 2.audioName, 3.audioNameNoExtension 4.yat, 
    %           5.year, 6.month, 7.day, 8.hour, 9.minute, 10.seconds }
    audioData = cell(filesCount, 8);

    rowId = 0;

    tic;

    % yat
    for yat = yats
        fprintf('>> YAT %d start  \n', yat);
        filesPerYat= 0;
        tic;

        for year = years
            for month = months
                fprintf('>> YAT %d, MONTH %d start \n', yat, month);
                filesPerMonth = 0;
                tic;

                for day = days
                    for hour = hours
                        for minute = minutes
                            audioNameNoExtension = sprintf("%04d%02d%02d_%02d%02d%s", year, month, day, hour, minute, "00");
                            audioName = sprintf("%s.WAV", audioNameNoExtension);
                            audioFilePath = sprintf("%s/YAT%dAudible/%s", sourceDir, yat, audioName);

                            if ~exist(audioFilePath, "file")
                                fprintf("# WARN - file not found: file name '%s' \n", audioName);
                            else
                                % fprintf('%04d) %s\n', rowId, audioName);

                                uniqueName = sprintf("yat%d_%s", yat, audioNameNoExtension);

                                rowId = rowId + 1;
                                filesPerMonth = filesPerMonth + 1;
                                filesPerYat = filesPerYat + 1;

                                audioData{rowId, 1} = uniqueName;
                                audioData{rowId, 2} = audioName;
                                audioData{rowId, 3} = audioNameNoExtension;
                                audioData{rowId, 4} = yat;
                                audioData{rowId, 5} = year;
                                audioData{rowId, 6} = month;
                                audioData{rowId, 7} = day;
                                audioData{rowId, 8} = hour;
                                audioData{rowId, 9} = minute;
                                audioData{rowId, 10} = 0;
                            end
                        end
                    end
                end

                elapsedPerMonth = toc;
                fprintf('>> YAT %d, MONTH %d end, %d files in %.4f s, %.4f files/s \n', ...
                    yat, month, filesPerMonth, elapsedPerMonth, filesPerMonth/elapsedPerMonth);
            end
            
        end

        elapsedPerYat = toc;
        fprintf('>> YAT %d end, %d files in %.4f s, %.4f files/s \n', ...
            yat, filesPerYat, elapsedPerYat, filesPerYat/elapsedPerYat);
    end
    
    % filtering pre allocated empty rows
    audioData = audioData(1:rowId, :);

    save(audioMatrixDataPath, 'audioData');

    elapsedTotal = toc;
    fprintf('Exec time in %.6f sec\n', elapsedTotal);

end

