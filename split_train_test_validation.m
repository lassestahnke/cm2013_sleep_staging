function [x_train, y_train, x_validation, y_validation, x_test, y_test] ...
    = split_train_test_validation(x_data, y_data, rel_validation, rel_test, rnd_seed)
% split dataset into train, validation and test
rng(rnd_seed); % set random seed
num_samples = size(x_data,1);

idx_all = randperm(num_samples);
idx_train = idx_all(1:round(num_samples*(1-rel_test-rel_validation)));
idx_validation = idx_all(round(num_samples* ...
                         (1-rel_test-rel_validation)) ...
                          +1:round(num_samples*(1-rel_test)));
idx_test = idx_all(round(num_samples*(1-rel_test))+1:end);

x_train = x_data(idx_train,:);
y_train = y_data(idx_train);

x_validation = x_data(idx_validation,:);
y_validation = y_data(idx_validation);

x_test = x_data(idx_test,:);
y_test = y_data(idx_test);

end