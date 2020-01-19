function [dataTables]=loadSensorData(dataDir, taskList)
%loadSensorData -load data tables and UHDRS score labels from pre-existing .mat files
%
% Syntax:  [dataTables] = loadSensorData(dataDir,outputDir, taskList, sensorList)
%
% Inputs:
%    dataDir - directory containing folders labeled by patient ID (i.e Patient_1, Patient_2)
%    taskList - list of task names found in annotation file Ex. {'Posture', 'Gait'}
%
% Outputs:
%    dataTables - cell array of datatables corresponding to each task

%------------- BEGIN CODE --------------

dataTables={};

for task= taskList
    df= fullfile(dataDir,sprintf('%s_data.mat',task{1})); 
    if exist(df, 'file') > 0
        dt= load(fullfile(dataDir,sprintf('%s_data.mat',task{1})));
        dataTables.(sprintf('%s_raw',task{1}))= dt.(sprintf('%s_table',task{1}));
    end
end

if length(fieldnames(dataTables))== length(taskList)
    return; 
else; dataTables={}; 
end


end
