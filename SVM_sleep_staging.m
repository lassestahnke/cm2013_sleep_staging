% Sleep staging using SVM on EEG, EEGsec and EOGL Data
clear all;
close all;
clc; 

% loading training data
edf_files = ["Data/R1.edf","Data/R4.edf"];
xml_files = ["Data/R1.xml","Data/R4.xml"];
% set relative number of validation and test data
rel_validation = 0.3;
rel_test = 0.2;
% set modalities 
modalities = ["EEG","EEGsec","EOGL"];
% set random seed
rnd_seed = 1337;
% load data
[x_train, y_train, x_validation, y_validation, x_test, y_test] ...
    = extract_features_from_edf(edf_files, xml_files, modalities, ...
    rel_validation, rel_test, rnd_seed);
%%