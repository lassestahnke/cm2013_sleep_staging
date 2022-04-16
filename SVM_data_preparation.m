%edf_files = 'Data/R4.edf';
%xml_files = 'Data/R4.xml';

edfFilename = 'Data/R4.edf';
xmlFilename = 'Data/R4.xml';

% % checking input format:
% num_edf_files = size(edf_files,2);
% num_xml_files = size(xml_files,2);
% if num_edf_files ~= num_xml_files
%     error('Number of .edf files and .xml files does not match!')
% end

%loading data 
[hdr, record] = edfread(edfFilename,'targetSignals','EEG');
[events, stages, epochLength,annotation] = readXML(xmlFilename);
numberOfEpochs = length(stages)/(epochLength);
Fs = hdr.samples;

%wavelet filtering of EEG
record = filter_EEG(record,'wavelet_filter',Fs);

%dividing signal into epochs array(epochNumber,epochRecords)
signal_per_epoch = [];
for epochNumber = 1:numberOfEpochs
    epochStart = (epochNumber-1)*Fs*epochLength+1;
    epochEnd = (epochStart-1) + epochLength*Fs;
    signal_per_epoch(epochNumber,:) = record(1,epochStart:epochEnd);
end

signal = reshape(signal_per_epoch',1,[]);

    %fixing signal so it matches numberOfEpochs*epochLength*Fs
    %signal = record(:, 1:(numberOfEpochs*epochLength*hdr.samples));

%fixing stages (merging stage N4 and N3)
stages(stages==1) = 2;

%one sleep stage per epoch
stage_per_epoch = reshape(stages, epochLength, numberOfEpochs);
stage_per_epoch = stage_per_epoch(1,:).';

%calculate features
[energies] = extract_freq_features(signal, epochLength, Fs);
% % old hjort and temporal feature functions, uncomment to test
% %[mobility, complexity] = extract_hjort_parameters(signal, epochLength, Fs);
% %[mean_signal, variance, amplitude, skewness_signal, kurtosis_signal] = extract_temp_features(signal, epochLength, Fs);
% %features = [mobility; complexity; skewness_signal; kurtosis_signal; energies]';
