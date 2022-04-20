% Function calculating temporal features of a signal

% NEW VERSION THAT TAKES ANY VECTOR AS AN INPUT AND OUTPUTS FEATURES
% CALCULATED FROM JUST THAT ONE VECTOR, DOES NOT DIVIDE INTO EPOCHS
% AUTOMATICALLY

%{
    Arguments:

    signal_vector[1D array]: input signal values
    temporal_feature[string cell array]: temporal features to extract
        {'mean', 'variance', 'amplitude', 'skewness', 'kurtosis'}
            comment: case insensitive, one or multiple features, any order

    Output:
    result_features[1D Array]: order of output features same as order of
    input features

%}

% function [result_features] = extract_temp_features(signal_vector, temporal_feature)
%     temporal_feature = lower(temporal_feature);
%     num_features = length(temporal_feature);
%     result_features=[];
% 
%      for i = 1:num_features
%         tmp_feature = cell2mat(temporal_feature(i));
% 
%         switch tmp_feature
% 
%         % Calculate mean
%             case 'mean' % calculate mean
%             mean_signal=mean(signal_vector);
%             tmp_result=mean_signal;
% 
%         % Calculate variance
%             case 'variance'
%             variance=var(signal_vector);
%             tmp_result=variance;
% 
%         % Calculate amplitude
%             case 'amplitude'
%             amplitude=max(signal_vector)-min(signal_vector); % Defined as maximum delta in a
%             tmp_result=amplitude;
% 
%         % Calculate skewness
%             case 'skewness'
%             skewness_signal=skewness(signal_vector);
%             tmp_result=skewness_signal;
% 
%         % Calculate kurtosis
%             case 'kurtosis'
%             kurtosis_signal=kurtosis(signal_vector);
%             tmp_result=kurtosis_signal;
%         end
%         result_features = [result_features tmp_result];
%     end
%     
% end

% % OLD VERSION THAT TAKES THE ENTIRE SIGNAL AS AN INPUT AND OUTPUTS FEATURES
% % IN EPOCHS
% % comment above and uncomment this part to use the old function

function [temp_features] = extract_temp_features(signal, epochLength, Fs)

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

temp_features=[mean_signal; variance; amplitude; skewness_signal; kurtosis_signal];
end
