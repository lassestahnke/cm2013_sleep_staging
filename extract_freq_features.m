function [energies] = extract_freq_features(signal, epochLength, Fs)

numberOfEpochs = floor(length(signal)/epochLength/Fs);
% inintializing features:
energies = zeros(4,numberOfEpochs);
energies_norm = zeros(4,numberOfEpochs);
% perform wavelet decomposition
waveletFunction = 'db8';
%sig_crop = signal(125*140:125*170);
[C,L] = wavedec(signal,5,waveletFunction);

cD1 = detcoef(C,L,1); % 62.5 - 125 Hz --> Noise
cD2 = detcoef(C,L,2); % Gamma; 32.25 - 62.5 Hz --> not interesting
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

length(A5)
for epochNumber=1:numberOfEpochs
    epochStart = ((epochNumber-1)*Fs*epochLength+1);
    epochEnd = (epochStart-1) + epochLength*Fs ;

    % compute signal energy for each band
    energies(1,epochNumber) = sum(D3(epochStart:epochEnd).^2); %beta
    energies(2,epochNumber) = sum(D4(epochStart:epochEnd).^2); %alpha
    energies(3,epochNumber) = sum(D5(epochStart:epochEnd).^2); %theta
    energies(4,epochNumber) = sum(A5(epochStart:epochEnd).^2); %delta
    
    %compute total sum of energies in an epoch
    energies_total=sum(energies(:,epochNumber));
    
    %compute energy ratio per band E_i / E_total
    energies_norm(1,epochNumber) = energies(1,epochNumber)./energies_total; %beta
    energies_norm(2,epochNumber) = energies(2,epochNumber)./energies_total; %alpha
    energies_norm(3,epochNumber) = energies(3,epochNumber)./energies_total; %theta
    energies_norm(4,epochNumber) = energies(4,epochNumber)./energies_total; %delta



end
return

end
