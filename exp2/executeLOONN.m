%computes Leave One Out with KNN
%>
%> @param featuresCount: numbers of features to consider
%> @param elementsPerFeatures: elements for each feature to consider inside
%data
%> @param data: n x m matrix with rows as elements and column as features
%data
%> @param labels: n x 1 matrix with labels of data
%> @param printResults: 0 to avoid results printing (default 1)
%>
%> @retval results: n x 32 cell matrix: rows every result, columns {label, error, standardization on/off}
% ======================================================================
function results = executeLOONN(featuresCount, elementsPerFeature, data, labels, printResults, printExecution)

objsCount = size(data, 1);
labelsCount = size(labels, 1);
if objsCount ~= labelsCount
    warning("labels count is different from object count: labels data will be reducted to data size. " + ...
        "objs %d, labels %d", objsCount, labelsCount);
end

labels = labels(1:objsCount,1);

featSize = elementsPerFeature;
allFeaturesIdxs = 1:(featSize*11);

spectralCentroidIdxs = 1:featSize;
spectralCrestFactorIdxs = (featSize*1+1):(featSize*2);
spectralDecreaseIdxs = (featSize*2+1):(featSize*3);
spectralFlatnessIdxs = (featSize*3+1):(featSize*4);
spectralFluxIdxs = (featSize*4+1):(featSize*5);
spectralRolloffIdxs = (featSize*5+1):(featSize*6);
spectralSpreadIdxs = (featSize*6+1):(featSize*7);
spectralTonalPowerRatioIdxs = (featSize*7+1):(featSize*8);
timeZeroCrossingRateIdxs = (featSize*8+1):(featSize*9);
timeAcfCoeffIdxs = (featSize*9+1):(featSize*10);
timeMaxAcfIdxs = (featSize*10+1):(featSize*11);

featuresSpectralIdxs = [spectralCentroidIdxs, spectralDecreaseIdxs, spectralFluxIdxs, spectralRolloffIdxs, spectralSpreadIdxs];
featuresTonalessIdxs = [spectralCrestFactorIdxs, spectralFlatnessIdxs, spectralTonalPowerRatioIdxs];
featuresTimeIdxs = [timeZeroCrossingRateIdxs, timeAcfCoeffIdxs, timeMaxAcfIdxs];

% average features
featuresMean = zeros(objsCount, 11);
for j = 1 : objsCount
    for i = 0 : (featuresCount-1)
        featuresMean(j, i+1) = mean(data(j, (featSize*i+1):(featSize*(i+1))));
    end
end
console(printExecution, "> mean completed\n");

featuresAvgSpectralIdxs = [1, 3, 5, 6, 7];
featuresAvgTonalessIdxs = [2, 4, 8];
featuresAvgTimeIdxs = [9, 10, 11];


    function str = getStd(st)
        str = "normal";
        if (st == 1)
            str = "std";
        end
    end
    function console(printExecution, varargin)
        if printExecution
            console(printExecution, varargin{:});
        end
    end

% 19 calc * 2: orig and std -> label, error, standardization on/off
results = cell(19*2, 3);

for st = 0:1
    console(printExecution, "\n--- LOONNErr %s ------------------------\n", getStd(st));

    % LOONN all features
    console(printExecution, "> conc feat all (%s): start\n", getStd(st));
    [err] = LOONNErr(data, allFeaturesIdxs, labels, st);
    results(1 + st*19, :) = {"conc feat all", err, st};
    console(printExecution, "> conc feat all (%s): end\n", getStd(st));

    % LOONN spectral features
    console(printExecution, "> conc feat spectral (%s): start\n", getStd(st));
    [err] = LOONNErr(data, featuresSpectralIdxs, labels, st);
    results(2 + st*19, :) = {"conc feat spectral", err, st};
    console(printExecution, "> conc feat spectral (%s): end\n", getStd(st));

    % LOONN tonaless features
    [err] = LOONNErr(data, featuresTonalessIdxs, labels, st);
    results(3 + st*19, :) = {"conc feat tonaless", err, st};
    console(printExecution, "> conc feat tonaless (%s): start\n", getStd(st));
    console(printExecution, "> conc feat tonaless (%s): end\n", getStd(st));

    % LOONN time features
    console(printExecution, "> conc feat time (%s): start\n", getStd(st));
    [err] = LOONNErr(data, featuresTimeIdxs, labels, st);
    results(4 + st*19, :) = {"conc feat time", err, st};
    console(printExecution, "> conc feat time (%s): end\n", getStd(st));

    % LOONN all mean features
    console(printExecution, "> conc avg feat all (%s): start\n", getStd(st));
    [err] = LOONNErr(featuresMean, 1:(featuresCount), labels, st);
    results(5 + st*19, :) = {"conc avg feat all", err, st};
    console(printExecution, "> conc avg feat all (%s): end\n", getStd(st));

    % LOONN mean of spectral features
    console(printExecution, "> conc avg feat spectral (%s): start\n", getStd(st));
    [err] = LOONNErr(featuresMean, featuresAvgSpectralIdxs, labels, st);
    results(6 + st*19, :) = {"conc avg feat spectral", err, st};
    console(printExecution, "> conc avg feat spectral (%s): end\n", getStd(st));

    % LOONN mean of tonaless features
    console(printExecution, "> conc avg feat tonaless (%s): start\n", getStd(st));
    [err] = LOONNErr(featuresMean, featuresAvgTonalessIdxs, labels, st);
    results(7 + st*19, :) = {"conc avg feat tonaless", err, st};
    console(printExecution, "> conc avg feat tonaless (%s): end\n", getStd(st));

    % LOONN mean of time features
    console(printExecution, "> conc avg feat time (%s): start\n", getStd(st));
    [err] = LOONNErr(featuresMean, featuresAvgTimeIdxs,labels, st);
    results(8 + st*19, :) = {"conc avg feat time", err, st};
    console(printExecution, "> conc avg feat time (%s): end\n", getStd(st));

    % LOONN single feature
    console(printExecution, "> conc all single features (%s): start\n", getStd(st));
    for i = 0 : (featuresCount-1)
        features = (featSize*i+1):(featSize*(i+1));
        [err] = LOONNErr(data, features, labels, st);
        featureName = Features.getEnumByIndex(i+1).Name;
        results(9 + i + st*19, :) = {sprintf("feat %s", featureName), err, st};
    end
    console(printExecution, "> conc all single features (%s): end\n", getStd(st));
end

if printResults == 1
    % print result to command window
    for i=1:size(results,1)
        id = results{i,1};
        err = results{i,2};
        st = results{i,3};
        if st == 1
            st = "(std) ";
        else
            st = "";
        end
        id = strcat(st, id);
        fprintf("%2d. LOONNErr %-35s -> %.4f\n", i, id, err);
    end
end

end