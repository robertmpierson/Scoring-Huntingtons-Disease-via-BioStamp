% runPipeline
clear all

run('settings.m')
addpath('helperFcns')
 
%% 1) SETUP
% loads the raw data and computes a feature matrix for all subjects, then
% splits the matrix into testing and training sets for all patients, and HD
% patients, indexed by i_test, i_train, and i_testHD and i_trainHD
% respectively.

% Obtain/Load Feature Table
run('get_features.m')

% Split Training/Test sets
hold_out= .3;                                       % ratio from total data to hold as test set                                         

rng(11);                                            % Split data reproducibly                                              
Pts= (1:numPatients);
splt = cvpartition(numPatients,'HoldOut',hold_out);
i_test= Pts(splt.test); i_train= Pts(~splt.test);   % All training & testing set idx     

% Obtain labels, 0- healthy control, 1- HD patient
labels_PtStatus = labels{i_train,1};
labels_PtStatus_test = labels{i_test,1};

i_testHD = i_test(logical(labels_PtStatus_test));    % HD Testing set idx 
i_trainHD = i_train(logical(labels_PtStatus));       % HD Training set idx 

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
    
    disp('Features aggregated')
    
    % compile & normalize training/test set features for all subjects
    trn_mn= mean(features_all(i_train,:)); trn_std=std(features_all(i_train,:));
    features= normalize(features_all(i_train,:));                % all training set features
    features_test = (features_all(i_test,:)-trn_mn)./trn_std;    % all test set features
    
     % compile & normalize training/test set features for HD patients only
    trn_mnHD= mean(features_all(i_trainHD,:)); trn_stdHD=std(features_all(i_trainHD,:));
    featuresHD= normalize(features_all(i_trainHD,:));        
    featuresHD_test = (features_all(i_testHD,:)-trn_mnHD)./trn_stdHD; 
    
    nFts=numel(featureTables.labels);
    
    disp('Features have been Normalized')
    
    save([dataDir, '/split_features.mat'], 'features', 'features_test', 'featuresHD', 'featuresHD_test');
    

%% 2) BINARY CLASSIFICATION 

type = 'Binary_Classification';

disp('Selecting Features...')
[selected_fts, selected_test_fts, flabels]= selectFeats(features,features_test, ...
    labels_PtStatus, labels_PtStatus_test, featureTables.labels, taskList, ...
    type, dataDir, true);

