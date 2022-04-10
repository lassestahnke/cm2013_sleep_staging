% Sleep staging using CNN on EEG Data
clear all;
close all;
clc; 
% loading data
edfFilename = 'Data/R4.edf';
xmlFilename = 'Data/R4.xml';
[hdr, record] = edfread(edfFilename);
[events, stages, epochLength,annotation] = readXML(xmlFilename);

% find EEG recordings
Fs = hdr.samples(8);  % samples per second
EEG_rec = record(8,1:end-Fs*30);
EEG_rec = filter_EEG(EEG_rec, "wavelet_filter", Fs);
num_epochs = floor(length(EEG_rec)/epochLength/Fs);
% get eeg data per epoch 
EEG_rec_per_epoch = reshape(EEG_rec, epochLength*Fs, num_epochs).';

% annotations ikn file are given per second, we need epoch wise annotations
% --> prepating labels for training -> labels per epochs
num_classes = 5;
stage_per_epoch = reshape(stages, 30, num_epochs);
stage_per_epoch = stage_per_epoch(1,:).';
stage_per_epoch(stage_per_epoch==1) = 2;

% divide data into train and test:
fprintf('setting up train and test data ... \n')
rel_test = 0;
rng(1337); % set random seed
idx_train = randperm(num_epochs, floor(num_epochs*(1-rel_test)));
idx_test = setdiff([1:1:num_epochs], idx_train);

x_train = EEG_rec_per_epoch(idx_train,:);
x_test = EEG_rec_per_epoch(idx_test,:);

y_train = categorical(stage_per_epoch(idx_train));
y_test = categorical(stage_per_epoch(idx_test));

% converting data to cell arrays
x_train = mat2cell(x_train, ones(length(idx_train),1));
x_test = mat2cell(x_test, ones(length(idx_test),1));

numFeatures = size(x_train{1},1);
numClasses = numel(categories(y_train));

%%%%% load more test data %%%%%%
% loading data
edfFilename = 'Data/R3.edf';
xmlFilename = 'Data/R3.xml';
[hdr, record] = edfread(edfFilename);
[events, stages, epochLength,annotation] = readXML(xmlFilename);

% find EEG recordings
Fs = hdr.samples(8);  % samples per second
EEG_rec = record(8,1:end-Fs*30);
EEG_rec = filter_EEG(EEG_rec, "wavelet_filter", Fs);
num_epochs = floor(length(EEG_rec)/epochLength/Fs);
% get eeg data per epoch 
EEG_rec_per_epoch = reshape(EEG_rec, epochLength*Fs, num_epochs).';

% annotations ikn file are given per second, we need epoch wise annotations
% --> prepating labels for training -> labels per epochs
num_classes = 5;
stage_per_epoch = reshape(stages, 30, num_epochs);
stage_per_epoch = stage_per_epoch(1,:).';
stage_per_epoch(stage_per_epoch==1) = 2;

x_test = EEG_rec_per_epoch;
y_test = categorical(stage_per_epoch);

x_test = mat2cell(x_test, ones(length(x_test(:,1)),1));

% setting up CNN
fprintf('setting up layers... \n')

filterSize = 32;
numFilters = 16;

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
    MaxEpochs=400, ...
    SequencePaddingDirection="left", ...
    ValidationData={x_test,y_test}, ...
    Plots="training-progress", ...
    Verbose=0);

fprintf('training network... \n')
net = trainNetwork(x_train, y_train, layers, options);

