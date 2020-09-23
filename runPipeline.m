% runPipeline
clear all

run('config.m')
addpath('helperFcns')
 
Pts= (1:numPatients);
%% 1) CLASSIFICATION SETUP
% loads the raw data and computes a feature matrix for all subjects, then
% splits the matrix into testing and training sets for all patients, and HD
% patients, indexed by i_test, i_train, and i_testHD and i_trainHD
% respectively.

% Obtain/Load Feature Table
run('get_features.m')

% Aggregate features into feature matrix
features_all=[];
ftNames= [];
% Array "features" will be size [nPatients x (nSensor Signals)(nFeatures)].
% Row organization: [s1f1, s1f2... s1fn s2f1, s2f2, ...s2fn... snfn],
% where f1s1 is feature 1 measured at sensor 1. 

% Select features for each task according to iFeats, concatenate into
% "features" matrix
for tname = taskList
    fts = featureTables.(tname{1});                                                     
    features_all= [features_all, cell2mat(cellfun(@(x)reshape(x,1,[]), fts,...
        'UniformOutput', false))];
    ftNames = [ftNames, strcat(tname, reshape(featureTables.labels,1,[]))];
end

nFts = numel(featureTables.labels);

disp('Features aggregated')

save([dataDir, '/classification_feature_matrix.mat'], 'features_all')

% Indices of HD patients & controls
HDPts= Pts(logical(labels.PtStatus));           
CtrPts =  Pts(~logical(labels.PtStatus));


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
     
    % Get zscored training features and testing features
    [features, trn_mn, trn_std] = zscore(features_all(pt_train,:)); % all training set features
    features_test = (features_all(pt_test,:)-trn_mn)./trn_std;      % all test set features
    
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
% each row is arranged as [trn_acc, tst_acc, AUC] for each patient (so row length= 3 x nPts)
cv_mat= cell2mat(cv_model_performance);

