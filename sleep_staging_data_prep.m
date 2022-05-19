% Data preparation for sleep staging using machine learning algorithms.
clear all;
close all;
clc; 

%% Loading data
edf_files_train = ["Data/R2.edf","Data/R3.edf","Data/R4.edf","Data/R6.edf","Data/R7.edf", "Data/R8.edf","Data/R9.edf", "Data/R10.edf"];
xml_files_train = ["Data/R2.xml","Data/R3.xml","Data/R4.xml","Data/R6.xml","Data/R7.xml", "Data/R8.xml","Data/R9.xml","Data/R10.xml"];

%% Extracting features from the dataset
% Setting modalities 
modalities = ["EEG", "EEGsec", "EOGL", "EOGR", "EMG"];
% Extracting features
[x_train, y_train] ...
    = extract_features_from_edf(edf_files_train, xml_files_train, modalities);
[x_test, y_test] = extract_features_from_edf(["Data/R1.edf", ...
    "Data/R5.edf"], ["Data/R1.xml","Data/R5.xml"], modalities);

%% Normalising features
x_train = normalize(x_train);
x_test = normalize(x_test);

%% Randomize order of features within their set
rand_perm_train = randperm(size(x_train,1));
rand_perm_test = randperm(size(x_test,1));

x_train = x_train(rand_perm_train,:);
y_train = y_train(rand_perm_train,:);

x_test = x_test (rand_perm_test ,:);
y_test  = y_test (rand_perm_test ,:);

%% Train model
% FCNN
[model, accuracy] = trainFCNN(x_train, y_train);
% SVM
%[model, accuracy] = trainSVM(x_train, y_train);
disp("Accuracy of the model on train/validation data is " + accuracy*100 + "%")

%% Prediction
fit = model.predictFcn(x_test);
% Plot model confusion matrix
fig = figure;
cm = confusionchart(y_test, fit, 'Normalization', 'total-normalized', 'RowSummary', 'row-normalized', 'ColumnSummary', 'column-normalized');
cm.Normalization = 'absolute';