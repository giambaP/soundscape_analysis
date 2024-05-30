%compute the Leave One Out error

%@param data: matrix of data
%@param features: feature considerated
%@param labels: labels of the data
%@param st: if 1 z-score standardization, else nothing

%@retval err: LOO error
% ======================================================================
function [err] = LOONNErr(data, features, labels, st)
n = size(data,1);

if (st == 1)
    % STANDARDIZATION
    % remove col with identical values
    xdata = data(:,features);
    a = std(xdata);
    keep = a > 0;
    xdata = xdata(:,keep);
    % z-score standardization
    newData = zscore(xdata);

    dist = squareform(pdist(newData)); % compute pairwise distance
    dist = dist+eye(size(newData,1)).*max(dist(:));
else
    dist = squareform(pdist(data(:,features))); % compute pairwise distance
    dist = dist+eye(size(data,1)).*max(dist(:));

end
[~,idx] = min(dist,[],2);
assignedLabels = labels(idx);
err = sum(labels~=assignedLabels);
err = err/n;

end