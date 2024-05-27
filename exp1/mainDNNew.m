clc
close all
clear all

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

nomeexp = '/home/andrea/Scrivania/Tirocinio/DayNight/templatesDN/PrimoExp';

data = [];


for fs = fss
    fprintf('Extracting Feature %s\n',nomefs{fs});
    sname = strcat(nomeexp,'_',nomefs{fs},'.mat');
    if ~exist(sname)
        counterRow = 1;
        clear featuresSet
    
        for i = 1:31
            for k = 0:23
               for j = 1:2
            % creazione nome file
            nm = '202003';
     
            if i < 10
                nm = strcat(nm,'0',num2str(i));
            else
                nm = strcat(nm,num2str(i));
            end
            nm = strcat(nm,'_');
        
                if k < 10
                    nm = strcat(nm, '0', num2str(k)); 
                else 
                    nm = strcat(nm, num2str(k));
                end
        
                if mod(j,2)
                    nm = strcat(nm, '0000.WAV');
                else
                    nm = strcat(nm, '3000.WAV');
                end
                j = 2;
                A = exist(strcat('/home/andrea/Scrivania/Tirocinio/DayNight/databaseDN/',nm));
                if A
                fprintf('%d) %s\n',counterRow,nm);
                    audioName =  strcat('/home/andrea/Scrivania/Tirocinio/DayNight/databaseDN/',nm);
                    %load the audio
                    [y, f_s] = audioread(audioName);
                    [X, f, t] = ComputeSpectrogram(y, f_s);

                    iBlockLength = 4096 * 8;
                    iHopLength = 2048 * 8;

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
                                fsval = FeatureSpectralMfccs(X, f_s);
                        end
                        featuresSet(counterRow,:) = fsval;
                        counterRow = counterRow + 1;
                   end
               end
            end
        end
        
        save(sname, 'featuresSet')
    else
        load(sname);
    end
        data = [data featuresSet];
end
    
