% %analysing ECG Signal
% clc;
% close all;
% clear all;
% 
% %% load edf and xml files
% edfFilename = 'Data/R4.edf';
% xmlFilename = 'Data/R4.xml';
% [hdr, record] = edfread(edfFilename);
% [events, stages, epochLength,annotation] = readXML(xmlFilename);
% %%

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
    i = 4 % plot ECG
Fs = hdr.samples(i);
(length(record(i,:)')/Fs);
epochNumber = 1; % plot nth epoch of 30 seconds
epochStart = (epochNumber*Fs*30);
epochEnd = epochStart + 600*Fs;
signal = record(i,epochStart:epochEnd);
plot((1:length(signal))/Fs,signal);
ylabel(hdr.label(i));
xlim([1 10]);
subtitle(['30 seconds epoch #' num2str(epochNumber)]);
set(gcf,'color','w');

% looking at periodogram of singal (rectangual window)
figure();
[pxx,w] = periodogram(signal,hamming(length(signal)),length(signal),Fs);
plot(w,10*log10(pxx))

% filter frequency over 30 hz
fc = 15; % Hz
[b,a] = butter(16,fc/(Fs/2));
filt_signal = filter(b,a,signal);
figure()
plot((1:length(filt_signal))/Fs,filt_signal);
ylabel(hdr.label(i));
xlim([150 160]);
subtitle(['30 seconds epoch #' num2str(epochNumber)]);
set(gcf,'color','w');

figure()
[pxx_filt,w_filt] = periodogram(filt_signal,hamming(length(filt_signal)),length(filt_signal),Fs);
plot(w_filt,10*log10(pxx_filt))
