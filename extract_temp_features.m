function [mean_signal, variance, amplitude, skewness_signal, kurtosis_signal] = extract_temp_features(signal, epochLength, Fs)

numberOfEpochs = floor(length(signal)/epochLength/Fs);
mean_signal= zeros(1, numberOfEpochs);
variance = zeros(1, numberOfEpochs);
amplitude= zeros(1, numberOfEpochs);
skewness_signal= zeros(1, numberOfEpochs);
kurtosis_signal= zeros(1, numberOfEpochs);

for epochNumber=1:numberOfEpochs
    epochStart = ((epochNumber-1)*Fs*epochLength+1);
    epochEnd = (epochStart-1) + epochLength*Fs ;

    mean_signal(epochNumber)=mean(signal(epochStart:epochEnd));
    variance(epochNumber)=var(signal(epochStart:epochEnd));
    amplitude(epochNumber)=max(signal(epochStart:epochEnd))-min(signal(epochStart:epochEnd)); % Defined as maximum delta in a 
    skewness_signal(epochNumber)=skewness(signal(epochStart:epochEnd));
    kurtosis_signal(epochNumber)=kurtosis(signal(epochStart:epochEnd));
end
return

end
