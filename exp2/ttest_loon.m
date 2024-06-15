clc; clear all; close all;

%% CONFIGURATION

resultExp2DirPath = "./result_classification_exp2";
resultExp2For0xsecFileName = "result_classification_exp2_fs0Xsec.csv";
resultExp2For1secFileName = "result_classification_exp2_fs1sec.csv";
resultTTest = "ttest.txt";


%% EXECUTION

% loading csv results (first row is header)
result0xsec = readmatrix(sprintf("%s/%s", resultExp2DirPath, resultExp2For0xsecFileName));
result1sec = readmatrix(sprintf("%s/%s", resultExp2DirPath, resultExp2For1secFileName));

result0xsecData = result0xsec(2:end,:);
result1secData = result1sec(2:end,:);

[h,p,ci,stats] = ttest(result0xsecData(:), result1secData(:));

resultFormatted = [ ...
    sprintf('> T-TEST \n') ...
    sprintf('%12s: %d\n', 'h', h) ...
    sprintf('%12s: %0.30f\n', 'p', p) ...
    sprintf('%12s: %0.5f\n', 'ci', ci(1, :)) ...
    sprintf('%12s: %0.5f\n', ' ', ci(2, :)) ...
    sprintf('%12s: %0.5f\n', 'stats.tstat', stats.tstat) ...
    sprintf('%12s: %d\n', 'stats.df', stats.df) ...
    sprintf('%12s: %0.5f\n', 'stats.sd', stats.sd)
];

% on command window
disp(resultFormatted);
% on file
resultFilePath = sprintf("%s/%s", resultExp2DirPath, resultTTest);
resultFileId = fopen(resultFilePath, 'w');
fprintf(resultFileId, resultFormatted);
fclose(resultFileId);

% IPOTESI NULLA RIFIUTATA, DIFFERENZE SIGNIFICATIVE TRA I GRUPPI
% DIFFERENZE STATISTICAMENTE SIGNIFICATIVE


