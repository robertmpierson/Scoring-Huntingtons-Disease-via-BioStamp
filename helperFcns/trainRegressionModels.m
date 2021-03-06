function [trainedModels, modelList, validationRMSE] = trainRegressionModels(inputTable)
% [trainedModel, validationRMSE] = trainRegressionModel(trainingData)
% returns a trained regression models and its RMSE.
%
%  Input:
%      trainingData: a table containing the same predictor and response
%       columns as imported into the app.
%
%  Output:
%      trainedModel: a cell arrya of structs containing the trained regression models. The
%       struct contains various fields with information about the trained model.
%
%      validationRMSE: array containing the RMSE.
%
% Use the code to train the model with new data. To retrain your model,
% call the function from the command line with your original data or new
% data as the input argument trainingData.

% Modified code that was auto-generated by MATLAB on 18-Jan-2020 12:48:14


% Extract predictors and response
% This code processes the data into the right shape for training the
% model.

predictorNames = inputTable.Properties.VariableNames(1:end-1);
predictors = inputTable(:, predictorNames);
response = inputTable.predictor;

predictorExtractionFcn = @(t) t(:, predictorNames);
modelList=cell(1,7);
ctr=1; 

% Train Models
%% (1) Linear Regression

linearModel = fitlm(predictors, 'linear', 'RobustOpts', 'off');

% Create the result struct with predict function
linearModelPredictFcn = @(x) predict(linearModel, x);

trainedModels{ctr}.predictFcn = @(x) linearModelPredictFcn(predictorExtractionFcn(x));
trainedModels{ctr}.RequiredVariables = predictorNames;
trainedModels{ctr}.LinearModel = linearModel;
trainedModels{ctr}.model_name = 'linear regression';
modelList{ctr}=trainedModels{ctr}.model_name;

% Perform cross-validation
KFolds = 5;
cvp = cvpartition(size(response, 1), 'KFold', KFolds);
% Initialize the predictions to the proper sizes
validationPredictions = response;
for fold = 1:KFolds
    trainingPredictors = predictors(cvp.training(fold), :);
    trainingResponse = response(cvp.training(fold), :);
    
    % Train a regression model
    % This code specifies all the model options and trains the model.
    concatenatedPredictorsAndResponse = trainingPredictors;
    concatenatedPredictorsAndResponse.predictor = trainingResponse;
    linearModel = fitlm(concatenatedPredictorsAndResponse, ...
        'linear','RobustOpts', 'off');
    
    % Create the result struct with predict function
    linearModelPredictFcn = @(x) predict(linearModel, x);
    validationPredictFcn = @(x) linearModelPredictFcn(x);

    % Compute validation predictions
    validationPredictors = predictors(cvp.test(fold), :);
    foldPredictions = validationPredictFcn(validationPredictors);
    
    % Store predictions in the original order
    validationPredictions(cvp.test(fold), :) = foldPredictions;
end

% Compute validation RMSE
isNotMissing = ~isnan(validationPredictions) & ~isnan(response);
validationRMSE(ctr) = sqrt(nansum(( validationPredictions - response ).^2) / numel(response(isNotMissing) ));

ctr=ctr+1;
%% (2) Fine Tree

regressionTree = fitrtree(predictors,response, ...
    'MinLeafSize', 4,'Surrogate', 'off');

treePredictFcn = @(x) predict(regressionTree, x);
trainedModels{ctr}.predictFcn = @(x) treePredictFcn(predictorExtractionFcn(x));
trainedModels{ctr}.RequiredVariables = predictorNames;
trainedModels{ctr}.RegressionTree = regressionTree;
trainedModels{ctr}.model_name = 'fine tree';
modelList{ctr}=trainedModels{ctr}.model_name;

partitionedModel = crossval(trainedModels{ctr}.RegressionTree, 'KFold', 5);
validationRMSE(ctr) = sqrt(kfoldLoss(partitionedModel, 'LossFun', 'mse'));

