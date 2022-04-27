function [hjort_parameters] = extract_hjort_parameters(signal, epochLength, Fs)
% Function calculating Hjort parameters of a signal
numberOfEpochs = floor(length(signal)/epochLength/Fs);

activity = zeros(1, numberOfEpochs);
mobility= zeros(1, numberOfEpochs);
complexity= zeros(1, numberOfEpochs);

for epochNumber=1:numberOfEpochs
    epochStart = ((epochNumber-1)*Fs*epochLength+1);
    epochEnd = (epochStart-1) + epochLength*Fs ;
    activity = var(signal(epochStart:epochEnd));

    mobility(epochNumber) = sqrt(var(gradient(signal(epochStart:epochEnd)))/activity);
    complexity(epochNumber) = (sqrt(var(gradient(gradient(signal(epochStart:epochEnd)))))/var(signal(epochStart:epochEnd)))/mobility(epochNumber);
end

hjort_parameters=[mobility; complexity];
end


