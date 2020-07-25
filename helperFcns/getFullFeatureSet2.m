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
     
    % We calculate feature rows
    featCell= cell(numPatients,1);
    
    % Get features for each patient row 
    for pt = 1:numPatients
        d = mat(pt,:);
%         d= cell2mat(temp);                 % matrix of patient data
          if mod(size(d,2), 3) ~=0, error('patient %d: incomplete xyz data'); end
             % Take l2 norm of x,y,z data for each sensor
             %TODO change next line to go over the cells
             ifs = cell(1,length(d)/3);
             for vec = 1:length(d)/3
                 temp = d((vec-1)*3+1:vec*3);
                 ll = length(temp{1});
                 temp = cell2mat(temp);
                 temp = reshape(temp,[],3);
                 temp = vecnorm(temp,2,2);
                 temp = reshape(temp, ll,[]);
                 ifs{vec} = temp;
             end
             %d_combo = cell2mat(arrayfun(@(x)vecnorm(d(:,3*(x-1)+(1:3))')', (1:size(d,2)/3), 'UniformOutput', false));        
        for c = 1:size(ifs{1},2)
            m = cellfun(@(x)x(:,c), ifs, 'UniformOutput', false) ;   
            m = cell2mat(m);
            % Add to feature list along with statistics features
            fc= [ ...  
                cell2mat(cellfun(@(x)max(abs(x)), {m}, 'UniformOutput', false));...
                cell2mat(cellfun(@rms, {m}, 'UniformOutput', false)); ...
                cell2mat(cellfun(@std, {m}, 'UniformOutput', false)); ...
                getAmplitudeFeats(m, minpkdist);...
                getBandpowerFeats(m,fs, frange)'];
            featCell{pt} = [featCell{pt}, fc];
        end
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

