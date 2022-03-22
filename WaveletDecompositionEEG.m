%load eegdata.mat;
%s=eegdata;
clc;
close all;
clear all;

%%Part 1 
%% a) Data importation (and bugging)
edfFilename = 'Data/R1.edf';
xmlFilename = 'Data/R1.xml';
[hdr, record] = edfread(edfFilename);
[events, stages, epochLength,annotation] = readXML(xmlFilename);
numberOfEpochs = length(record(3,:)')/(30*hdr.samples(3))

%% b) Data visualization
figure(1);
signal = record(:,1:3750); 
for i=1:14
subplot(size(signal,1),1,i);
plot(signal(i,:))
end

%% c) One EEG channel Visualization
eeg=signal(8,:)
s=eeg;
figure (2);p=plot(s,'r');
title('EEG Signal')
hold on

%%Part 2
%% d)filtering 
sig=s;
fs = hdr.samples(8);
[A,B] = butter(4,[0.3 35]/fs, "bandpass");
%d = designfilt('bandpassiir','FilterOrder',20, ...
%    'HalfPowerFrequency1', 0.3,'HalfPowerFrequency2', 35, ...
%    'SampleRate',1500);
y = filtfilt(A, B, sig)

p=plot(y,'b');
hold on







%%Part 3
%% e) wavelet decomposition 
N=length(s);
 

waveletFunction = 'db8';
                [C,L] = wavedec(s,8,waveletFunction);
       
                cD1 = detcoef(C,L,1);
                cD2 = detcoef(C,L,2);
                cD3 = detcoef(C,L,3);
                cD4 = detcoef(C,L,4);
                cD5 = detcoef(C,L,5); 
                cD6 = detcoef(C,L,6); 
                cD7 = detcoef(C,L,7); 
                cD8 = detcoef(C,L,8); 
                cA8 = appcoef(C,L,waveletFunction,8); 
                D1 = wrcoef('d',C,L,waveletFunction,1);
                D2 = wrcoef('d',C,L,waveletFunction,2);
                D3 = wrcoef('d',C,L,waveletFunction,3);
                D4 = wrcoef('d',C,L,waveletFunction,4);
                D5 = wrcoef('d',C,L,waveletFunction,5); 
                D6 = wrcoef('d',C,L,waveletFunction,6); 
                D7 = wrcoef('d',C,L,waveletFunction,7); 
                D8 = wrcoef('d',C,L,waveletFunction,8); 
                A8 = wrcoef('a',C,L,waveletFunction,8); 
                
                %%plot EEG waves
             
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                

 
%%Part 4
%% f) Frequency domain extraction  

%fft


freq = 0:N/length(D5):N/2;
xdft = xdft(1:length(D5)/2+1);

% figure;
figure;

% calculate max and display it
[~,I] = max();
fprintf('Gamma:Maximum occurs at %3.2f Hz.\n',freq(I));

%redo the same steps for each EEG wave

