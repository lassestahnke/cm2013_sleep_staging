% Attempt at having a similar version of Lasse's file for the feature
% extraction

% function to get train, test and Validation data from EDF file in correct
% format for DL 
function [x_data, y_data] ...
    = extract_features_from_edf(edf_files, xml_files, modalities)

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
%        for j=1:1:num_features
            % Get EEG data
            if ismember('EEG', modalities)
                Fs = hdr.samples(8);  % samples per second
                EEG_rec = record(8,1:end-Fs*epochLength);
                EEG_rec = filter_EEG(EEG_rec, "wavelet_filter", Fs);
                temporal_features = extract_temp_features(EEG_rec, epochLength, Fs);
                freq_features = extract_freq_features(EEG_rec, epochLength, Fs);
                hjort_features = extract_hjort_parameters(EEG_rec, epochLength, Fs);
                % get eeg data per epoch 
                %EEG_rec_per_epoch = reshape(EEG_rec, epochLength*Fs, ...
                %                            num_epochs).';
                
                %x_tmp = cat(3, x_tmp, EEG_rec_per_epoch);
                EEG_data = [temporal_features', freq_features', hjort_features'];
                x_tmp = cat(2,x_tmp, EEG_data);
            end  
            
            % Get EEGsec data
            if ismember('EEGsec', modalities)
                Fs = hdr.samples(3);  % samples per second
                EEGsec_rec = record(3,1:end-Fs*epochLength);
                EEGsec_rec = filter_EEG(EEGsec_rec, "wavelet_filter", Fs);

                temporal_features = extract_temp_features(EEGsec_rec, epochLength, Fs);
                freq_features = extract_freq_features(EEGsec_rec, epochLength, Fs);
                hjort_features = extract_hjort_parameters(EEGsec_rec, epochLength, Fs);
                % get eeg data per epoch 
                %EEG_rec_per_epoch = reshape(EEG_rec, epochLength*Fs, ...
                %                            num_epochs).';
                
                %x_tmp = cat(3, x_tmp, EEG_rec_per_epoch);
                EEGsec_data = [temporal_features', freq_features', hjort_features'];
                x_tmp = cat(2,x_tmp, EEGsec_data);


                % get eeg data per epoch 
                % all features
            end  
            
            %Get EOGL data
            if ismember('EOGL', modalities)
                Fs = hdr.samples(6);  % samples per second
                EOGL_rec = record(6,1:num_epochs*Fs*epochLength); 
                % TODO: Add pre-processing
                temporal_features = extract_temp_features(EOGL_rec, epochLength, Fs);
                
                EOGL_data = [temporal_features'];
                x_tmp = cat(2,x_tmp, EOGL_data);

                % get eog data per epoch 
                % Temporal features
            end
            
            %Get EOGR data
            if ismember('EOGR', modalities)
                Fs = hdr.samples(7);  % samples per second
                EOGR_rec = record(7,1:num_epochs*Fs*epochLength); 
                % TODO: Add pre-processing
                temporal_features = extract_temp_features(EOGR_rec, epochLength, Fs);

                EOGR_data = [temporal_features'];
                x_tmp = cat(2,x_tmp, EOGR_data);


                % get eog data per epoch 
                % Temporal features
            end

            %Get ECG data
            if ismember('ECG', modalities)
                Fs = hdr.samples(4);  % samples per second
                ECG_rec = record(4,1:num_epochs*Fs*epochLength); 
                % TODO: Add pre-processing
                temporal_features = extract_temp_features(EEG_rec, epochLength, Fs);
                EEG_data = [temporal_features'];
                x_tmp = cat(2,x_tmp, EEG_data);
            end 
            
            %Get EMG data
            if ismember('EMG', modalities)
                Fs = hdr.samples(5);  % samples per second
                EMG_rec = record(5,1:num_epochs*Fs*epochLength); 
                % TODO: Add pre-processing
                temporal_features = extract_temp_features(EMG_rec, epochLength, Fs);
                EMG_data = [temporal_features'];
                x_tmp = cat(2,x_tmp, EMG_data);
            end

            %Get Sa02 data
            if ismember('Sa02', modalities)
                Fs = hdr.samples(1);  % samples per second
                Sa02_rec = record(1,1:num_epochs*Fs*epochLength); 
                % TODO: Add pre-processing
                temporal_features = extract_temp_features(Sa02_rec, epochLength, Fs);
                Sa02_data = [temporal_features'];
                x_tmp = cat(2,x_tmp, Sa02_data);
            end

            %Get HR data
            if ismember('HR', modalities)
                Fs = hdr.samples(2);  % samples per second
                HR_rec = record(2,1:num_epochs*Fs*epochLength); 
                % TODO: Add pre-processing
                temporal_features = extract_temp_features(HR_rec, epochLength, Fs);
                HR_data = [temporal_features'];
                x_tmp = cat(2,x_tmp, HR_data);
            end
%        end
 
 
    x_data = [x_data;x_tmp];
    end 
    y_data = categorical(y_data);

end
    