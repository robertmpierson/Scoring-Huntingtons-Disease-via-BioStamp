%% Feature Analysis

% Things to try: 
% - Inspect Features with different windowed segments
% - Remove highly correlated features
% - Remove low variance features 
% - Partition scores into ranges of 10 points, and instead treat this as a
% classificaiton problem instead of a regression problem
% 


percentRank = @(YourArray, TheProbes) reshape( mean( bsxfun(@le,...
    YourArray(:), TheProbes(:).') ) * 100, size(TheProbes) );


%% Look at feature Variance: 

% Run run_pipeline to get feature variance, then play around with it:

ftvar = var(features_all);
[s, ii] = sort(ftvar);
ftNames(ii)'

histogram(log(ftvar))

%% Look at feature correlation

cfts = corr(features_all);
bincfts = abs(cfts) >= .7; % binarize correlation matrix

[s, ii] = sort(sum(bincfts));
ftNames(ii(1:20))'; 

imagesc(cfts)
imagesc(abs(cfts))

imagesc(bincfts)

histogram(percentRank(ftvar, ftvar(ii(1:20))), 10)

%% Inspect how feature values differ between subjects

rng(10); 

% NOTE: didn't separate training/testing
zscrfts= zscore(features_all);

figure(1); imagesc(zscrfts(HDPts, :))
figure(2); imagesc(zscrfts(CtrPts, :))

figure(3); imagesc([mean(zscrfts(HDPts, :)); mean(zscrfts(CtrPts, :))])
figure(4); imagesc([median(zscrfts(HDPts, :)); median(zscrfts(CtrPts, :))])