classifier_application_app_Mx = array2table([selected_fts,labels_PtStatus], ...
    'VariableNames', [flabels','predictor']);

disp('Training Classifiers ...')
[binary_class_models, modelList, validationAccuracies] = trainClassifiers(classifier_application_app_Mx);

disp('Tabulating results ...')
for model_num= 1:length(modelList)
    chosenModel= binary_class_models{model_num};
    model_name= chosenModel.model_name; 

    % This function calculates testing and training accuracy, and saves to
    % excel file in dataDir
    [trn_acc, tst_acc, AUC] = getModelResults(chosenModel, model_name, model_num,...
    'Binary_Classification', selected_fts, selected_test_fts, ...
    labels_PtStatus, labels_PtStatus_test, flabels, [0,1], dataDir, true);
end

save([dataDir, '/Models/Binary_Classification.mat'], 'binary_class_models', ...
    'selected_fts', 'selected_test_fts', 'labels_PtStatus',...
    'labels_PtStatus_test', 'flabels', 'classifier_application_app_Mx')
 
disp('Binary Classification Done')
%% 2) REGRESSION MODELS

% Instructions: 
% Uncomment desired feature set and run this section. 

% GAIT ANALYSIS % % 
% type= 'Gait_Regression'
% reg_features = featuresHD; %(:,2/3*size(featuresHD,2)+1:end);
% reg_features_test = featuresHD_test; %(:,2/3* size(featuresHD,2)+1:end);
% labelset=featureTables.labels;
% reg_labels = labels{i_trainHD,22};
% reg_labels_test = labels{i_testHD,22};
% rng = [0,4];

% % TANDEM GAIT ANALYSIS % % 
% type= 'Tandem Gait_Regression'
% reg_features = featuresHD; %(:,2/3*size(featuresHD,2)+1:end);
% reg_features_test = featuresHD_test %(:,2/3* size(featuresHD,2)+1:end);
% reg_labels = labels{i_trainHD,23};
% reg_labels_test = labels{i_testHD,23};
% rng = [0,4];

% ARM RIGIDITY % % 
% type= 'RArm_Rigidity_Regression',
% iFts= find(contains(featureTables.labels, 'Rforearm'))+[0,104,208];
% reg_features = featuresHD(:,iFts);
% reg_features_test = featuresHD_test(:,iFts); 
% reg_labels = labels{i_trainHD,18};
% reg_labels_test = labels{i_testHD,18};
% labelset=featureTables.labels(iFts(:,1));
% rng = [0,4];

% type= 'LArm_Rigidity_Regression',
% iFts= find(contains(featureTables.labels, 'Lforearm'))+[0,104,208];
% reg_features = featuresHD(:,iFts);
% reg_features_test = featuresHD_test(:,iFts); 
% reg_labels = labels{i_trainHD,19};
% reg_labels_test = labels{i_testHD,19};
% labelset=featureTables.labels(iFts(:,1));
% rng = [0,4];

% % FINGER TAPS % % 
% type= 'Finger_Taps_Regression_right'
% % Get all Rforearm fts across 3 tasks
% iFts= find(contains(featureTables.labels, 'Rforearm'))+(0:2)*nFts; 
% reg_features = featuresHD(:,iFts); 
% reg_features_test = featuresHD_test(:,iFts); 
% reg_labels = labels{i_trainHD,14};
% reg_labels_test = labels{i_testHD,14};
% labelset=featureTables.labels(iFts(:,1));
% rng = [0,4];

% type= 'Finger_Taps_Regression_left'
% % Get all Rforearm fts across 3 tasks
% iFts= find(contains(featureTables.labels, 'Lforearm'))+(0:2)*nFts; 
% reg_features = featuresHD(:,iFts); 
% reg_features_test = featuresHD_test(:,iFts); 
% reg_labels = labels{i_trainHD,15};
% reg_labels_test = labels{i_testHD,15};
% labelset=featureTables.labels(iFts(:,1));
% rng = [0,4];

% % DYSTONIA % % 
% type= 'Dystonia_Regression'
% reg_features = featuresHD
% reg_features_test = featuresHD_test 
% reg_labels = labels{i_trainHD,11};
% reg_labels_test = labels{i_testHD,11};
% labelset=featureTables.labels
% rng = [0,20];


% CHOREA % % 
% type= 'Chorea_Regression'
% reg_features = featuresHD
% reg_features_test = featuresHD_test
% reg_labels = labels{i_trainHD,12};
% reg_labels_test = labels{i_testHD,12};
% labelset=featureTables.labels
% rng = [0,28];

% BRADYKENESIA % % 
% type= 'Bradykenesia_Regression'
% reg_features = featuresHD
% reg_features_test = featuresHD_test
% reg_labels = labels{i_trainHD,21};
% reg_labels_test = labels{i_testHD,21};
% labelset=featureTables.labels
% rng = [0,4];

% ALL THE ABOVE
% type= 'All_selected_subscores'
% reg_features = featuresHD
% reg_features_test = featuresHD_test
% reg_labels = sum(labels{i_trainHD,[11,12,15,19,21,22,23]},2);
% reg_labels_test = sum(labels{i_testHD,[11,12,15,19,21,22,23]},2);
% labelset= featureTables.labels
% rng = [0,80];

disp('Selecting Features...')
[selected_fts, selected_test_fts, flabels]= selectFeats(reg_features,reg_features_test, ...
    reg_labels, reg_labels_test, labelset, taskList, type, dataDir, false);

disp('Training Classifiers ...')
regressionlearner_mx= array2table([selected_fts, reg_labels], 'VariableNames', [flabels', 'predictor']);
[class_models, modelList, validationRMSE] = trainRegressionModels(regressionlearner_mx);
  
disp('Tabulating results ...')
for model_num= 1:length(modelList)
    chosenModel= class_models{model_num};
    model_name= chosenModel.model_name;

    % This function calculates testing and training accuracy, and saves to
    % excel file in dataDir
    [trn_ME, tst_ME, trntst_corrs] = getModelResults(chosenModel, ...
        model_name, model_num, type, selected_fts, selected_test_fts, reg_labels,...
        reg_labels_test, flabels, rng, dataDir, false)
end

save([dataDir,'/Models/' type, '.mat'],'selected_fts', 'selected_test_fts',...
    'reg_labels', 'reg_labels_test', 'flabels', 'regressionlearner_mx', 'class_models')
