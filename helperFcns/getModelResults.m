function [trn_out, tst_out, xtra, preds] = getModelResults(chosenModel, model_name, ...
     selected_fts, selected_test_fts, reg_labels, reg_labels_test, flabels, m_rng, isbinary)

% Get training and testing accuracies
yfit_trn= min(max(chosenModel.predictFcn(array2table(selected_fts, 'VariableNames', flabels')),...
    m_rng(1)), m_rng(2));


% Binary train and test accuracy, AUC
if isbinary
    [yfit_tst, scr]= chosenModel.predictFcn(array2table(selected_test_fts, 'VariableNames', flabels'));
    trn_out= sum(yfit_trn==reg_labels)/length(yfit_trn) * 100; 
    tst_out= sum(yfit_tst==reg_labels_test)/length(yfit_tst) * 100;
    preds=yfit_tst; 
    if length(reg_labels_test) > 1, [~,~,~,xtra]=perfcurve(reg_labels_test, scr(:,2), 1); 
    else, xtra=-1; end
    results={model_name, ['Train_acc: ',num2str(trn_out),'%' ], ['Tst_acc: ',num2str(tst_out),'%'], ['AUC: ',num2str(xtra)]};

% Regression mean error and correlations
else  
    yfit_tst= min(max(chosenModel.predictFcn(array2table(selected_test_fts, 'VariableNames', flabels')),...
        m_rng(1)), m_rng(2));
    trn_out = mean(abs(yfit_trn-reg_labels));
    tst_out = mean(abs(yfit_tst-reg_labels_test));
    preds=yfit_tst;  
    xtra= [corr(yfit_trn, reg_labels), corr(yfit_tst, reg_labels_test)];
    results={model_name, ['Train_ME: ',num2str(trn_out)], ['Tst_ME: ',num2str(tst_out)], ['trnCorr, tstCorr: ',num2str(xtra)]};
    
end 


end