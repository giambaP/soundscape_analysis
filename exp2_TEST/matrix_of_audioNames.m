clc
clear all
close all

if (~exist("./templatesYAT/audio_name.mat"))
    k = 0;
    numOfDays = 31;
    audioMat = {};
    numAudio = (6*31*3) -2;
    for YAT = 1:3
        %audio per days
        for i = 1:numOfDays
            %audio per hours
            for j = [2 6 10 14 18 22]
                %create file name
                nm = '202003';
                if i < 10
                    nm = strcat(nm,'0',num2str(i));
                else
                    nm = strcat(nm,num2str(i));
                end
                if j < 10
                    nm = strcat(nm,'_0',num2str(j),'0000.WAV');
                else
                    nm = strcat(nm,'_',num2str(j),'0000.WAV');
                end
                A = exist(strcat('./databaseYAT/YAT', num2str(YAT),'Audible/',nm));
                if A
                    audioName =  strcat('YAT',num2str(YAT),'_',nm);
                    k = k + 1;
                    audioMat{k} = audioName;
                end
            end
        end
    end
    audioMat = audioMat';
    save('./templatesYAT/audio_name.mat', 'audioMat');
end