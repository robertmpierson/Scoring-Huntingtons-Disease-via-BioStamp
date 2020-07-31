% Get Features

run('settingsB.m')
addpath('helperFcns')

% Load feature data if it already exists
% if exist(fullfile(dataDir, featFilename),'file') > 0
%     fprintf('loading %s, delete and rerun to recompute\n', featFilename)
%     load(fullfile(dataDir, featFilename)); 
%     load(fullfile('rawData','labels.mat'));
%     disp('features loaded');
%     return;
% end

%%  Load data 
% load from all patients, save as .mat files in dataDir. If files
% already exist, load .mat files. 

disp('loading raw data')
[dataTables]= loadSensorData('rawData', taskList);
load(fullfile('rawData','labels.mat'))
disp('data loaded')


%%  Remove Time from beginning/end
disp('Trimming Data')
if remove_time == 1
    for i = 1:numPatients
        for j = 1:numSignals
            dataTables.Posture_raw{i,j}{1,1}=dataTables.Posture_raw{i,j}{1,1}(1+time_removed_postureANDsitting:end-time_removed_postureANDsitting,1);
            dataTables.Sitting_raw{i,j}{1,1}=dataTables.Sitting_raw{i,j}{1,1}(1+time_removed_postureANDsitting:end-time_removed_postureANDsitting,1);
            for k = 1:numIntervals
                dataTables.Gait_raw{i,j*k}(1+fs*time_removed_walking:end-fs*time_removed_walking,1);
            end
        end
    end
    disp('Data has been Trimmed')
end


%%  Filter data

disp('filtering data')
for task= taskList
    raw_data= dataTables.([task{1},'_raw']);
    [clean_data] = filterData(table2array(raw_data), fs, order, f_high, f_low);
    
    % Add cleaned data to dataTables
    dataTables.([task{1},'_clean'])= cell2table(clean_data, ...
        'VariableNames', raw_data.Properties.VariableNames);  
end

save(fullfile(dataDir,'dataTables.mat'), 'dataTables'); 
disp('Data has been filtered')

%% Segment Data
disp('segmenting gait data')
%for task= taskList
    task = taskList(3);
    dclean= dataTables.([task{1},'_clean']);
    [seg_mat,segmented_data, patientIDMap, ptNumSeg] = segmentData(table2array(dclean), wind, overlap, fs, numIntervals);

    % Add segmented data to dataTables
    dataTables.([task{1},'_segmat'])= cell2table(seg_mat', ...
        'VariableNames', raw_data.Properties.VariableNames);  
    % Add segmented data to dataTables
    dataTables.([task{1},'_segmented'])= cell2table(segmented_data, ...
        'VariableNames', raw_data.Properties.VariableNames);  
    
%end

save(fullfile(dataDir,'dataTables.mat'), 'dataTables'); 
disp('Data has been segmented')

%% Compute All Features
% Returns featureTables struct

disp('computing features')
featureTables=struct();
for task= taskList
    tic
    clean_data= dataTables.([task{1},'_clean']);
    numPts=height(clean_data);           
    
    % Get features for each Gait interval
    if strcmp(task{1}, 'Gait')
        clean_data = dataTables.([task{1},'_segmat']);
        %clean_data = dataTables.([task{1},'_clean']);
        names= clean_data.Properties.VariableNames;
        ftG = cell(1,numIntervals);
        for int = 1:numIntervals
            int_data= clean_data(:,contains(names,sprintf('Interval%d',int)));
            [ftG{int}, ~]= getFullFeatureSet2(int_data, fs, [f_high, f_low], minpkdist ,patientIDMap{int});  
            %[ftG, ~]= getFullFeatureSet(int_data, fs, [f_high, f_low], minpkdist);  
            %featureTables.Gait_Intervals(:,int) = ftG;
        end
        [ptList, ftIntv, n] = ptIDList(patientIDMap, ftG);
        % Aggregate Gait features across intervals
%         gi=featureTables.Gait_Intervals;
%         %ERROR HERE: Dimensions of arrays being concatenated are not consistent.
%         featureTables.Gait= arrayfun(@(pt)mean(cat(3,gi{pt,:}),3), ...
%             (1:numPts)', 'UniformOutput', false); 
        featureTables.Gait = ftIntv;
    else
        [featureTables.(task{1}), fl]= getFullFeatureSet(clean_data, fs, [f_high, f_low], minpkdist);
    end  
    toc
end

% Create array of feature labels to match feature structure
featureTables.labels=vertcat(fl{:});

save(fullfile(dataDir,featFilename), 'featureTables'); 
disp('features computed')
