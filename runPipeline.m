% runPipeline
clear all

run('settings.m')
addpath('helperFcns')
 
Pts= (1:numPatients);
%% 1) SETUP
% loads the raw data and computes a feature matrix for all subjects, then
% splits the matrix into testing and training sets for all patients, and HD
% patients, indexed by i_test, i_train, and i_testHD and i_trainHD
% respectively.



% Obtain/Load Feature Table
run('get_features.m')

% Aggregate features into feature matrix
features_all=[];   
% Array "features" will be size [nPatients x (nSensor Signals)(nFeatures)].
% Row organization: [s1f1, s1f2... s1fn s2f1, s2f2, ...s2fn... snfn],
% where f1s1 is feature 1 measured at sensor 1. 

% Select features for each task according to iFeats, concatenate into
% "features" matrix
for tname = taskList
    fts= featureTables.(tname{1})(Pts);                                                     
    features_all= [features_all, cell2mat(cellfun(@(x)reshape(x,1,[]), fts,...
        'UniformOutput', false))];
end

nFts=numel(featureTables.labels);
disp('Features aggregated')

save([dataDir, '/feature_matrix.mat'], 'features_all')
    

%% 2) BINARY CLASSIFICATION CV

type = 'Binary_Classification';
Pts= (1:numPatients);

cv_feats= cell(1, numPatients);
cv_model_performance= cell(1,numPatients); 

