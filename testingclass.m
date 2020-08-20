%compare actual labels vs predictions
clear rng;
load('/Users/inbartivon/Downloads/HD Litt Lab/Data/labels.mat');
%labels = repelem(labels, n_sit,1);
labels = [repelem(labels, n_sit,1);repelem(labels, n,1)];
nl = load('/Users/inbartivon/Downloads/HD Litt Lab/Data/labels.mat');
nl = nl.labels;
rng(6);
labels.combined_subscores = sum(labels{:,[11,12,20,21,22,23]},2); 
%edges = 0:10:80;
% labels.combined_subscores = discretize(labels.combined_subscores, edges);
nl.combined_subscores = sum(nl{:,[11,12,20,21,22,23]},2); 
% nl.combined_subscores = discretize(nl.combined_subscores, edges);
hdpts28 = find(nl.PtStatus == 1);
pt_test = 2; %random take only from HD patients
% idx = ~ismember(ptList_sit, pt_test)' & labels.PtStatus; % choose non test patients that are HD patients
% features_all = [featureTables.Sitting,featureTables.Gait] ;
ptL = [ptList_sit, ptList];
idx = ~ismember(ptL, pt_test)' & labels.PtStatus; % choose non test patients that are HD patients
features_all = [featureTables.Sitting;featureTables.Gait] ;

testG2 = [features_all(idx,:),...
    labels{idx,22}+labels{idx,23}];


testG = [features_all(idx,:),...
labels{idx,24}];

yfit2 = trainedModel7.predictFcn(features_all); %can replace model with anything from regression learner app
predt2 = arrayfun(@(x)mean(yfit2(ptL==x)), 1:28);
predt2 = predt2(nl.PtStatus == 1)

%nlG2 = (nl.TandemGait(nl.PtStatus == 1) + nl.Gait(nl.PtStatus == 1))'

nlG2 = nl.combined_subscores(nl.PtStatus == 1)'

round(predt2)

sum(nlG2(pt_test) == rp(pt_test))
sum(nlG2(:) == rp(:))
%sort scores, scatterplot
figure(1)
clf
[m, i] = sort(nlG2(pt_test));
scatter(1:length(pt_test), m)
hold on;
p = predt2(pt_test);
scatter(1:length(pt_test),p(i))
legend('true', 'pred');

figure(2)
clf
[m, i] = sort(nlG2(:));
scatter(1:14, m)
hold on;
p = predt2(:);
scatter(1:14,p(i))
legend('true', 'pred');