ctr=ctr+1;

%% (3) Linear SVM

responseScale = iqr(response);
if ~isfinite(responseScale) || responseScale == 0.0
    responseScale = 1.0;
end
boxConstraint = responseScale/1.349;
epsilon = responseScale/13.49;
regressionSVM = fitrsvm(predictors, response,'KernelFunction', 'linear', ...
    'PolynomialOrder', [],'KernelScale', 'auto','BoxConstraint', boxConstraint, ...
    'Epsilon', epsilon,'Standardize', true);

svmPredictFcn = @(x) predict(regressionSVM, x);
trainedModels{ctr}.predictFcn =@(x) svmPredictFcn(predictorExtractionFcn(x));
trainedModels{ctr}.RequiredVariables = predictorNames;
trainedModels{ctr}.RegressionSVM = regressionSVM;
trainedModels{ctr}.model_name = 'linear svm';
modelList{ctr}=trainedModels{ctr}.model_name;


% Perform cross-validation
KFolds = 5;
cvp = cvpartition(size(response, 1), 'KFold', KFolds);
% Initialize the predictions to the proper sizes
validationPredictions = response;
for fold = 1:KFolds
    trainingPredictors = predictors(cvp.training(fold), :);
    trainingResponse = response(cvp.training(fold), :);
    
    responseScale = iqr(trainingResponse);
    if ~isfinite(responseScale) || responseScale == 0.0
        responseScale = 1.0;
    end
    boxConstraint = responseScale/1.349;
    epsilon = responseScale/13.49;
    regressionSVM = fitrsvm( trainingPredictors, trainingResponse, ...
        'KernelFunction', 'linear','PolynomialOrder', [],'KernelScale', 'auto', ...
        'BoxConstraint', boxConstraint,'Epsilon', epsilon,'Standardize', true);
    
    % Create the result struct with predict function
    svmPredictFcn = @(x) predict(regressionSVM, x);
    validationPredictFcn = @(x) svmPredictFcn(x);
    
    % Compute validation predictions
    validationPredictors = predictors(cvp.test(fold), :);
    foldPredictions = validationPredictFcn(validationPredictors);
    
    % Store predictions in the original order
    validationPredictions(cvp.test(fold), :) = foldPredictions;
end

% Compute validation RMSE
isNotMissing = ~isnan(validationPredictions) & ~isnan(response);
validationRMSE(ctr) = sqrt(nansum(( validationPredictions - response ).^2) / numel(response(isNotMissing) ));

ctr=ctr+1;
%% (4) Quadratic SVM

responseScale = iqr(response);
if ~isfinite(responseScale) || responseScale == 0.0
    responseScale = 1.0;
end
boxConstraint = responseScale/1.349;
epsilon = responseScale/13.49;
regressionSVM = fitrsvm(predictors, response,'KernelFunction', 'polynomial', ...
    'PolynomialOrder', 2,'KernelScale', 'auto','BoxConstraint', boxConstraint, ...
    'Epsilon', epsilon,'Standardize', true);

svmPredictFcn = @(x) predict(regressionSVM, x);
trainedModels{ctr}.predictFcn =@(x) svmPredictFcn(predictorExtractionFcn(x));
trainedModels{ctr}.RequiredVariables = predictorNames;
trainedModels{ctr}.RegressionSVM = regressionSVM;
trainedModels{ctr}.model_name = 'quadratic SVM';
modelList{ctr}=trainedModels{ctr}.model_name;


