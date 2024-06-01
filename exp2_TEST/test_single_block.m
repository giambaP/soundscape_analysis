clc; clear all; close all;

%% conf
threadsCount = 4;

blockSize = 6; % files per block

%% functions

function [startIdx, endIdx] = calcRange(rangeId, rangeSize, totalSize)

end

%% defining data

a = ones(blockSize+1, 1) .* 1;
b = ones(blockSize+1, 1) .* 2;
c = ones(blockSize+1, 1) .* 3;
d = ones(blockSize+1, 1) .* 4;
data = vertcat(a,b,c,d);

%% execution

totalCount = size(data, 1);

blockSize = min(blockSize, totalCount);
blockCount = max(ceil(totalCount/blockSize), 1);

fprintf("# totalSize %d\n", totalCount);
fprintf("# blockSize %d (totalBlocks %d)\n", blockSize, blockCount);

delete(gcp('nocreate'));
% setup parallel threads count
parpool("Processes", threadsCount);

tic;
% blocco di file da poter salvare su disco contemporaneamente
for b = 0:(blockCount-1)
    startIdx = 1 + (b * blockSize);
    endIdx = min((b+1) * blockSize, totalCount);

    % sotto blocco di file da salvare parallelizzabile per thread
    parfor s = startIdx:endIdx
        fprintf("PF1 %2d. BLOCK index %d\n", b, s);
    end

    % secondo sotto blocco di file da salvare parallelizzabile per thread
    parfor s = startIdx:endIdx
        fprintf("PF2 %2d. BLOCK index %d\n", b, s);
    end

    fprintf("END OF BLOCK %d \n", b);
end

disp("");
toc;