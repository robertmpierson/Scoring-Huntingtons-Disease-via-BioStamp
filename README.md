# Scoring-Huntingtons-Disease-via-BioStamp

This code is associated with the research paper "Automatic Classification of Abnormal Movement in Huntington Disease Using Wearable Sensors."  The pipeline takes triaxial BioStamp data, extracts features, and trains both binary classifiers to identify symptomatic subjects, as well as regression models to predict UHDRS subscores. This code is publicly available for research purposes.  


## Getting Started

Update `settings.m` file with the filepath of the directory containing the raw data. The processed output will also appear in this directory.

Your data directory should contain one or more \<taskname\>_data.mat files containing matlab tables named "\<taskname\>_table" respectively. The table variable column names should include the following: 
* sensor type: either "Acc" or "Gyro" for accelerometer or gyroscopic data
* direction: either "X","Y", or "Z" 
* (optional): sensor name
* (optional): interval and number (e.g. Interval1, Interval2, ...). 

Each table row represents data collected from a single patient. 

e.g. Gait_data.mat: Gait_Table:
(example table header with two rows of patient data)

| AccX_S1_Raw_Interval1 | AccY_S1_Raw_Interval1 | AccZ_S1_Raw_Interval1 | AccX_S1_Raw_Interval2 | ... | AccZ_S3_Raw_Interval5 |
|-----------------------|-----------------------|-----------------------|-----------------------|-----|-----------------------|
| [336x1 double]        |[336x1 double]         |[336x1 double]         |[402x1 double]         | ... |[374x1 double]         |
| [521x1 double]        |[521x1 double]         |[521x1 double]         |[442x1 double]         | ... |[492x1 double]         |

The 'settings.m' file enables the user to set a number of parameters, to allow researchers to use our provided code during personalized experiments.  In this file, the user can set parameters such as the sampling rate (Hz), number of patients and number of signals.  We provided example data for running our code, in which there are 28 patients and 24 signals (3-axis data from 5 accelerometers and 3-axis data from 3 gyroscopes).  These parameters can be editted to accomodate personalized experiments, as sensors are added or removed from the system.  The 'settings.m' file also enables the user to set pre-processing butterworth filter parameters: the n-th order, as well as the highpass and lowpass frequency cutoffs.

Finally, the 'settings.m' file enables the user to control signal processing and analysis, via several binary toggles.  The user can control the inclusion of angular acceleration and angular displacement, derived from gyroscope angular velocity data.  The user can control the inclusion of velocity and displacement, derived from accelerometer accceleration data.  The user can use a binary toggle to include all features in their machine-learning, or use MATLAB's LASSO function to reduce the feature space.  The user can use a binary toggle to remove data from the beginning/end of datasets and, if so, how much data to remove.

## Running the Pipeline (TODO: update this section)
### Setup
- Run this section.  This section computes features on the input data, then splits the feature set into training and test sets. The size of the testing and training sets can be changed by updating the hold_out variable.  This variable indicates what fraction of the patients to exclude from the analysis and later use as the test set. Run this section to select features, patients, labels for training and cross validation.  Running this section will compile the following files: 'settings.m' and 'get_features.m'
  - Running 'settings.m' will load the sampling rate, number of patients, number of input signals, as well as the chosen method of pre-processing, feature extraction and feature selection.  
  - Running 'get_features.m' will 1) load data; 2) remove data from beginning/end; 3) filter the data; and 4) compute all features.  Tasks #1-3 are completed based off of the parameters previosuly set in the 'settings.m' file.

### Binary Classification
- Run the section.  This section selects the most useful features for binary classification by using Matlab's LASSO function.  It uses these features to build a binary classification model which predicts whether a patient is HD symptomatic or a healthy control. 

### Classification Testing Analysis
- Run this section.  This section compiles 'getModelResults.m' which calculates the testing and training accuracy and saves the results to spreadsheet, 'resultsTable.xlsx', which summarizes model performance metrics.

### Regression Models
- After binary classification determines the HD symptomatic patients, this section predicts the score for each of these patients in different categories of abnormal muscle movement.  In this section, you can select which category of abnormal muscle movement you would like to predict the score of.  Uncomment variables for the desired feature and label set, then run this section.
- Run this section.  This section selects the most useful features for scoring the selected abnormal muscle movement, by using Matlab's LASSO function.  It uses these features to build a regression model for predicting the score of the selected abnormal muscle movement.

### Regression Analysis
- Run this section.  This section compiles 'getModelResults.m' which calculates the testing and training accuracy and saves the results to spreadsheet, 'resultsTable.xlsx', which summarizes model performance metrics.

## Software Requirements
* [Matlab_R2017+](https://www.mathworks.com/products/matlab.html)
* Microsoft Excel

