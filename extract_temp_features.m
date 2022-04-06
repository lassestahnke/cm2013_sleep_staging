function [mean_signal, variance, amplitude] = extract_temp_features(signal, epochLength, numberOfEpochs, Fs)
length_signal =  length(signal);
%numberOfEpochs = length_signal/epochLength;
mean_signal= zeros(1, numberOfEpochs);
variance = zeros(1, numberOfEpochs);
amplitude= zeros(1, numberOfEpochs);

for epochNumber=1:numberOfEpochs
    epochStart = (epochNumber*Fs);
    epochEnd = epochStart + 30*Fs;
    mean_signal(epochNumber)=mean(signal(epochStart:epochEnd));
    variance(epochNumber)=var(signal(epochStart:epochEnd));
    amplitude(epochNumber)=max(signal(epochStart:epochEnd))-min(signal(epochStart:epochEnd)); % Defined as maximum delta in a 
end
return

end
