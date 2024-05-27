clc; clear all; close all

numOfDays = 31;

nomefs{1} = 'SpectralCentroid';
nomefs{2} = 'SpectralCrestFactor';
nomefs{3} = 'SpectralDecrease';
nomefs{4} = 'SpectralFlatness';
nomefs{5} = 'SpectralFlux';
nomefs{6} = 'SpectralRolloff';
nomefs{7} = 'SpectralSpread';
nomefs{8} = 'SpectralTonalPowerRatio';
nomefs{9} = 'TimeZeroCrossingRate';
nomefs{10} = 'TimeAcfCoeff';
nomefs{11} = 'TimeMaxAcf';
nomefs{12} = 'SpectralMfccs';
fss = 1:12;

nomeexp = './templatesYAT/PrimoExp';

data = [];
MfccsSet = [];

for fs = fss
    fprintf('Extracting Feature %s\n',nomefs{fs});
    sname = strcat(nomeexp,'_',nomefs{fs},'.mat');
    if exist(sname, "file")
        load(sname);
    else        
        counterRow = 1;
        clear featuresSet
        clear labels
        for YAT = 1:3
            fprintf('Extracting YAT %d\n',YAT);
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
                    fprintf('%d) %s\n',counterRow,nm);
                    A = exist(strcat('./databaseYAT/YAT', num2str(YAT),'Audible/',nm));
                    if A
                        audioName =  strcat('./databaseYAT/YAT',num2str(YAT),'Audible/',nm);
                        labels(counterRow) = YAT;
                        %load the audio

                        
                        [y, f_s] = audioread(audioName);
                        iBlockLength = 4096 * 8;
                        iHopLength = 2048 * 8;

                        [X, f, t] = ComputeSpectrogram(y, f_s, [], iBlockLength, iHopLength);

                        switch fs
                            case 1
                                fsval = FeatureSpectralCentroid(X, f_s);
                            case 2
                                fsval = FeatureSpectralCrestFactor(X, f_s);
                            case 3
                                fsval = FeatureSpectralDecrease(X, f_s);
                            case 4
                                fsval = FeatureSpectralFlatness(X, f_s);
                            case 5
                                fsval = FeatureSpectralFlux(X, f_s);
                            case 6
                                fsval = FeatureSpectralRolloff(X, f_s);
                            case 7
                                fsval = FeatureSpectralSpread(X, f_s);
                             case 8
                                fsval = FeatureSpectralTonalPowerRatio(X, f_s);
                            case 9
                                fsval = FeatureTimeZeroCrossingRate(y, iBlockLength, iHopLength, f_s);
                            case 10
                                fsval = FeatureTimeAcfCoeff(y, iBlockLength, iHopLength, f_s);
                            case 11
                                fsval = FeatureTimeMaxAcf(y, iBlockLength, iHopLength, f_s);
                            case 12
                                fsMfcc = FeatureSpectralMfccs(X, f_s);
                        end
                        if(fs ~= 12)
                            featuresSet(counterRow,:) = fsval;
                        else
                            MfccsSet = [MfccsSet fsMfcc];
                        end
                        counterRow = counterRow + 1;
                    end
                end
            end
        end
        if(fs ~= 12)
            save(sname,'featuresSet','labels');
        else
            save(sname, 'MfccsSet', 'labels');
        end
    end
    if(fs ~= 12)
        data = [data featuresSet];
        save('./templatesYAT/matriceYAT.mat', 'data', 'labels')
    end
end