% Gather list of missed data points
[mod, m_pt]=find(cv_mat(:,2:3:end) == 0);   % get test_acc for each patient & each classifier  
missed= arrayfun(@(x)num2str(m_pt(mod == x )'),(1:length(modelList)),'UniformOutput',false)';

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

%% 3) REGRESSION MODEL CV

% Aggregate all features used for the regression model. The current
% configuration selects Sitting and Gait features from each subject as well
% as segmented Sitting features

load(fullfile(dataDir,'dataTables.mat'));

seg = 'Gait_Seg_Intervals';
ftTaskList = {'Sitting', 'Posture', seg};

[ftNames, features_task, ptMap, features_all] = deal([]);
for tname = ftTaskList(1:end-1)
    fts = featureTables.(tname{1});                                                     
    features_task= [features_task, cell2mat(cellfun(@(x)x(:)', fts,'Uni', 0))];
    ftNames = [ftNames, strcat(tname, featureTables.labels(:)')];
end

if strcmp(seg, 'Gait_Seg_Intervals')
    %Collect Gait_Seg_Intervals Features:
    for n = 1:numIntervals
        fts = featureTables.(seg){1,n}; 
        ft_mat = cell2mat(cellfun(@(x)reshape(x,1,[]), fts, 'Uni', 0)); 
        intvl = features_task(featureTables.(seg){2,n},:); 
        features_all= [features_all; [intvl, ft_mat]];
        ptMap = [ptMap, featureTables.(seg){2,n}];
    end
else 
    % Collect Sitting_Seg Features:
    fts = featureTables.(seg);
    ptMap = dataTables.Sitting_ptList;
    ft_mat = cell2mat(cellfun(@(x)reshape(x,1,[]), fts, 'Uni', 0)); 
    intvl = features_task(ptMap,:); 
    features_all= [intvl, ft_mat];
end

ftNames = [ftNames, strcat(seg, reshape(featureTables.labels,1,[]))];

disp('Features aggregated')

save([dataDir, '/regression_feature_matrix.mat'], 'features_all', 'ftTaskList')

%%
% Define subscore categories in "labels" table to predict
subscores= {'Gait', 'TandemGait', ...
    'Rigidity_RIGHTArm', 'Rigidity_LEFTArm', ...
    'MaximalDystonia_trunkAnd4Extremities_',...
    'MaximalChorea_face_Mouth_Trunk_And4Extremities_', ...
    'Bradykinesia_body_', ...
    'combined_subscores'};

labels.combined_subscores = sum(labels{:,[11,12,20,21,22,23]},2); 

% Indices of HD patients & controls
HDPts= Pts(logical(labels.PtStatus));           
CtrPts =  Pts(~logical(labels.PtStatus));
labels.PtStatus(ptMap);

% iterate through all subscores
for i_scr = length(subscores)

    type= subscores{i_scr};     % subscore type
    scrs=labels.(type)(ptMap);  % True subscores
    
    cv_reg_feats= cell(1, numPatients);
    cv_reg_model_performance= cell(1,numPatients); 
    
    % Set score range (range is the total possible score a patient could
    % get in the categories counted). 
    if strcmp(type, 'MaximalChorea_face_Mouth_Trunk_And4Extremities_'), rng = [0,28];
    elseif strcmp(type, 'MaximalDystonia_trunkAnd4Extremities_'), rng = [0,20];
    elseif strcmp(type, 'combined_subscores'), rng = [0,80];
    else, rng = [0,4];
    end

    % Perform leave one out CV to predict subscore
    % train only on HD patients
    for pt_t=1:numPatients
        
        fprintf('pt %d\n', pt_t)

        % Form Training/Test sets. Training set has only HD patients       
        pt_train= find((ptMap~=pt_t)'.*logical(labels.PtStatus(ptMap)));
        reg_labels = scrs(pt_train);
        
        pt_test = find(ptMap==pt_t);
        reg_labels_test = scrs(pt_test);
        
       
        [features,trn_mn, trn_std]= zscore(features_all(pt_train,:));   % all training set features
        features_test = (features_all(pt_test,:)-trn_mn)./trn_std;      % all test set features

        disp('Selecting Features...')
        [selected_fts, selected_test_fts, flabels]= selectFeats(features, features_test, ...
            reg_labels, featureTables.labels, ftTaskList, type, false);
        cv_feats{pt_t}=flabels; 

        disp('Training Classifiers ...')
        regressionlearner_mx= array2table([selected_fts, reg_labels], 'VariableNames', [flabels', 'predictor']);
        [class_models, modelList, validationRMSE] = trainRegressionModels(regressionlearner_mx);

        disp('Tabulating results ...')

        model_performance= zeros(length(modelList), 4); 
        for model_num= 1:length(modelList)
            chosenModel= class_models{model_num};
            model_name= chosenModel.model_name;

            % This function calculates testing and training accuracy, and saves to
            % excel file in dataDir
            [trn_ME, tst_ME, trntst_corrs, y_tst] = getModelResults(chosenModel, ...
                model_name, selected_fts, selected_test_fts, reg_labels,...
                reg_labels_test, flabels, rng, false);

            model_performance(model_num,:)=[trn_ME, tst_ME, mean(y_tst), std(y_tst)];
            
        end

        cv_model_performance{pt_t}= model_performance;

    end


% Compile results
cv_mat= cell2mat(cv_model_performance);
error= cv_mat(:,3:4:end)-(labels.(type))';  % predictions are in 3rd out of 4 columns per patient. 
reg_results_table= table(error,'RowNames', modelList);
reg_results_table.pcnt_error=reg_results_table.error/rng(2)*100;
reg_results_table.abs_mn_error_HD =  mean(abs(reg_results_table.error(:,HDPts)),2);
reg_results_table.abs_mn_error_HD_pcnt =  reg_results_table.abs_mn_error_HD/rng(2)*100;
reg_results_table.abs_mn_error_all= mean(abs(reg_results_table.error),2);
reg_results_table.abs_mn_error_all_pcnt= reg_results_table.abs_mn_error_all/rng(2)*100;

% Tabulate how often each feature was selected throughout cross validation
allfts= vertcat(cv_feats{:}); ufts= unique(allfts);
feat_freqs= cellfun(@(x) sum(ismember(allfts,x)), ufts);
[a, b]=sort(feat_freqs); 
ft_counts_table= table(ufts(b), a, 'VariableNames', {'Feature', 'count'});

save([dataDir,'/Results/' type, '.mat'],'cv_feats', 'cv_model_performance', 'type', ...
    'reg_results_table', 'ft_counts_table', 'rng')

fprintf('%s CV done\n', type)

end

%% Calculate Overall Model Score:

type= 'combined_subscores'; % type of UHDRS subscore to predict
load(fullfile(dataDir, 'Results', 'Binary_Classification.mat'))
load(fullfile(dataDir, 'Results', [type, '.mat'])) 

i_binmod= 1; % index of binary classifier model to use
i_regmod= 7; % index of regression model to use

missed= cellfun(@str2num, strsplit(bin_results_table.missed{i_binmod},' '));
FN= missed(ismember(missed, HDPts));        % index of false negatives
FP= missed(~ismember(missed, HDPts));       % index of false positives

totalScores=zeros(numPatients,1);
totalScores([HDPts, FP])= reg_results_table.error(i_regmod,unique([HDPts, FP]));
totalScores(FN)= cellfun(@(x) x(i_regmod, 3), cv_model_performance(FN)); 

final_error= mean(abs(totalScores));
final_error_pcnt= final_error/rng(2)*100;
percentile= [prctile(abs(totalScores),0), prctile(abs(totalScores),50), prctile(abs(totalScores),90)]/rng(2)*100;


fprintf(['Using the %s classifier and %s regression model to predict %s.\n',...
    'Mean error magnitude: %0.2f, normalized mean error: %0.2f%%\n'],...
bin_results_table.Properties.RowNames{i_binmod}, ...
reg_results_table.Properties.RowNames{i_regmod}, type, ...
final_error, final_error_pcnt)



