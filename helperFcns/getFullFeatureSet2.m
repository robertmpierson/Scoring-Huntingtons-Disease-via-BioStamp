function [featCell, featureLabels] = getFullFeatureSet2(clean_data, fs, frange, minpkdist ,ptID)
%FOR SEGMENTED GAIT FEATS

%getFullFeatureSet - assemble feature set for each patient with data the
%table clean_data
%
% Syntax: [featCell, featureLabels, d_combo] = getFullFeatureSet(clean_data, fs, frange, minpkdist)
%
% Inputs:
%    clean_data - A table containing vectors for each data signal, and
%    entries for  each patient. 
%    fs - data sampling rage
%    frange- frequency range endpoints for computing average frequency
%    minpkdist - minimum spacing between detected peaks, input to findpeaks
%    function
%
% Outputs:
%    featCell - a cell array containing a feature matrix for each patient
%    featureLabels- feature name lookup cell array

%------------- BEGIN CODE --------------
    numPatients = max(ptID);

    mat= table2array(clean_data);
    mat = reshape(cell2mat(mat), [], size(clean_data,2), size(cell2mat(table2array((clean_data(1,1)))),1));
     
    % We calculate feature rows
    featCell= cell(length(ptID),1);
    
    % Get features for each patient row 
    for pt = 1:length(ptID)
        d = squeeze(mat(pt,:,:))';
        %         d= cell2mat(temp);                 % matrix of patient data
        if mod(size(d,2), 3) ~=0, error('patient %d: incomplete xyz data'); end
        % Take l2 norm of x,y,z data for each sensor
        ifs = cell2mat(arrayfun(@(x)vecnorm(d(:,3*(x-1)+(1:3))')', (1:size(d,2)/3), 'UniformOutput', false)); 
        %d_combo = cell2mat(arrayfun(@(x)vecnorm(d(:,3*(x-1)+(1:3))')', (1:size(d,2)/3), 'UniformOutput', false));        
        ftC= [ ...    
        cell2mat(cellfun(@(x)max(abs(x)), {ifs}, 'UniformOutput', false));...
        cell2mat(cellfun(@rms, {ifs}, 'UniformOutput', false)); ...
        cell2mat(cellfun(@std, {ifs}, 'UniformOutput', false)); ...
        getAmplitudeFeats(ifs, minpkdist);...
        getBandpowerFeats(ifs,fs, frange)'];  
%         featCell{pt} = [featCell{pt};reshape(ftC, 1, [])];
        featCell{pt} = [featCell{pt};ftC]; %13*n x 8
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

