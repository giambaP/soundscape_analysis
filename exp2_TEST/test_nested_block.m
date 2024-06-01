clc; clear all; close all;

%% conf
threadsCount = 4;

blockSize = 500; % files per block
subBlockSize = 100; % files per single thread (recommend minimum blockSize / threadsCount )

%% functions

function [startIdx, endIdx] = calcRange(rangeId, rangeSize, totalSize)
startIdx = 1 + (rangeId * rangeSize);
endIdx = min((rangeId+1) * rangeSize, totalSize);
end

%% defining data

a = ones(1000, 1) .* 1;
b = ones(1000, 1) .* 2;
c = ones(1000, 1) .* 3;
d = ones(1000, 1) .* 4;
data = vertcat(a,b,c,d);

%% execution

totalCount = size(data, 1);

blockSize = min(blockSize, totalCount);
blockCount = max(ceil(totalCount/blockSize), 1);

subBlockSize = min(subBlockSize, blockSize);
subBlockCount = min(ceil(blockSize/subBlockSize), threadsCount);

fprintf("# totalSize %d\n", totalCount);
fprintf("# blockSize %d (totalBlocks %d)\n", blockSize, blockCount);
fprintf("# subBlockSize %d (totalSubBlocks %d) \n", subBlockSize, subBlockCount);

delete(gcp('nocreate'));

tic;
% blocco di file da poter salvare su disco contemporaneamente
for b = 0:(blockCount-1)
    [startBlockIdx, endBlockIdx] = calcRange(b, blockSize, totalCount);

    totalSubBlockCount = endBlockIdx - startBlockIdx + 1;

    % sotto blocco di file da salvare parallelizzabile per thread
    parfor t = 0:(subBlockCount-1)
        [subStartIdx, subEndIdx] = calcRange(t, subBlockSize, totalSubBlockCount);
        startIdx = startBlockIdx + subStartIdx - 1;
        endIdx = startBlockIdx + subEndIdx - 1;

        if startIdx <= endIdx
            fprintf("PF1 %2d. BLOCK %2d-%2d | %2d. sub   %2d -> %2d\n", b, startBlockIdx, endBlockIdx, t, startIdx, endIdx);
            
            % some code
        end
    end

    parfor t = 0:(subBlockCount-1)
        [subStartIdx, subEndIdx] = calcRange(t, subBlockSize, totalSubBlockCount);
        startIdx = startBlockIdx + subStartIdx - 1;
        endIdx = startBlockIdx + subEndIdx - 1;

        if startIdx <= endIdx
            fprintf("PF2 %2d. BLOCK %2d-%2d | %2d. sub   %2d -> %2d\n", b, startBlockIdx, endBlockIdx, t, startIdx, endIdx);

            % some code
        end
    end

    fprintf("END OF BLOCK %d \n", b);
end
toc;