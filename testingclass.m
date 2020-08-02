clear rng;
load('/Users/inbartivon/Downloads/HD Litt Lab/Data/labels.mat');
labels = repelem(labels, n,1);
nl = load('/Users/inbartivon/Downloads/HD Litt Lab/Data/labels.mat');
nl = nl.labels;
rng(6);
labels.combined_subscores = sum(labels{:,[11,12,20,21,22,23]},2); 
edges = 0:10:80;
labels.combined_subscores = discretize(labels.combined_subscores, edges);
nl.combined_subscores = sum(nl{:,[11,12,20,21,22,23]},2); 
nl.combined_subscores = discretize(nl.combined_subscores, edges);
hdpts28 = find(nl.PtStatus == 1);
pt_test = randsample(hdpts28, 4); %random take only from HD patients
idx = ~ismember(ptList, pt_test)' & labels.PtStatus; % choose non test patients that are HD patients
% testG2 = [features_all(idx,:),...
%     labels{idx,22}+labels{idx,23}];

testG = [features_all(idx,:),...
labels{idx,24}];

yfit2 = trainedModel.predictFcn(features_all);
predt2 = arrayfun(@(x)mean(yfit2(ptList==x)), 1:28);
predt2 = predt2(nl.PtStatus == 1)

%nlG2 = (nl.TandemGait(nl.PtStatus == 1) + nl.Gait(nl.PtStatus == 1))'

nlG2 = nl.combined_subscores(nl.PtStatus == 1)'

round(predt2)