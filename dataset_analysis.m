 %analysing ECG Signal
clc;
close all;
clear all;
 
% load edf and xml files
edfFilename = 'Data/R4.edf';
xmlFilename = 'Data/R4.xml';
[hdr, record] = edfread(edfFilename);
[events, stages, epochLength,annotation] = readXML(xmlFilename);


labels = hdr.label()
% get number of samples for each record
num_samples_non_zero = zeros(length(labels),1);
for i=1:14
    num_samples_non_zero(i) = nnz(record(i,:));
end
display(num_samples_non_zero)

%calculate sampling rate
sample_frequencies = num_samples_non_zero/(length(stages)); % in Hz
display(sample_frequencies)

numberOfEpochs = length(record(3,:)')/(30*hdr.samples(3))

%% plot 1 30 sec epoch of each signal
figure(1);
% specify signal to plot:
figure()
i = 8 % plot EEG
Fs = hdr.samples(i);
(length(record(i,:)')/Fs);
epochNumber = 1; % plot nth epoch of 30 seconds
epochStart = (epochNumber-1)*Fs*30+1;
epochEnd = (epochStart-1) + 600*Fs;
%signal = record(i,epochStart:epochEnd);
signal = record(i,epochStart:end);
plot((1:length(signal))/Fs,signal);
ylabel(hdr.label(i));
xlim([1 100]);
subtitle(['30 seconds epoch #' num2str(epochNumber)]);
set(gcf,'color','w');
% 
% % looking at periodogram of singal (rectangual window)
% figure();
% [pxx,w] = periodogram(signal,hamming(length(signal)),length(signal),Fs);
% plot(w,10*log10(pxx))
% 
% % filter frequency over 30 hz
% fc = 15; % Hz
% [b,a] = butter(16,fc/(Fs/2));
% filt_signal = filter(b,a,signal);
% figure()
% plot((1:length(filt_signal))/Fs,filt_signal);
% ylabel(hdr.label(i));
% xlim([150 160]);
% subtitle(['30 seconds epoch #' num2str(epochNumber)]);
% set(gcf,'color','w');
% 
% figure()
% [pxx_filt,w_filt] = periodogram(filt_signal,hamming(length(filt_signal)),length(filt_signal),Fs);
% plot(w_filt,10*log10(pxx_filt))
% 
% using Wavelet Decomposition to denoise our signal using 8 levels
waveletFunction = 'db8';
%sig_crop = signal(125*140:125*170);
[C,L] = wavedec(signal,5,waveletFunction);

cD1 = detcoef(C,L,1); % 62.5 - 125 Hz
cD2 = detcoef(C,L,2); % Gamma; 32.25 - 62.5 Hz
cD3 = detcoef(C,L,3); % Beta; 16.125 - 32.25 Hz
cD4 = detcoef(C,L,4); % Alpha; 8.06 - 16.13 Hz
cD5 = detcoef(C,L,5); % Theta; 4.03 - 8.06 Hz
cA5 = appcoef(C,L,waveletFunction,5); % Delta; 0 -4.03 Hz
D1 = wrcoef('d',C,L,waveletFunction,1); % 
D2 = wrcoef('d',C,L,waveletFunction,2); % Gamma
D3 = wrcoef('d',C,L,waveletFunction,3); % Beta
D4 = wrcoef('d',C,L,waveletFunction,4); % Alpha
D5 = wrcoef('d',C,L,waveletFunction,5); % Theta
A5 = wrcoef('a',C,L,waveletFunction,5); % Delta

% plotting Wavelet decompositions
x_min = 5200;
x_max = 5800;
figure()
subplot(4,1,1)
plot(1/Fs:1/Fs:length(D3)/Fs, D3)
xlim([x_min x_max]);

subplot(4,1,2)
plot(1/Fs:1/Fs:length(D4)/Fs, D4)
xlim([x_min x_max]);

subplot(4,1,3)
plot(1/Fs:1/Fs:length(D5)/Fs, D5)
xlim([x_min x_max]);

subplot(4,1,4)
plot(1/Fs:1/Fs:length(A5)/Fs, A5)
xlim([x_min x_max]);


% plotting detail Wavelet decompositions
x_min = 5200;
x_max = 5800;
figure()
subplot(4,1,1)
plot(1/Fs:1/Fs:length(cD3)/Fs, cD3)


subplot(4,1,2)
plot(1/Fs:1/Fs:length(cD4)/Fs, cD4)


subplot(4,1,3)
plot(1/Fs:1/Fs:length(cD5)/Fs, cD5)


subplot(4,1,4)
plot(1/Fs:1/Fs:length(cA5)/Fs, cA5)

result = extract_freq_features(signal, epochLength, Fs)

% prepating labels for training -> labels in epochs
stage_per_epoch = [];
num_epochs = floor(length(stages)/epochLength);
for k=1:num_epochs
    stage_k = stages((k-1)*30+1);
    if stage_k == 1
        stage_k = 2;
    end
    stage_per_epoch(end+1) = stage_k;
end