figure(1); clf; hold all
load('rawData/labels.mat');
labels.combined_subscores=sum(labels{:,[11,12,15,20,21,22,23]},2); 

load('/Users/inbartivon/Downloads/HD Litt Lab/DATA1/Results/combined_subscores.mat', 'cv_model_performance');
[srtscr, srtind]=sort(labels.combined_subscores');

plot([1:length(labels.combined_subscores)], srtscr, '.', 'markersize', 20 )
hold on;
ts = zeros(1,28);
for i = 1: length(cv_model_performance)
    if ismember(i, HDPts) %should include the one wrong classification
        c = cv_model_performance{i};
        ts(i) = c(7,3);
    end
end
plot([1:length(labels.combined_subscores)], ts(srtind), '.', 'markersize', 20 )

legend({'True score', 'Predicted Score'}, 'location', 'best')
xlabel('Patients')
xticklabels('')
ylabel('Composite Score')
%title('Full Model composite subscore prediction') 
set(gca, 'XTick', [])
grid on

ylim([-5, 50])