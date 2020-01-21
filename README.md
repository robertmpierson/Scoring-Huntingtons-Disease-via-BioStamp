# Scoring-Huntingtons-Disease-via-BioStamp

This code is associated with the research paper "Automatic classification of tremor severity in Huntington's disease."  The pipeline takes triaxial BioStamp data, extracts features, and trains both binary classifiers to identify symptomatic subjects, as well as regression models to predict UHDRS subscores. This code is publicly available for research purposes.  


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


The 'settings.m' file enables the user to set a number of parameters, to allow researchers to use our provided code during personalized experiments.  In this file, the user can set parameters such as the sampling rate (Hz), number of patients and number of signals.  We provided data for running our code, in which there are 28 patients and 24 signals (3-axis data from 5 accelerometers and 3-axis data from 3 gyroscopes).  These parameters can be editted to accomodate personalized experiments, as sensors are added or removed from the system.  The 'settings.m' file also enables the user to set pre-processing butterworth filter parameters: the n-th order, as well as the highpass and lowpass frequency cutoffs.

Finally, the 'settings.m' file enables the user to control signal processing and analysis, via a number of binary toggles.  The user can control the inclusion of angular acceleration and angular displacement, derived from gyroscope angular velocity data.  The user can control the inclusion of velocity and displacement, derived from accelerometer accceleration data.  The user can use a binary toggle to include all features in their machine-learning, or use MATLAB's LASSO function to reduce the feature space.  The user can use a binary toggle to remove data from the beginning/end of datasets and, if so, how much data to remove.

## Running the Pipeline (TODO: update this section)
### Setup
- This section computes features on the input data, then splits the feature set into training and test sets. The size of the testing and training sets can be changed by updating the hold_out variable. 
- Run 'settings.m'
- add helper function in the 'helperFcns' folder to path
- Run 'get_features.m'
- Select Features, Patients, Labels for Training and Cross Validation

### Binary Classification
- Run the section
- Binary classification on HD patients vs Control patients
- A tab will be added to the "resultsTable.xlsx" file with model performance metrics. 

### Regression Models
- Uncomment variables for the desired feature and label set. 
- Run the section
- A tab will be added to the "resultsTable.xlsx" file with model performance metrics. 

### Regression Analysis
- 

## Software Requirements

* [Matlab_R2017+](https://www.mathworks.com/products/matlab.html)
* Microsoft Excel

