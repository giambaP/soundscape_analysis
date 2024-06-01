clc; clear all; close all;

% general

disney{1} = "Pippo";
disney{2} = "Topolino";
disney{3} = "Minni";

disneyPippo = ones(9000, 176) * 1;
disneyTopolino = ones(9000, 176) * 1;
disneyMinni = ones(9000, 176) * 1;

dirTest = "TEST";
mkdir(dirTest);

% for i = 1:numel(disney)
%     disneyName = disney{i};
%     matrixName = sprintf("disney%s", disneyName);
%     featureSet = eval(matrixName);
%     save(sprintf("%s/%s.mat", dirTest, matrixName), "-fromstruct", struct("featureSet", featureSet));
% end

load("TEST/disneyPippo.mat");