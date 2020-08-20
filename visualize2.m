%%use this to plot Full Model composite subscore prediction
figure(1); clf; hold all
load('rawData/labels.mat');
labels.combined_subscores=sum(labels{:,[11,12,15,20,21,22,23]},2); 

load('/Users/inbartivon/Downloads/HD Litt Lab/DATA2/Results/combined_subscores.mat', 'cv_model_performance');
[srtscr, srtind]=sort(labels.combined_subscores');

plot([1:length(labels.combined_subscores)], srtscr, '.', 'markersize', 20 )
hold on;
i_binmod= 1; % index of binary classifier model to use
i_regmod= 7; % index of regression model to use

missed= cellfun(@str2num, strsplit(bin_results_table.missed{i_binmod},' '));
FN= missed(ismember(missed, HDPts));        % index of false negatives
FP= missed(~ismember(missed, HDPts));  

ts = zeros(1,28);
for i = 1: length(cv_model_performance)
    if ismember(i, HDPts) | ismember(i, FP)  %should include the one wrong classification
        c = cv_model_performance{i};
        ts(i) = c(7,3);
    end
end
plot([1:length(labels.combined_subscores)], ts(srtind), '.', 'markersize', 20 )
t = ts(srtind);
for j = 1:length(labels.combined_subscores)

    plot([j,j],[srtscr(j),t(j)] ,'k')
end
legend('True score', 'Predicted Score');
xlabel('Patients')
xticklabels('')
ylabel('Composite Score')
%title('Full Model composite subscore prediction') 
set(gca, 'XTick', [])
grid on
title('Composite Score using Expanded Sitting Features'); 
ylim([-5, 50])