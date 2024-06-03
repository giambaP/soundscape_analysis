clc; clear all; close all;

%% LOONN all features, no filters

matrixDataName = "matrixAllFeatures.mat";
matrixLabelsName = "labelsYAT.mat";

load(sprintf("./templates/%s", matrixDataName));
fprintf("loaded audio data from '%s'\n", matrixDataName);
load(sprintf("./templates/%s", matrixLabelsName));
fprintf("loaded labels data from '%s'\n", matrixLabelsName);

featuresCount = 11;
elementsPerFeature = 176;
labels = labelsYAT(1:size(data, 1),1);

execLOONN(featuresCount, elementsPerFeature, data, labels, 1);
fprintf("> LOONN end\n");