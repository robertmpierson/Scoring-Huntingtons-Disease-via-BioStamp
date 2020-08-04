%% Tabulate Results

dd=dir('Data/Results/*.mat');
load('rawData/labels.mat')

run('settings.m')
addpath(genpath('helperFcns'))
 
Pts= (1:numPatients);
HDPts= Pts(logical(labels.PtStatus));
CtrlPts = Pts(~logical(labels.PtStatus));

cols=[[69, 124, 214]; [190,8,4]; [140,42,195];[75,184,166];[242,224,43];[74,156,85];...
   [80,80,80]; [255,255,255]]/255;

labels.combined_subscores=sum(labels{:,[11,12,15,20,21,22,23]},2); 

%% Get characteristics of Dataset

% Distribution of labels
figure(1); clf;
histogram(labels.combined_subscores)

% Display Raw Data, select task and sensor
task= taskList{3}; sensor= 'S3'; 

figure(1); clf; 
plotRawData(dataTables, 'clean', task, sensor, HDPts(1:end/2))

figure(2); clf;
plotRawData(dataTables, 'clean', task, sensor, CtrlPts(1:end/2))

%% Figure for paper, control vs. HD patient

rms_func = @(dd) sqrt(sum(cell2mat(dd)'.^2)); 
figure(30); clf; 
subplot(3,1,1); hold on
dd= dataTables.Posture_clean{1,1:3};
plot(rms_func(dd))
dd= dataTables.Posture_clean{6,1:3};
plot(rms_func(dd))
xticks('')
title('Posture', 'fontsize', 13)

subplot(312); hold on
dd= dataTables.Sitting_clean{1,1:3};
plot(rms_func(dd))
dd= dataTables.Sitting_clean{6,1:3};
plot(rms_func(dd))
title('Sitting', 'fontsize', 13)
xticks('')

subplot(313); hold on
dd= dataTables.Gait_clean{1,1:3};
plot([1:length(dd{1})]/fs, rms_func(dd))
dd= dataTables.Gait_clean{6,1:3};
plot([1:length(dd{1})]/fs, rms_func(dd))
title('Gait', 'fontsize', 13)
xlabel('Time', 'fontsize', 13)

legend('HD Symptomatic','Control')


%% Plot Error Distribution for all models

figure(3); clf; hold on
figure(4); clf; hold on

% subscore results
subscore_results=table(); 
mods= [2,3,7]; % select which models we want
clear all_ft_counts
sortedScore = table();
sortedScoreHD = table();

sigDiffs=table();

comboscore=0;

i_mat=1; 
for name= {dd.name}
    load(sprintf('Data/Results/%s', name{1}))
    
    if any(strcmp(type, {'binary', 'Rigidity_RIGHTArm', 'FingerTaps_RIGHT'}))
        continue
    end
    
    if ~strcmp(type, 'combined_subscores')
        comboscore= comboscore+ reg_results_table.error(mods,:)+labels.(type)(:)';
    end 

    xval=[(1:length(mods))', .3+(1:length(mods))']./4.5+i_mat;
    
    x= repmat(mean(xval,2)',length(HDPts),1)+normrnd(0,.02,length(HDPts), ...
        length(mods)); 
    y1= reg_results_table.pcnt_error(mods,HDPts)';
    y2= abs(reg_results_table.pcnt_error(mods,HDPts)');
    
    figure(3); %clf; hold on
    h=plot(x, y1, 'o', 'markersize', 5)
    set(h, {'Color'}, {cols(1,:); cols(2,:); cols(3,:)});
    plot(xval'+[-.06; .06], [mean(reg_results_table.pcnt_error(mods,HDPts),2),mean(reg_results_table.pcnt_error(mods,HDPts),2)]', 'black')
    xticklabels(reg_results_table.Properties.RowNames(mods))
    xticks([1:length(mods)])
    xtickangle(45)
    title(sprintf('raw error: %s', type))
    legend(reg_results_table.Properties.RowNames(mods))
    
    
    figure(4);hold on
    h2=plot(x,y2, 'o', 'markersize', 5)
    set(h2, {'Color'}, {cols(1,:); cols(2,:); cols(3,:)});
    plot(xval'+[-.06; .06],...
        [reg_results_table.abs_mn_error_HD_pcnt(mods),reg_results_table.abs_mn_error_HD_pcnt(mods)]', 'black')
    xticklabels(reg_results_table.Properties.RowNames(mods))
    xticks([1:length(mods)])
    xtickangle(45)
    title('absolute error')
    legend(reg_results_table.Properties.RowNames(mods))
     
    subscore_results.(type)= reg_results_table.abs_mn_error_HD_pcnt;
    
    % Tabulate how often each feature was selected throughout cross validation
    HD_fts= cv_feats(HDPts);
    allfts= vertcat(HD_fts{:}); ufts= unique(allfts);
    feat_freqs= cellfun(@(x) sum(ismember(allfts,x)), ufts);
    [a, b]=sort(feat_freqs); 
    all_ft_counts.(type)= table(ufts(b), a, 'VariableNames', {'Feature', 'count'});
    
    [srt,pt]=sort(abs(reg_results_table.pcnt_error(mods,HDPts))', 'descend');
    sortedScoreHD.(type)=[HDPts(pt);srt];
    sortedScore.(type)=reg_results_table.pcnt_error(:,HDPts)
    
    for md1=1:length(mods)
        for md2=md1:length(mods)
        sig_diff(md1,md2)= [signrank(abs(sortedScore.(type)(mods(md1),:)), ...
            abs(sortedScore.(type)(mods(md2),:)))];
        end
    end
    
    sigDiffs.(type)= sig_diff; 
    
    i_mat=i_mat+1;
end

xticks([1:8]+.5)
xticklabels({'Gait', 'TandemGait', 'Rigidity_LEFTArm', ...
    'FingerTaps_LEFT',...
    'MaximalDystonia_trunkAnd4Extremities_',...
    'MaximalChorea_face_Mouth_Trunk_And4Extremities_', ...
    'Bradykinesia_body_', ...
    'combined_subscores'});

subscore_results.Properties.RowNames=reg_results_table.Properties.RowNames;
sortedScore.Properties.RowNames=reg_results_table.Properties.RowNames;

figure(1); clf; hold on
bar(table2array(subscore_results(mods,:))')
xticklabels(subscore_results.Properties.VariableNames)
xtickangle(45)

legend(reg_results_table.Properties.RowNames(mods))

% Compare sum of a patient's scores as combined subscore prediction
cscr= comboscore-labels.combined_subscores';
[mean(abs(cscr(:,HDPts)),2), std(abs(cscr(:,HDPts)),[],2)]./.8
prctile(abs(cscr(:,HDPts)./.8), [25 50 75],2)

% Get percentiles of single composite model
prctile(abs(reg_results_table.error(i_regmod,HDPts)/.8), [25 50 75],2)

%     for md1=1:length(mods)
%         for md2=md1:length(mods)
%         sig_diff(md1,md2)=signrank(abs(cscr(md1,:)), abs(sortedScore.combined_subscores(mods(md2),:)));
%         end
%     end

%% Calculate Overall Score:

load('Data/Results/Binary_Classification.mat')
load('Data/Results/combined_subscores.mat')

i_binmod=1;
i_regmod=7;

missed= cellfun(@str2num, strsplit(bin_results_table.missed{i_binmod},' '))
FN= ismember(HDPts, missed) 

fullError=zeros(28,1);
fullError([HDPts, missed])= reg_results_table.error(i_regmod,unique([HDPts, missed]));
fullError(FN)=0; 

final_error= mean(abs(fullError))
final_error_pcnt= mean(abs(fullError))./rng(2)

prctile(abs(reg_results_table.error(i_regmod,HDPts)/.8), [25 50 75],2)

fprintf(['Using the %s classifier and %s regression model to predict %s.\n',...
    'Mean error magnitude: %0.2f, normalized mean error: %0.2f%%\n'],...
bin_results_table.Properties.RowNames{i_binmod}, ...
reg_results_table.Properties.RowNames{i_regmod}, type, ...
final_error, final_error_pcnt*100)

%% Full Model combined scores

figure(1); clf; hold all
[srtscr, srtind]=sort(labels.combined_subscores');

comboError=zeros(28,1);
comboError([HDPts, missed])=cscr([HDPts, missed])

for d= 1:length(fullError)
    plot([d,d], [srtscr(d), fullError(srtind(d))'+srtscr(d)], 'black', ...
        'linewidth', 1, 'HandleVisibility','off')
    
%     plot([d,d], [srtscr(d),  comboError(srtind(d))'+srtscr(d)], 'black', ...
%         'linewidth', 1, 'HandleVisibility','off')
end

plot([1:length(fullError)], srtscr, '.', 'markersize', 20 )
plot([1:length(fullError)], fullError(srtind)'+srtscr, '.', 'markersize', 20 )
%plot([1:length(fullError)], comboError(srtind)'+srtscr, '.', 'markersize', 20)

legend({'True score', 'Predicted Score'}, 'location', 'best')
xlabel('Patients')
xticklabels('')
ylabel('Composite Score')
%title('Full Model composite subscore prediction') 
set(gca, 'XTick', [])
grid on

ylim([-5, 50])

% saveas(gcf,'/Users/bscheid/MATLAB-Drive/Final HD/figures/figures_V2/fullModScores.png')
% saveas(gcf,'/Users/bscheid/MATLAB-Drive/Final HD/figures/figures_V2/fullModScores.fig')


%% Total Score Correlation

figure(3); clf; hold on
plot([1:length(fullError([HDPts, missed]))], srtscr(ismember(srtind, [HDPts, missed])), '.', 'markersize', 20 )
plot([1:length(fullError([HDPts, missed]))], ...
    comboError(srtind(ismember(srtind, [HDPts, missed])))'+srtscr(ismember(srtind, [HDPts, missed])), '.', 'markersize', 20 )

[r,p]=corr(srtscr(ismember(srtind, [HDPts, missed]))',...
    comboError(srtind(ismember(srtind, [HDPts, missed])))+srtscr(ismember(srtind, [HDPts, missed]))')