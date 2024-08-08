clc; clear all; close all;

dirLabels = "labels";
labelsFileName = "audio_data_identified_with_labels.dat";


%% preparing

% retrieving labels
dataSounds = readtable(sprintf("%s/%s", dirLabels, labelsFileName));
labelsVehicle = dataSounds.vehicle;
labelBirds = dataSounds.birds;
labelsCrickets = dataSounds.crickets;
labelsRiverWaterfall = dataSounds.river_waterfall;
labelsRain = dataSounds.rain;
labelsThunder = dataSounds.thunder;
labelsNoise = dataSounds.noise;
labelsUnknown = dataSounds.unknown;


%% search best combination on two label
labelNames = ["vehicle","birds","crickets","river_waterfall","rain","thunder","noise","unknown"];
labelData = [labelsVehicle, labelBirds, labelsCrickets, labelsRiverWaterfall, labelsRain, labelsThunder, labelsNoise, labelsUnknown];

totRows = size(labelData, 1);
perms = nchoosek(1:size(labelNames, 2), 2);
results = strings(size(perms,1), 11);
% for each permutation
for i=1:size(perms,1)
    lblIdx1 = perms(i, 1);
    lblIdx2 = perms(i, 2);
    label1 = labelNames(1, lblIdx1);
    label2 = labelNames(1, lblIdx2);
    dataset1 = labelData(:, lblIdx1);
    dataset2 = labelData(:, lblIdx2);
    
    c1 = 0;
    c2 = 0;
    both = 0;
    % for each row
    for j=1:totRows
        val1 = dataset1(j);
        val2 = dataset2(j);
        if val1==1 && val2==1 
            both = both+1;
        elseif val1==1
            c1 = c1+1;
        elseif val2==1
            c2 = c2+1;
        end
    end

    c1Perc = (c1/totRows)*100;
    c2Perc = (c2/totRows)*100;
    bothPerc = (both/totRows)*100;
    distance = (abs(c1 - c2) / totRows) * 100;
    
    results(i, :) = [ i, ... 
        sprintf("%d-%d", lblIdx1, lblIdx2), ...
        sprintf("%s", label1), ...
        sprintf("%s", label2), ...
        sprintf("%d", c1), ... % c1
        sprintf("%d", c2), ... % c2
        sprintf("%d", both), ... % both
        sprintf("%0.1f", round(c1Perc,1)), ... % c1 perc
        sprintf("%0.1f", round(c2Perc,1)), ... % c2 perc
        sprintf("%0.1f", round(bothPerc,1)),... % both perc 
        distance
    ];
end

table = array2table(results);
table.Properties.VariableNames(:) = {'Index', 'Comb', 'VAR_1', 'VAR_2', 'Cnt1', 'Cnt2', 'CntRest', 'Perc1', 'Perc2', 'PercRest', 'distance'};

writetable(table, sprintf('%s/best_tests_2label_combination.csv', dirLabels));

%% search best combination on three label
labelNames = ["vehicle","birds","crickets","river_waterfall","rain","thunder","noise","unknown"];
labelData = [labelsVehicle, labelBirds, labelsCrickets, labelsRiverWaterfall, labelsRain, labelsThunder, labelsNoise, labelsUnknown];

