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


%% filtering idenfied matrix searching for
% 		      TYPE                  1	      2	           3	1	2	3
% BINARIO	ANTRO vs GEO	     vehicle	rain	         	55	45	
% BINARIO	ANTRO vs BIO	     vehicle	crickets		    55	36	
% BINARIO	BIO vs GEO	         crickets	thunder	         	51	55	
% BINARIO 	BIO vs GEO	         crickets	rain		        52	61	
% TERNARIO	ANTRO vs BIO vs GEO	 vehicle	crickets	thunder	36	30	36
% TERNARIO	ANTRO vs BIO vs GEO	 vehicle	crickets	rain	34	31	40

%% creating matrix subset of identified labels matrix with only vehicle,crickets,rain
resultTable = dataSounds(:,:);

% binary
totRows = size(resultTable, 1);
labelVehicleRain = zeros(totRows, 1) .* -1;
labelVehicleCrickets = zeros(totRows, 1) .* -1;
labelCricketsThunder = zeros(totRows, 1) .* -1;
labelCricketsRain = zeros(totRows, 1) .* -1;
% tertiary
labelSubsetVehicleCricketsRain = zeros(totRows, 1) .* -1;
labelSubsetVehicleCricketsThunder = zeros(totRows, 1) .* -1;

function class = filterClass(values)
    valuesCount = size(values,2);
    % only if class exists for one type at time
    if sum(values) ~= 1
        class = -1;
    else
        if valuesCount > 0 && values(1,1)==1; class = 1;
        elseif valuesCount > 1 && values(1,2)==1; class = 2;
        elseif valuesCount > 2 && values(1,3)==1; class = 3;
        else; error("Invalid case..");
        end
    end    
end

for i=1:totRows
    isVehicle = resultTable{i, "vehicle"};
    isCrickets = resultTable{i, "crickets"};
    isRain = resultTable{i, "rain"};
    isThunder = resultTable{i, "thunder"};

    labelVehicleRain(i,1) = filterClass([isVehicle,isRain]);
    labelVehicleCrickets(i,1) = filterClass([isVehicle,isCrickets]);
    labelCricketsThunder(i,1) = filterClass([isCrickets,isThunder]);
    labelCricketsRain(i,1) = filterClass([isCrickets,isRain]);
    labelSubsetVehicleCricketsRain(i,1) = filterClass([isVehicle,isCrickets,isRain]);
    labelSubsetVehicleCricketsThunder(i,1) = filterClass([isVehicle,isCrickets,isThunder]);    
end

% filter negative labels (mean not considered)
function res = countTypes(labels)
 res = groupcounts(labels(labels > 0,1));
end

% checking result
disp(table(["Vehicle", "Rain"]', countTypes(labelVehicleRain), 'VariableNames', ["Type", "Count"]));
disp(table(["Vehicle", "Crickets"]', countTypes(labelVehicleCrickets), 'VariableNames', ["Type", "Count"]));
disp(table(["Crickets", "Thunder"]', countTypes(labelCricketsThunder), 'VariableNames', ["Type", "Count"]));
disp(table(["Crickets", "Rain"]', countTypes(labelCricketsRain), 'VariableNames', ["Type", "Count"]));
disp(table(["Vehicle", "Crickets", "Rain"]', countTypes(labelSubsetVehicleCricketsRain), 'VariableNames', ["Type", "Count"]));
disp(table(["Vehicle", "Crickets", "Thunder"]', countTypes(labelSubsetVehicleCricketsThunder), 'VariableNames', ["Type", "Count"]));


resultTable = removevars(resultTable, {'vehicle','birds','crickets','river_waterfall','rain','thunder','noise','unknown'});
resultTable = addvars(resultTable, labelVehicleRain, labelVehicleCrickets, labelCricketsThunder, labelCricketsRain, labelSubsetVehicleCricketsRain, labelSubsetVehicleCricketsThunder);
writetable(resultTable, sprintf('%s/audio_data_identified_with_labels_subset.dat', dirLabels));