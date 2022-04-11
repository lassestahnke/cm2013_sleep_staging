% Sleep staging using CNN on EEG Data
clear all;
close all;
clc; 

% loading training data
edf_files = ["Data/R1.edf", "Data/R2.edf", "Data/R3.edf",...
             "Data/R4.edf", "Data/R5.edf"];
xml_files = ["Data/R1.xml", "Data/R2.xml", "Data/R3.xml",...
             "Data/R4.xml", "Data/R5.xml"];
% set relative number of validation and test data
rel_validation = 0.1;
rel_test = 0;
% set modalities 
modalities = ["EEG", "EEGsec"];
% set random seed
rnd_seed = 1337;
% load data
[x_train, y_train, x_validation, y_validation, x_test, y_test] ...
    = get_dataset_from_edf(edf_files, xml_files, modalities, ...
    rel_validation, rel_test, rnd_seed);


% setting up CNN
fprintf('setting up layers... \n')

filterSize = 32;
numFilters = 16;
numFeatures = length(modalities);
classes = categories(y_train);
numClasses = numel(classes);

layers = [ ...
    sequenceInputLayer(numFeatures)
    convolution1dLayer(filterSize,numFilters,Padding="causal")
    reluLayer
    layerNormalizationLayer

    maxPooling1dLayer(1,'stride', 2)
    convolution1dLayer(filterSize,2*numFilters,Padding="causal")
    reluLayer
    layerNormalizationLayer

    globalAveragePooling1dLayer
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];


% setting options
fprintf('setting options... \n')
options = trainingOptions("adam", ...
    MiniBatchSize=50, ...
    MaxEpochs=100, ...
    SequencePaddingDirection="left", ...
    ValidationData={x_validation,y_validation}, ...
    Plots="training-progress", ...
    Verbose=0);

fprintf('training network... \n')
net = trainNetwork(x_train, y_train, layers, options);