totRows = size(labelData, 1);
perms = nchoosek(1:size(labelNames, 2), 3);
results = strings(size(perms,1), 10);
% for each permutation
for i=1:size(perms,1)
    lblIdx1 = perms(i, 1);
    lblIdx2 = perms(i, 2);
    lblIdx3 = perms(i, 3);
    label1 = labelNames(1, lblIdx1);
    label2 = labelNames(1, lblIdx2);
    label3 = labelNames(1, lblIdx3);
    dataset1 = labelData(:, lblIdx1);
    dataset2 = labelData(:, lblIdx2);
    dataset3 = labelData(:, lblIdx3);
    
    c1 = 0;
    c2 = 0;
    c3 = 0;    % for each row
    both = 0;
    for j=1:totRows
        val1 = dataset1(j);
        val2 = dataset2(j);
        val3 = dataset3(j);
        if sum([val1,val2,val3]) ~= 1
            both = both+1;
        elseif val1==1
            c1 = c1+1;
        elseif val2==1
            c2 = c2+1;
        elseif val3==1
            c3 = c3+1;        
        end
    end

    if sum([c1,c2,c3,both])~=totRows
        error("WRONG COUNT");
    end

    c1Perc = (c1/totRows)*100;
    c2Perc = (c2/totRows)*100;
    c3Perc = (c3/totRows)*100;
    bothPerc = (both/totRows)*100;
    distance = max([c1,c2,c3]) - min([c1,c2,c3]);
    
    results(i, :) = [ i, ... 
        sprintf("%d-%d-%d", lblIdx1, lblIdx2, lblIdx3), ...
        sprintf("%s", label1), ...
        sprintf("%s", label2), ...
        sprintf("%s", label3), ...
        sprintf("%d", c1), ... % c1
        sprintf("%d", c2), ... % c2
        sprintf("%d", c3), ... % c3
        sprintf("%d", both), ... % both
        distance
    ];
end

table = array2table(results);
table.Properties.VariableNames(:) = {'Index', 'Comb', 'VAR_1', 'VAR_2', 'VAR_3', 'Cnt1', 'Cnt2', 'Cnt3', 'CntRest', 'distance'};

writetable(table, sprintf('%s/best_tests_3label_combination.csv', dirLabels));

%% search best combination on fourth label
labelNames = ["vehicle","birds","crickets","river_waterfall","rain","thunder","noise","unknown"];
labelData = [labelsVehicle, labelBirds, labelsCrickets, labelsRiverWaterfall, labelsRain, labelsThunder, labelsNoise, labelsUnknown];

totRows = size(labelData, 1);
perms = nchoosek(1:size(labelNames, 2), 4);
results = strings(size(perms,1), 12);
% for each permutation
for i=1:size(perms,1)
    lblIdx1 = perms(i, 1);
    lblIdx2 = perms(i, 2);
    lblIdx3 = perms(i, 3);
    lblIdx4 = perms(i, 4);
    label1 = labelNames(1, lblIdx1);
    label2 = labelNames(1, lblIdx2);
    label3 = labelNames(1, lblIdx3);
    label4 = labelNames(1, lblIdx4);
    dataset1 = labelData(:, lblIdx1);
    dataset2 = labelData(:, lblIdx2);
    dataset3 = labelData(:, lblIdx3);
    dataset4 = labelData(:, lblIdx4);
    
    c1 = 0;
    c2 = 0;
    c3 = 0;
    c4 = 0;
    % for each row
    both = 0;
    for j=1:totRows
        val1 = dataset1(j);
        val2 = dataset2(j);
        val3 = dataset3(j);
        val4 = dataset4(j);
        if sum([val1,val2,val3, val4]) ~= 1
            both = both+1;
        elseif val1==1
            c1 = c1+1;
        elseif val2==1
            c2 = c2+1;
        elseif val3==1
            c3 = c3+1;        
        elseif val4==1
            c4 = c4+1;        
        end
    end

    if sum([c1,c2,c3,c4,both])~=totRows
        error("WRONG COUNT");
    end

    c1Perc = (c1/totRows)*100;
    c2Perc = (c2/totRows)*100;
    c3Perc = (c3/totRows)*100;
    c4Perc = (c4/totRows)*100;
    bothPerc = (both/totRows)*100;
    distance = max([c1,c2,c3,c4]) - min([c1,c2,c3,c4]);
    
    results(i, :) = [ i, ... 
        sprintf("%d-%d-%d", lblIdx1, lblIdx2, lblIdx3), ...
        sprintf("%s", label1), ...
        sprintf("%s", label2), ...
        sprintf("%s", label3), ...
        sprintf("%s", label4), ...
        sprintf("%d", c1), ... % c1
        sprintf("%d", c2), ... % c2
        sprintf("%d", c3), ... % c3
        sprintf("%d", c4), ... % c4
        sprintf("%d", both), ... % both
        distance
    ];
end

