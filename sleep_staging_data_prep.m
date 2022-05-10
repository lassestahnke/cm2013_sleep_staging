% Sleep staging using SVM on EEG, EEGsec and EOGL Data
clear all;
close all;
clc; 

%% loading data
edf_files = ["Data/R2.edf","Data/R3.edf","Data/R4.edf","Data/R6.edf","Data/R7.edf", "Data/R8.edf","Data/R9.edf", "Data/R10.edf"];
xml_files = ["Data/R2.xml","Data/R3.xml","Data/R4.xml","Data/R6.xml","Data/R7.xml", "Data/R8.xml","Data/R9.xml","Data/R10.xml"];
%% Extracting features from the dataset
% set modalities 
%modalities = ["EEG","EEGsec","EOGL", "EOGR"];
modalities = ["EEG", "EOGL", "EOGR", "ECG", "EMG", "Sa02", "HR"];
[x_data, y_data] ...
    = extract_features_from_edf(edf_files, xml_files, modalities);
%% Normalising features
x_data = normalize(x_data);
%% Splitting into train and test (and validation) sets
% set relative number of validation and test data
rel_validation = 0.0;
rel_test = 0.0;
% set random seed
rnd_seed = 1337;
% [x_train, y_train, x_validation, y_validation, x_test, y_test] = ...
%     split_train_test_validation(x_data, y_data, rel_validation, rel_test, rnd_seed);

[x_test, y_test] = extract_features_from_edf(["Data/R1.edf", "Data/R5.edf"], ["Data/R1.xml","Data/R5.xml"], modalities);
x_test = normalize(x_test);