% Function calculating Hjort parameters of a signal

% NEW VERSION THAT TAKES ANY VECTOR AS AN INPUT AND OUTPUTS FEATURES
% CALCULATED FROM JUST THAT ONE VECTOR, DOES NOT DIVIDE INTO EPOCHS
% AUTOMATICALLY

%{
    Arguments:

    signal_vector[1D array]: input signal values
    temporal_feature[string cell array]: hjort parameters to extract
        {'mobility','complexity'}
            comment: case insensitive, one or multiple parameters, any order

    Output:
    result_parameters[1D Array]: defined hjort parameters
    comment: order of output parameters same as order of input parameters

%}


% function [result_parameters] = extract_hjort_parameters(signal_vector, hjort_parameter)
%     hjort_parameter = lower(hjort_parameter);
%     num_parameters = length(hjort_parameter);
%     result_parameters=[];
% 
%     activity = var(signal_vector);
% 
%      for i = 1:num_parameters
%         tmp_parameter = cell2mat(hjort_parameter(i));
% 
%         switch tmp_parameter
% 
%         % Calculate mobility
%             case 'mobility'
%             mobility = sqrt(var(gradient(signal_vector))/activity);
%             tmp_result=mobility;
% 
%         % Calculate complexity
%             case 'complexity'
%             mobility = sqrt(var(gradient(signal_vector))/activity);
%             complexity = (sqrt(var(gradient(gradient(signal_vector))))/var(signal_vector)) ...
%                 /mobility;
%             tmp_result=complexity;
% 
%         end
%         result_parameters = [result_parameters tmp_result];
%      end
% end

% % OLD VERSION THAT TAKES THE ENTIRE SIGNAL AS AN INPUT AND OUTPUT PARAMETERS
% % IN EPOCHS
% % comment above and uncomment this part to use the old function

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