table = array2table(results);
table.Properties.VariableNames(:) = {'Index', 'Comb', 'VAR_1', 'VAR_2', 'VAR_3', 'VAR_4', 'Cnt1', 'Cnt2', 'Cnt3', 'Cnt4', 'CntRest', 'distance'};

writetable(table, sprintf('%s/best_tests_4label_combination.csv', dirLabels));


% %% search best combination on fourth label
% labelNames = ["vehicle","birds","crickets","river_waterfall","rain","thunder","noise","unknown"];
% labelData = [labelsVehicle, labelBirds, labelsCrickets, labelsRiverWaterfall, labelsRain, labelsThunder, labelsNoise, labelsUnknown];
% 
% totRows = size(labelData, 1);
% perms = nchoosek(1:size(labelNames, 2), 5);
% results = strings(size(perms,1), 14);
% % for each permutation
% for i=1:size(perms,1)
%     lblIdx1 = perms(i, 1);
%     lblIdx2 = perms(i, 2);
%     lblIdx3 = perms(i, 3);
%     lblIdx4 = perms(i, 4);
%     lblIdx5 = perms(i, 5);
%     label1 = labelNames(1, lblIdx1);
%     label2 = labelNames(1, lblIdx2);
%     label3 = labelNames(1, lblIdx3);
%     label4 = labelNames(1, lblIdx4);
%     label5 = labelNames(1, lblIdx5);
%     dataset1 = labelData(:, lblIdx1);
%     dataset2 = labelData(:, lblIdx2);
%     dataset3 = labelData(:, lblIdx3);
%     dataset4 = labelData(:, lblIdx4);
%     dataset5 = labelData(:, lblIdx5);
% 
%     c1 = 0;
%     c2 = 0;
%     c3 = 0;
%     c4 = 0;
%     c5 = 0;
%     % for each row
%     both = 0;
%     for j=1:totRows
%         val1 = dataset1(j);
%         val2 = dataset2(j);
%         val3 = dataset3(j);
%         val4 = dataset4(j);
%         val5 = dataset5(j);
%         if sum([val1,val2,val3, val4, val5]) ~= 1
%             both = both+1;
%         elseif val1==1
%             c1 = c1+1;
%         elseif val2==1
%             c2 = c2+1;
%         elseif val3==1
%             c3 = c3+1;        
%         elseif val4==1
%             c4 = c4+1;
%         elseif val5==1
%             c5 = c5+1;        
%         end
%     end
% 
%     if sum([c1,c2,c3,c4,c5,both])~=totRows
%         error("WRONG COUNT");
%     end
% 
%     c1Perc = (c1/totRows)*100;
%     c2Perc = (c2/totRows)*100;
%     c3Perc = (c3/totRows)*100;
%     c4Perc = (c4/totRows)*100;
%     c5Perc = (c5/totRows)*100;
%     bothPerc = (both/totRows)*100;
%     distance = max([c1,c2,c3,c4,c5]) - min([c1,c2,c3,c4,c5]);
% 
%     results(i, :) = [ i, ... 
%         sprintf("%d-%d-%d", lblIdx1, lblIdx2, lblIdx3), ...
%         sprintf("%s", label1), ...
%         sprintf("%s", label2), ...
%         sprintf("%s", label3), ...
%         sprintf("%s", label4), ...
%         sprintf("%s", label5), ...
%         sprintf("%d", c1), ... % c1
%         sprintf("%d", c2), ... % c2
%         sprintf("%d", c3), ... % c3
%         sprintf("%d", c4), ... % c4
%         sprintf("%d", c5), ... % c5
%         sprintf("%d", both), ... % both
%         distance
%     ];
% end
% 
% table = array2table(results);
% table.Properties.VariableNames(:) = {'Index', 'Comb', 'VAR_1', 'VAR_2', 'VAR_3', 'VAR_4', 'VAR_5', 'Cnt1', 'Cnt2', 'Cnt3', 'Cnt4', 'Cnt5', 'CntRest', 'distance'};
% 
% writetable(table, sprintf('%s/best_tests_5label_combination.csv', dirLabels));