%compute the Leave One Out error

%@param data: matrix of data
%@param features: feature considerated
%@param labels: labels of the data
%@param st: if 1 z-score standardization, else nothing

%@retval err: LOO error
% ======================================================================
% function [err] = LOONNErr(data, features, labels, st)
% n = size(data,1);
% 
% if (st == 1)
%     % STANDARDIZATION
%     % remove col with identical values
%     xdata = data(:,features);
%     a = std(xdata);
%     keep = a > 0;
%     xdata = xdata(:,keep);
%     % z-score standardization
%     newData = zscore(xdata);
% 
%     dist = squareform(pdist(newData)); % compute pairwise distance
%     dist = dist+eye(size(newData,1)).*max(dist(:));
% else
%     % pdist create matrix distance between every point inside data
%     % squareform trasform it to a square matrix
%     dist = squareform(pdist(data(:,features))); 
%     % increase distance between points 
%     dist = dist+eye(size(data,1)).*max(dist(:));
% 
% end
% [~,idx] = min(dist,[],2);
% assignedLabels = labels(idx);
% err = sum(labels~=assignedLabels);
% err = err/n;
% 
% end

function [err] = LOONNErr(data, features, labels, st)
    k = 10; % numero di fold
    n = size(data, 1);
    indices = crossvalind('Kfold', labels, k); % crea gli indici per i fold
    err = 0; % inizializza il contatore degli errori

    for i = 1:k
        % Indici per il set di test e il set di addestramento
        testIdx = (indices == i);
        trainIdx = ~testIdx;

        % Dataset di addestramento e di test
        trainData = data(trainIdx, :);
        trainLabels = labels(trainIdx);
        testData = data(testIdx, :);
        testLabels = labels(testIdx);

        % Seleziona le caratteristiche
        xTrain = trainData(:, features);
        xTest = testData(:, features);

        % Standardizza se necessario
        if st == 1
            % Rimuovi colonne con valori identici
            a = std(xTrain);
            keep = a > 0;
            xTrain = xTrain(:, keep);
            xTest = xTest(:, keep);

            % Standardizzazione Z-score
            mu = mean(xTrain);
            sigma = std(xTrain);
            xTrain = (xTrain - mu) ./ sigma;
            xTest = (xTest - mu) ./ sigma;
        end

        % Calcola le distanze e classifica ciascun punto nel set di test
        for j = 1:size(xTest, 1)
            dists = sqrt(sum((xTrain - xTest(j, :)).^2, 2));
            [~, idx] = min(dists);
            assignedLabel = trainLabels(idx);
            if assignedLabel ~= testLabels(j)
                err = err + 1;
            end
        end
    end

    % Calcola l'errore normalizzato
    err = err / n;
end