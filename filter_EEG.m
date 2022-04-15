function [wav_filt_signal] = filter_EEG(signal, method, Fs)
        x_min = 5200;
        x_max = 5800;
switch method
    case 'wavelet_filter'
    
        waveletFunction = 'db8';
    
        [C,L] = wavedec(signal,5,waveletFunction);
        
        %get detail and approximation coefficient vectors
        cD1 = detcoef(C,L,1); % 62.5 - 125 Hz
        cD2 = detcoef(C,L,2); % Gamma; 32.25 - 62.5 Hz
        cD3 = detcoef(C,L,3); % Beta; 16.125 - 32.25 Hz
        cD4 = detcoef(C,L,4); % Alpha; 8.06 - 16.13 Hz
        cD5 = detcoef(C,L,5); % Theta; 4.03 - 8.06 Hz
        cA5 = appcoef(C,L,waveletFunction,5); % Delta; 0 -4.03 Hz
        
        %reconstruct the signal from wavelet coefficients
        D1 = wrcoef('d',C,L,waveletFunction,1); % 
        D2 = wrcoef('d',C,L,waveletFunction,2); % Gamma
        D3 = wrcoef('d',C,L,waveletFunction,3); % Beta
        D4 = wrcoef('d',C,L,waveletFunction,4); % Alpha
        D5 = wrcoef('d',C,L,waveletFunction,5); % Theta
        A5 = wrcoef('a',C,L,waveletFunction,5); % Delta
    
        % plotting Wavelet decompositions
    
%         figure('Name','Reconstructed signal at different levels')
%         subplot(4,1,1)
%         title('D3 - beta')
%         plot(1/Fs:1/Fs:length(D3)/Fs, D3)
%         xlim([x_min x_max]);
%         
%         subplot(4,1,2)
%         title('D4 - alpha')
%         plot(1/Fs:1/Fs:length(D4)/Fs, D4)
%         xlim([x_min x_max]);
%         
%         subplot(4,1,3)
%         title('D5 - theta')
%         plot(1/Fs:1/Fs:length(D5)/Fs, D5)
%         xlim([x_min x_max]);
%         
%         subplot(4,1,4)
%         title('A5 - delta')
%         plot(1/Fs:1/Fs:length(A5)/Fs, A5)
%         xlim([x_min x_max]);
    
        % plotting wavelet decomposition coefficients
    
%         figure('Name', 'Wavelet decomposition coefficients')
%         subplot(4,1,1)
%         title('cD3')
%         plot(1/Fs:1/Fs:length(cD3)/Fs, cD3)
%         
%         subplot(4,1,2)
%         title('cD4')
%         plot(1/Fs:1/Fs:length(cD4)/Fs, cD4)
%         
%         subplot(4,1,3)
%         title('cD5')
%         plot(1/Fs:1/Fs:length(cD5)/Fs, cD5)
%         
%         subplot(4,1,4)
%         title('cA5')
%         plot(1/Fs:1/Fs:length(cA5)/Fs, cA5)

        %filtering out high frequencies
        cD1_new = zeros(1,length(cD1));
        cD2_new = zeros(1,length(cD2)); % Gamma; 32.25 - 62.5 Hz
        C_new = [cA5 cD5 cD4 cD3 cD2_new cD1_new];

%         figure('Name','original vs filtered signal')
%         subplot(2,1,1)
        wav_filt_signal = waverec(C_new,L,waveletFunction);
%         plot((1:length(wav_filt_signal))/Fs,wav_filt_signal);
%         title('filtered')
%         xlim([x_min x_max]);
% 
%         subplot(2,1,2)
%         plot((1:length(signal))/Fs,signal);
%         title('original')
%         xlim([x_min x_max]);
        


    case 'butter_filter'

        % filter frequency over 30 hz
        fc = 32.25; % cutoff frequency [Hz]
        [b,a] = butter(16,fc/(Fs/2));
        butter_filt_signal = filter(b,a,signal);
        figure("Name",'Butterworth method filtered signal vs original')

        subplot(3,1,1)
        plot((1:length(butter_filt_signal))/Fs,butter_filt_signal);
        title('filtered')
        xlim([x_min x_max]);
        set(gcf,'color','w');
        
        subplot(3,1,2)
        plot((1:length(signal))/Fs,signal);
        title('original')
        xlim([x_min x_max]);

        filt_original_diff = signal-butter_filt_signal;
        subplot(3,1,3)
        plot((1:length(filt_original_diff))/Fs,filt_original_diff);
        title('original - filtered')
        xlim([x_min x_max]);

        figure("Name",'Periodogram of the filtered signal')
        [pxx_filt,w_filt] = periodogram(butter_filt_signal,hamming(length(butter_filt_signal)),length(butter_filt_signal),Fs);
        plot(w_filt,10*log10(pxx_filt))

%         figure("Name",'Periodogram of original - filtered')
%         [pxx_filt,w_filt] = periodogram(filt_original_diff,hamming(length(filt_original_diff)),length(filt_original_diff),Fs);
%         plot(w_filt,10*log10(pxx_filt))
    
    otherwise
        fprintf('wrong input arguments \n')


end