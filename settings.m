% HD Pipeline Settings

% Data Loading
dataDir = 'Data';
taskList= {'Posture', 'Sitting', 'Gait'};
numIntervals = 5;  % Number of Gait intervals

sensorList= {'Lforearm', 'Rforearm', 'sacrum', 'Lthigh', 'Rthigh'};
  
fs= 62.5; % sample rate
numPatients = 28;
numSignals = 24;

% dataProcessing 
order = 5;     % Filter order
f_high = 1;    % highpass cutoff
f_low = 16;    % lowpass cutoff

% Feature file
featFilename= 'fullFeatures.mat';   % feature filename to create/load from 'dataDir'
minpkdist= 25;                      % min distance b/w signal peaks for amp feature set

% Include LASSO
include_lasso = 1;

% Remove Data from Beginning/End
remove_time = 1;
time_removed_walking = round(0*fs); % 2 seconds % time already removed while removing turns
time_removed_postureANDsitting = round(5*fs); % 5 seconds