% Perform leave-one-out CV
tic
for pt_test=1:numPatients

    fprintf('pt %d', pt_test)
    
    % Form Training/Test sets
    pt_train= Pts(Pts~=pt_test); 
    labels_PtStatus = labels.PtStatus(pt_train);
    labels_PtStatus_test = labels.PtStatus(pt_test);
    
    trn_mn= mean(features_all(pt_train,:)); trn_std=std(features_all(pt_train,:));
    features= normalize(features_all(pt_train,:));                % all training set features
    features_test = (features_all(pt_test,:)-trn_mn)./trn_std;    % all test set features
    
    
    disp('Selecting Features...')
    [selected_fts, selected_test_fts, flabels]= selectFeats(features,features_test, ...
        labels_PtStatus, featureTables.labels, taskList, type, true);
    
    cv_feats{pt_test}=flabels; 

    classifier_application_app_Mx = array2table([selected_fts,labels_PtStatus], ...
        'VariableNames', [flabels','predictor']);

    disp('Training Classifiers ...')
    [binary_class_models, modelList, validationAccuracies] = trainClassifiers(classifier_application_app_Mx);

    disp('Tabulating results ...')
    model_performance= zeros(length(modelList), 3); 
    for model_num= 1:length(modelList)
        chosenModel= binary_class_models{model_num};
        model_name= chosenModel.model_name; 

        % This function calculates testing and training accuracy, and saves to
        % excel file in dataDir
        [trn_acc, tst_acc, AUC] = getModelResults(chosenModel, model_name,...
            selected_fts, selected_test_fts, labels_PtStatus, ...
            labels_PtStatus_test, flabels, [0,1], true);
        
        model_performance(model_num,:)=[trn_acc, tst_acc, AUC]; 
    end

    cv_model_performance{pt_test}= model_performance;

end
toc

disp('Classification CV done')

%% Compute and Save Classification Results

% Calculate average CV test and train accuracy
cv_mat= cell2mat(cv_model_performance);

% Gather list of missed data points
[mod, m_pt]=find(cv_mat(:,2:3:end)==0);     
missed= arrayfun(@(x)num2str(m_pt(m==x)'),[1:length(modelList)],'UniformOutput',false)';

% Get true/false positives, true/false negatives for each model
TP= (cv_mat(:,2:3:end)~=0)*(labels.PtStatus==1); 
TN= (cv_mat(:,2:3:end)~=0)*(labels.PtStatus==0);
FN= (cv_mat(:,2:3:end)==0)*(labels.PtStatus==1);    % predicted as 0 when actually 1
FP=(cv_mat(:,2:3:end)==0)*(labels.PtStatus==0);     % predicted as 1 when actually 0

bin_results_table= table(mean(cv_mat(:,1:3:end),2), mean(cv_mat(:,2:3:end),2),TP, FP, TN, FN, missed,...
    'VariableNames', {'CV_train_acc', 'CV_tst_acc', 'TP', 'FP', 'TN', 'FN', 'missed'},...
    'RowNames', modelList)

% Tabulate how often each feature was selected throughout cross validation
allfts= vertcat(cv_feats{:}); ufts= unique(allfts);
feat_freqs= cellfun(@(x) sum(ismember(allfts,x)), ufts);
[a, b]=sort(feat_freqs); 
ft_countss_table= table(ufts(b), a, 'VariableNames', {'Feature', 'count'})


save([dataDir, '/Results/Binary_Classification.mat'], 'cv_feats',...
    'cv_model_performance', 'bin_results_table', 'ft_countss_table')


disp('Binary Classification Done')


%% 2) REGRESSION MODEL CV


% Define subscore categories in "labels" table to predict
subscores= {'Gait', 'TandemGait', ...
    'Rigidity_RIGHTArm', 'Rigidity_LEFTArm', ...
    'FingerTaps_RIGHT', 'FingerTaps_LEFT',...
    'MaximalDystonia_trunkAnd4Extremities_',...
    'MaximalChorea_face_Mouth_Trunk_And4Extremities_', ...
    'Bradykinesia_body_', ...
    'combined_subscores'};

labels.combined_subscores=sum(labels{:,[11,12,15,20,21,22,23]},2); 
HDPts= Pts(logical(labels.PtStatus));

% iterate through all subscores
for i_scr = (1:length(subscores))
    
    type= subscores{i_scr};     % subscore type
    scrs=labels.(type);         % True subscores
    
    cv_reg_feats= cell(1, numPatients);
    cv_reg_model_performance= cell(1,numPatients); 
    
    % Set score range
    if strcmp(type, 'MaximalChorea_face_Mouth_Trunk_And4Extremities_'), rng = [0,28];
    elseif strcmp(type, 'MaximalDystonia_trunkAnd4Extremities_'), rng = [0,20];
    elseif strcmp(type, 'combined_subscores'), rng = [0,80];
    else, rng = [0,4];
    end

% Perform leave one out CV to predict subscore
for pt_test=1:numPatients

    fprintf('pt %d\n', pt_test)
    
    % Form Training/Test sets
    pt_train= HDPts(HDPts~=pt_test); 
    reg_labels = scr(pt_train);
    reg_labels_test = scr(pt_test);
    
    trn_mn= mean(features_all(pt_train,:)); trn_std=std(features_all(pt_train,:));
    features= normalize(features_all(pt_train,:));                % all training set features
    features_test = (features_all(pt_test,:)-trn_mn)./trn_std;    % all test set features

    disp('Selecting Features...')
    [selected_fts, selected_test_fts, flabels]= selectFeats(features, features_test, ...
        reg_labels, featureTables.labels, taskList, type, false);
    cv_feats{pt_test}=flabels; 

    disp('Training Classifiers ...')
    regressionlearner_mx= array2table([selected_fts, reg_labels], 'VariableNames', [flabels', 'predictor']);
    [class_models, modelList, validationRMSE] = trainRegressionModels(regressionlearner_mx);

    disp('Tabulating results ...')

    model_performance= zeros(length(modelList), 3); 
    for model_num= 1:length(modelList)
        chosenModel= class_models{model_num};
        model_name= chosenModel.model_name;

        % This function calculates testing and training accuracy, and saves to
        % excel file in dataDir
        [trn_ME, tst_ME, trntst_corrs, y_tst] = getModelResults(chosenModel, ...
            model_name, selected_fts, selected_test_fts, reg_labels,...
            reg_labels_test, flabels, rng, false);

        model_performance(model_num,:)=[trn_ME, tst_ME, y_tst];
    end
    
    cv_model_performance{pt_test}= model_performance;
    
end


% Compile results
cv_mat= cell2mat(cv_model_performance);
error= cv_mat(:,3:3:end)-scrs';  
reg_results_table= table(error,'RowNames', modelList);
reg_results_table.pcnt_error=reg_results_table.error/rng(2)*100;
reg_results_table.abs_mn_error_HD =  mean(abs(reg_results_table.error(:,HDPts)),2);
reg_results_table.abs_mn_error_HD_pcnt =  reg_results_table.abs_mn_error_HD/rng(2)*100;
reg_results_table.abs_mn_error_all= mean(abs(reg_results_table.error),2);
reg_results_table.abs_mn_error_all_pcnt= reg_results_table.abs_mn_error_all/rng(2)*100

% Tabulate how often each feature was selected throughout cross validation
allfts= vertcat(cv_feats{:}); ufts= unique(allfts);
feat_freqs= cellfun(@(x) sum(ismember(allfts,x)), ufts);
[a, b]=sort(feat_freqs); 
ft_counts_table= table(ufts(b), a, 'VariableNames', {'Feature', 'count'});

save([dataDir,'/Results/' type, '.mat'],'cv_feats', 'cv_model_performance', 'type', ...
    'reg_results_table', 'ft_counts_table', 'rng')

fprintf('%s CV done\n', type)

end