% Perform cross-validation
KFolds = 5;
cvp = cvpartition(size(response, 1), 'KFold', KFolds);
% Initialize the predictions to the proper sizes
validationPredictions = response;
for fold = 1:KFolds
    trainingPredictors = predictors(cvp.training(fold), :);
    trainingResponse = response(cvp.training(fold), :);
    
    responseScale = iqr(trainingResponse);
    if ~isfinite(responseScale) || responseScale == 0.0
        responseScale = 1.0;
    end
    boxConstraint = responseScale/1.349;
    epsilon = responseScale/13.49;
    regressionSVM = fitrsvm( trainingPredictors, trainingResponse, ...
        'KernelFunction', 'polynomial','PolynomialOrder', 2,'KernelScale', 'auto', ...
        'BoxConstraint', boxConstraint,'Epsilon', epsilon,'Standardize', true);
    
    % Create the result struct with predict function
    svmPredictFcn = @(x) predict(regressionSVM, x);
    validationPredictFcn = @(x) svmPredictFcn(x);
    
    % Compute validation predictions
    validationPredictors = predictors(cvp.test(fold), :);
    foldPredictions = validationPredictFcn(validationPredictors);
    
    % Store predictions in the original order
    validationPredictions(cvp.test(fold), :) = foldPredictions;
end

% Compute validation RMSE
isNotMissing = ~isnan(validationPredictions) & ~isnan(response);
validationRMSE(ctr) = sqrt(nansum(( validationPredictions - response ).^2) / numel(response(isNotMissing) ));

ctr=ctr+1;
%% (5) Ensemble Boosted Trees

template = templateTree('MinLeafSize', 8);
regressionEnsemble = fitrensemble(predictors, response,'Method', 'LSBoost', ...
    'NumLearningCycles', 30,'Learners', template, 'LearnRate', 0.1);

ensemblePredictFcn = @(x) predict(regressionEnsemble, x);
trainedModels{ctr}.predictFcn = @(x) ensemblePredictFcn(predictorExtractionFcn(x));
trainedModels{ctr}.RequiredVariables = predictorNames;
trainedModels{ctr}.RegressionEnsemble = regressionEnsemble;
trainedModels{ctr}.model_name = 'ensemble boosted trees';
modelList{ctr}=trainedModels{ctr}.model_name;

partitionedModel = crossval(trainedModels{ctr}.RegressionEnsemble, 'KFold', 5);
validationRMSE(ctr) = sqrt(kfoldLoss(partitionedModel, 'LossFun', 'mse'));

ctr=ctr+1;

%% (6) Ensemble Bagged Trees

template = templateTree('MinLeafSize', 8);
regressionEnsemble = fitrensemble(predictors, response,'Method', 'Bag', ...
    'NumLearningCycles', 30,'Learners', template);

ensemblePredictFcn = @(x) predict(regressionEnsemble, x);
trainedModels{ctr}.predictFcn = @(x) ensemblePredictFcn(predictorExtractionFcn(x));
trainedModels{ctr}.RequiredVariables = predictorNames;
trainedModels{ctr}.RegressionEnsemble = regressionEnsemble;
trainedModels{ctr}.model_name = 'ensemble bagged trees';
modelList{ctr}=trainedModels{ctr}.model_name;

partitionedModel = crossval(trainedModels{ctr}.RegressionEnsemble, 'KFold', 5);
validationRMSE(ctr) = sqrt(kfoldLoss(partitionedModel, 'LossFun', 'mse'));

ctr=ctr+1;

%% (7) Gaussian Process Exponential GPR

regressionGP = fitrgp(predictors,response, 'BasisFunction', 'constant',...
    'KernelFunction', 'exponential','Standardize', true);

gpPredictFcn = @(x) predict(regressionGP, x);
trainedModels{ctr}.predictFcn = @(x) gpPredictFcn(predictorExtractionFcn(x));
trainedModels{ctr}.RequiredVariables = predictorNames;
trainedModels{ctr}.RegressionGP = regressionGP;
trainedModels{ctr}.model_name = 'Exponential Gaussian Process';
modelList{ctr}=trainedModels{ctr}.model_name;

partitionedModel = crossval(trainedModels{ctr}.RegressionGP, 'KFold', 5);
validationRMSE(ctr) = sqrt(kfoldLoss(partitionedModel, 'LossFun', 'mse'));
