 function [selected_fts, selected_test_fts, fLabels] = selectFeats(allTrainFeats, allTestFeats,...
    train_labels, labelset, taskList, type, isbinary)

    % Binary Classification
    if isbinary
        disp('binomial LASSO')
        [B_gait, fitInfo] = lassoglm(allTrainFeats,train_labels,'binomial','CV',length(train_labels)-1);          
        % Find coeffs for best CV fit
        i_sft = find(B_gait(:, fitInfo.IndexMinDeviance));   % index of selected features
        if isempty(i_sft)                         % select new lambda if feature set empty
            ilambda=find(sum(B_gait~=0) > 0, 1, 'last'); 
            i_sft=find(B_gait(:,ilambda)); 
        end
    else  % Regression
        disp('normal LASSO')
        [B_gait, fitInfo] = lassoglm(allTrainFeats,train_labels,'normal','CV',5);
% Find coeffs for best CV fit
        i_sft = find(B_gait(:, fitInfo.IndexMinDeviance));   % index of selected features
        if isempty(i_sft)                         % select new lambda if feature set empty
            ilambda=find(sum(B_gait~=0) > 0, 1, 'last'); 
            i_sft=find(B_gait(:,ilambda)); 
        end
        
%         disp('fscmrmr')
%         [idx,scores] = fscmrmr(allTrainFeats,train_labels);
%         cs = cumsum(scores(idx));
%         i_sft = idx(cs < 0.85)';
%         if isempty(i_sft)
%             i_sft = idx(:);
%         end
            
        


    end


    
    
    selected_fts=allTrainFeats(:, i_sft);
    selected_test_fts= allTestFeats(:,i_sft); 
    
    % return label names and indices
    nl= numel(labelset);  
    %what does this line below do?
    task= ceil(i_sft/nl);                           % feature taskIndex
    
    label_suffix= labelset(i_sft-(task-1)*nl);
    fLabels=strcat(taskList(task)', label_suffix); 
    
    disp([type,' -- Number of Features Selected from LASSO = ',num2str(length(fLabels))])
    disp(fLabels)
     
end