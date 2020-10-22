function [selected_fts, selected_test_fts, fLabels] = selectFeats(allTrainFeats, allTestFeats,...
    train_labels, ftNames, ftSelMethod, isbinary)

ftNames= ftNames(:); % enforce as column vector

% %% LASSO FEATURE SELECTION %% %
    if strcmp(ftSelMethod, 'lasso')
    
        % Binary Classification
        if isbinary
            disp('binomial LASSO')
            [B_gait, fitInfo] = lassoglm(allTrainFeats,train_labels,'binomial','CV',length(train_labels)-1);          
        else  % Regression
            disp('normal LASSO')
            [B_gait, fitInfo] = lassoglm(allTrainFeats,train_labels,'normal','CV',length(train_labels)-1);
        end

        % Find coeffs for best CV fit
        i_sft = find(B_gait(:, fitInfo.IndexMinDeviance));   % index of selected features
        if isempty(i_sft)                         % select new lambda if feature set empty
            ilambda=find(sum(B_gait~=0) > 0, 1, 'last'); 
            i_sft=find(B_gait(:,ilambda)); 
        end
 
% %% SEQUENTIAL FEATURE SELECTION %% %
    elseif strcmp(ftSelMethod, 'sequential')
    
        Options.Display = 'iter'; 
        Options.UseParallel = false; %true; 
        keepout = false(1,312);        
        
        if isbinary % Binary
            disp('binomial sequential feature selection')
            fun = @(XT,yT,Xt,yt)mean((predict(...
                    fitcsvm(...
                        XT,yT,'KernelFunction', 'linear', 'PolynomialOrder', [], ...
                        'KernelScale', 'auto','Standardize', true, 'ClassNames', [0; 1]...
                        ),...
                    Xt)-yt).^2);
            
        else % Regression
            disp('regression sequential feature selection')
            fun = @(XT,yT,Xt,yt)loss(fitrgp(XT,yT, 'BasisFunction', 'constant',...
                    'KernelFunction', 'exponential','Standardize', true),Xt,yt);
        end
        
        i_sft =  sequentialfs(fun, allTrainFeats, train_labels, 'cv', length(train_labels)-1,...
            'Options', Options, 'Keepout', logical(keepout));           
    end
    
    selected_fts=allTrainFeats(:, i_sft);
    selected_test_fts= allTestFeats(:,i_sft); 
    
    fLabels= ftNames(i_sft);
    disp([' -- Number of Features Selected = ',num2str(length(fLabels))])
    disp(fLabels)
     
end