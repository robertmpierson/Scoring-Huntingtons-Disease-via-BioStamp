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

## Running the Pipeline (TODO: update this section)
### Setup
- This section computes features on the input data, then splits the feature set into training and test sets. The size of the testing and training sets can be changed by updating the hold_out variable. 
- Run the section 

### Binary Classification
- Run the section
- A tab will be added to the "resultsTable.xlsx" file with model performance metrics. 

### Regression
- Uncomment variables for the desired feature and label set. 
- Run the section
- A tab will be added to the "resultsTable.xlsx" file with model performance metrics. 

## Software Requirements

* [Matlab_R2017+](https://www.mathworks.com/products/matlab.html)
* Microsoft Excel

