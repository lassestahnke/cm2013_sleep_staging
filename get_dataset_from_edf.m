% function to get train, test and Validation data from EDF file in correct
% format for DL 
function [x_train, y_train, x_validation, y_validation, x_test, y_test] ...
    = get_dataset_from_edf(edf_files, xml_files, modalities, ...
    rel_validation, rel_test, rnd_seed)

%{
    Arguments: 
            efd_files: [array] paths to .edf files
            xml_files: [array] paths to .xml files for annotations
            modalities:[array] modalities that should be included in
                        dataset ('EEG', "EEGsec","EOGL", "EOGR", 'ECG', 
                                 'EMG')
            rel_validation: [float] percentage of validation data 0...1
            rel_test:       [float] percentage of test data 0...1
            seed:           [int] random seed for data splitting
    
    Output:
            x_train: [cell array] n*c*d training data 
                        (n different cases with c features and d samples)
            y_train: [cell array] n*1 training labels (categorical)
            x_validation: [cell array] n*c*d validation data 
                        (n different cases with c features and d samples)
            y_validation [cell array] n*1 training labels (categorical)
            x_test: [cell array] n*c*d test data 
                        (n different cases with c features and d samples)
            y_test: [cell array] n*1 test labels (categorical)
%}

    % checking input format:
    num_edf_files = size(edf_files,2);
    num_xml_files = size(xml_files,2);
    if num_edf_files ~= num_xml_files
        error('Number of .edf files and .xml files does not match!')
    end
    
    if rel_validation > 1 || rel_validation < 0
        error('Please enter rel_validation between 0 and 1!')
    end

    if rel_test > 1 || rel_test < 0
        error('Please enter rel_test between 0 and 1!')
    end
    
    % set temporaty variables
    x_data = [];
    y_data = [];

    num_features = size(modalities,2);

    for i=1:1:num_edf_files
        x_tmp = [];
        y_tmp = [];

        edf_filename_tmp = edf_files(i);
        xml_filename_tmp = xml_files(i);

        % load files
        [hdr, record] = edfread(edf_filename_tmp);
        [events, stages, epochLength, annotation] ...
            = readXML(xml_filename_tmp);
        
        % transforming labels and change label 1 to 2
        num_epochs = size(stages,2)/epochLength;
        stage_per_epoch = reshape(stages, epochLength, num_epochs);
        stage_per_epoch = stage_per_epoch(1,:).';
        stage_per_epoch(stage_per_epoch==1) = 2;

        y_data = [y_data; stage_per_epoch];
        
        % transforming actual data
        for j=1:1:num_features
            % Get EEG data
            if ismember('EEG', modalities)
                Fs = hdr.samples(8);  % samples per second
                EEG_rec = record(8,1:end-Fs*epochLength);
                EEG_rec = filter_EEG(EEG_rec, "wavelet_filter", Fs);
                % get eeg data per epoch 
                EEG_rec_per_epoch = reshape(EEG_rec, epochLength*Fs, ...
                                            num_epochs).';
                
                x_tmp = cat(3, x_tmp, EEG_rec_per_epoch);
            end  
            
            % Get EEGsec data
            if ismember('EEGsec', modalities)
                Fs = hdr.samples(3);  % samples per second
                EEG_rec = record(3,1:end-Fs*epochLength);
                EEG_rec = filter_EEG(EEG_rec, "wavelet_filter", Fs);
                % get eeg data per epoch 
                EEG_rec_per_epoch = reshape(EEG_rec, epochLength*Fs, ...
                                            num_epochs).';
                
                x_tmp = cat(3, x_tmp, EEG_rec_per_epoch);
            end  
            
            %Get EOGL data
            if ismember('EOGL', modalities)
                Fs = hdr.samples(6);  % samples per second
                EOG_rec = record(6,1:num_epochs*Fs*epochLength); 

                % get eog data per epoch 
                EOG_rec_per_epoch = reshape(EOG_rec, epochLength*Fs,...
                                            num_epochs).';
                % add zero padding per epoch
                EOG_rec_per_epoch = cat(2, EOG_rec_per_epoch, ...
                                 zeros(num_epochs, size(x_tmp,2)- ...
                                 size(EOG_rec_per_epoch,2)));

                x_tmp = cat(3, x_tmp, EOG_rec_per_epoch);
            end
            
            %Get EOGR data
            if ismember('EOGR', modalities)
                Fs = hdr.samples(7);  % samples per second
                EOG_rec = record(7,1:num_epochs*Fs*epochLength); 

                % get eog data per epoch 
                EOG_rec_per_epoch = reshape(EOG_rec, epochLength*Fs,...
                                            num_epochs).';
                % add zero padding per epoch
                EOG_rec_per_epoch = cat(2, EOG_rec_per_epoch, ...
                                 zeros(num_epochs, size(x_tmp,2)- ...
                                 size(EOG_rec_per_epoch,2)));

                x_tmp = cat(3, x_tmp, EOG_rec_per_epoch);
            end

            %Get ECG data
            if ismember('ECG', modalities)
                Fs = hdr.samples(4);  % samples per second
                ECG_rec = record(4,1:num_epochs*Fs*epochLength); 

                % get eog data per epoch 
                ECG_rec_per_epoch = reshape(ECG_rec, epochLength*Fs,...
                                            num_epochs).';
                % add zero padding per epoch
                ECG_rec_per_epoch = cat(2, ECG_rec_per_epoch, ...
                                 zeros(num_epochs, size(x_tmp,2)- ...
                                 size(ECG_rec_per_epoch,2)));

                x_tmp = cat(3, x_tmp, ECG_rec_per_epoch);
            end 
            
            %Get EMG data
            if ismember('EMG', modalities)
                Fs = hdr.samples(5);  % samples per second
                EMG_rec = record(5,1:num_epochs*Fs*epochLength); 

                % get eog data per epoch 
                EMG_rec_per_epoch = reshape(EMG_rec, epochLength*Fs,...
                                            num_epochs).';
                % add zero padding per epoch
                EMG_rec_per_epoch = cat(2, EMG_rec_per_epoch, ...
                                 zeros(num_epochs, size(x_tmp,2)- ...
                                 size(EMG_rec_per_epoch,2)));

                x_tmp = cat(3, x_tmp, EMG_rec_per_epoch);
            end
        end
        
        for k=1:1:size(x_tmp,1)
            arr_tmp = [];
            for l=1:1:num_features
                arr_tmp = [arr_tmp; x_tmp(k,:,l)];
            end
            cell_tmp = mat2cell(arr_tmp, num_features, size(x_tmp,2));
            x_data = [x_data; cell_tmp];
        end 

    end 
    y_data = categorical(y_data);

    % split dataset into train, validation and test
    rng(rnd_seed); % set random seed
    num_samples = size(x_data,1);

    idx_all = randperm(num_samples);
    idx_train = idx_all(1:round(num_samples*(1-rel_test-rel_validation)));
    idx_validation = idx_all(round(num_samples* ...
                             (1-rel_test-rel_validation)) ...
                              +1:round(num_samples*(1-rel_test)));
    idx_test = idx_all(round(num_samples*(1-rel_test))+1:end);
    
    x_train = x_data(idx_train);
    y_train = y_data(idx_train);

    x_validation = x_data(idx_validation);
    y_validation = y_data(idx_validation);

    x_test = x_data(idx_test);
    y_test = y_data(idx_test);

    % todo: add support for more modalities (caution with zero padding)
