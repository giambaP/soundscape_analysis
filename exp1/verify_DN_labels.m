clc
clear all
close all

numOfDays = 31;
counterRow = 1;
for YAT = 1
    %audio per days
    for i = 1:numOfDays
        % audio per hours
        for j = 0:23
            % create file name
            flName = '202003';
            if i < 10
                flName = strcat(flName,'0',num2str(i));
            else
                flName = strcat(flName,num2str(i));
            end
            % audio per half hour
            for h = [0 3]
                if j < 10
                    nm = strcat(flName,'_0',num2str(j), num2str(h),'000.WAV');
                else
                    nm = strcat(flName,'_',num2str(j), num2str(h),'000.WAV');
                end

                audioName = strcat('./databaseDN/YAT', num2str(YAT),'Audible/', nm);
                if ~exist(audioName, "file")
                    fprintf("WARN - file not found: file name '%s' \n", audioName);
                else
                    label = 0; % night
                    if j >= 6 && (j <= 17) % day >6 e <17:59
                        label = 1;
                    end
                    fprintf('%d) %s -> label %d\n',counterRow, audioName, label);
                    counterRow = counterRow + 1;
                end
            end
        end
    end
end