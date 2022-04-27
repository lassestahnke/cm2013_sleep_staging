% Sleep staging using SVM on EEG, EEGsec and EOGL Data
clear all;
close all;
clc; 

% loading training data
edf_files = ["Data/R1.edf","Data/R2.edf","Data/R3.edf","Data/R4.edf"];
xml_files = ["Data/R1.xml","Data/R2.xml","Data/R3.xml","Data/R4.xml"];
% edf_files = ["Data/R1.edf"];
% xml_files = ["Data/R1.xml"];
% set relative number of validation and test data
rel_validation = 0.0;
rel_test = 0.1;
% set modalities 
modalities = ["EEG","EEGsec","EOGL"];
%modalities = ["EEG"];
% set random seed
rnd_seed = 1337;
% load data
%%
[x_data, y_data] ...
    = extract_features_from_edf(edf_files, xml_files, modalities);
disp(x_data);
%%
x_data = normalize(x_data);
disp(x_data);
%%
[x_train, y_train, x_validation, y_validation, x_test, y_test] = ...
    split_train_test_validation(x_data, y_data, rel_validation, rel_test, rnd_seed);