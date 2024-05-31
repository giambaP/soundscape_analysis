clc; clear all; close all;

a = ones(20, 1) .* 1;
b = ones(20, 1) .* 2;
c = ones(20, 1) .* 3;
d = ones(20, 1) .* 4;
data = vertcat(a,b,c,d);

%% conf
threadsCount = 4;

blockSize = 20; % files per block
subBlockSize = 6; % files per single thread (recommend minimum blockSize / threadsCount )

totalCount = size(data, 1);

%% optimize conf

if subBlockSize < ceil(blockSize / threadsCount)
    warning("sub block size value (%d) is minor than division betweem block size and threads count (%d/%d=%d): overriden", subBlockSize, blockSize, threadsCount, round(blockSize/threadsCount));
    subBlockSize = ceil(blockSize / threadsCount);
end

blockSize = min(blockSize, totalCount);
blockCount = max(ceil(totalCount/blockSize), 1);

subBlockSize = min(subBlockSize, blockSize);
subBlockCount = min(ceil(blockSize/subBlockSize), threadsCount);

%% functions

function [startIdx, endIdx] = calcRange(rangeId, rangeSize, totalSize)
startIdx = 1 + (rangeId * rangeSize);
endIdx = min((rangeId+1) * rangeSize, totalSize);
end

%% EXECUTION

fprintf("# totalSize %d\n", totalCount);
fprintf("# blockSize %d (totalBlocks %d)\n", blockSize, blockCount);
fprintf("# subBlockSize %d (totalSubBlocks %d) \n", subBlockSize, subBlockCount);
for b = 0:(blockCount-1)
    [startBlockIdx, endBlockIdx] = calcRange(b, blockSize, totalCount);
    fprintf("\n> %2d. BLOCK %2d -> %2d\n", b, startBlockIdx, endBlockIdx);
    % partData = data(startBlockIdx:endBlockIdx, 1);
    % disp(partData);

    subBlockData = data(startBlockIdx:endBlockIdx, 1);
    totalSubBlockCount = size(subBlockData, 1);
     for t = 0:(subBlockCount-1)
        [subStartIdx, subEndIdx] = calcRange(t, subBlockSize, totalSubBlockCount);
        startIdx = startBlockIdx + subStartIdx - 1;
        endIdx = startBlockIdx + subEndIdx - 1;
        
        if startIdx <= endIdx
            fprintf("  %2d. sub   %2d -> %2d\n", t, startIdx, endIdx);
        end
    end
end