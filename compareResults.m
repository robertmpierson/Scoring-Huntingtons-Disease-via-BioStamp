%chose 4 of the HD patients to keep out of the training set. 
% 10 out of 14 used to train, and used for 5-fold CV acc
% 10 patients expanded was 221 patients
% patients in the hold out set: 2, 5, 7, 14
%used only expanded gait features
%labels= ['Classifier for gait subscores', 'Classifier for combined sub_scores', 'Classifier for combined sub_scores buckets of 10', 'Linear Regression for combined scores' ];
labels = categorical({'Classifier for gait subscores', 'Classifier for combined subscores', 'Classifier for combined subscores buckets of 10', 'Linear Regression for combined scores', 'Linear Regression for combined score buckets'});
CVacc =[.91, .887, .923, NaN, NaN]; %classifer 5 fold CV accuracy
TestAcc = [10 4;8 2 ;8 2; 0 1; 8 2]; %[x y] x is number of correct training predictions out of 10, y is number of correct testing predictions out of 4

figure(1)
bar(labels, CVacc);
title('5 fold CV Classifier accuracy of training patients')
ylabel('accuracy')
ylim([0.85,1])
grid on;

figure(2)
bar(labels, TestAcc, 'stacked');
title('# of correct testing predictions out of 4 patients, stacked on # of correct training predictions out of 10 patients')
ylabel('# of correct predictions')
grid on;

    

