function [featCell, featureLabels, d_combo] = getFullFeatureSet(clean_data, fs, frange, minpkdist)

    mat= table2array(clean_data);
     
    % We calculate feature rows
    featCell= cell(height(clean_data),1); 
    
    % Get features for each patient row 
    for pt = 1:height(clean_data)
        d= cell2mat(mat(pt,:));                 % matrix of patient data
          if mod(size(d,2), 3) ~=0, error('patient %d: incomplete xyz data'); end
             % Take l2 norm of x,y,z data for each sensor
             d_combo = cell2mat(arrayfun(@(x)vecnorm(d(:,3*(x-1)+(1:3))')', (1:size(d,2)/3), 'UniformOutput', false)); 
             ifs = d_combo;         

        % Add to feature list along with statistics features
        featCell{pt}= [ ...    
            cell2mat(cellfun(@(x)max(abs(x)), {ifs}, 'UniformOutput', false));...
            cell2mat(cellfun(@rms, {ifs}, 'UniformOutput', false)); ...
            cell2mat(cellfun(@std, {ifs}, 'UniformOutput', false)); ...
            getAmplitudeFeats(d_combo, minpkdist);...
            getBandpowerFeats(d_combo,fs, frange)'];  
    end
    
    % Assemble feature labels
    stat_labels = {'absmx', 'rms', 'std'};
    amp_labels = {'amp_mean','amp_max','amp_min','amp_std','reg_mean','reg_std'};
    bandp_labels = {'favg','flow','fmid','fhigh'};
    
    label_suffix = [ stat_labels, amp_labels, bandp_labels ]; 
    
    sensor_titles = clean_data.Properties.VariableNames(1:3:end);
    sensor_titles= cellfun(@(x)replace(x, 'AccelX', 'Acceleration'), sensor_titles, 'UniformOutput', false);
    sensor_titles= cellfun(@(x)replace(x, 'GyroX', 'AngularVelocity'), sensor_titles, 'UniformOutput', false);
    
    featureLabels= cellfun(@(x)strcat(sensor_titles, ['_',x]), label_suffix, 'UniformOutput', false);

