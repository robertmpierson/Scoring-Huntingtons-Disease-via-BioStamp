line 150 in runpipeline changed to just use combines subscores
also removed finger taps

line 176 discretize into bins of 10


line 180 % instead of 312, input 100 features that have high variance and low ...
    %correlation with each other
    
change selectFts , replace lasso

used classifer app to make new code
TODO - update it to match previous code
commented out model performance

tried using fscmrmr, not sure how many to keep


Turn into categorical labels instead of 1 2 3 4 

try top ten var , no lasso
    
fscmrmr better for larger datasets

(try windowed feats!) in getFeatures
    
 
--> use lasso again
diff model? var/low corr

segment data function
for every patient: save numwins,
    pt1 has 4 windows
    running vector patient ID map
    patientIDMap =  [patientIDMap, i*ones(numwin,1)]
    
    103x120 where i can map 1:4 to patient 1

-----
7/28
only use gait data:
turn every window segment into a new patient
features_all = 582x104

if repeating posture/sitting then 582*312
    
see repelm: can do the same for their scores
    
7/30
    
labels.combined_subscores = sum(labels{:,[11,12,20,21,22,23]},2);
newlabels = repelem(labels.combined_subscores, n);
features_all =  [ftIntv, newlabels];
    
7/31
rather than end up with 582, aggregate using patient map to get only one score per patient
print variance along one patient

posture and sitting data to expanded gait

expand sitting 

get data final folder

bring back lasso

--
yfit = trainedModel.predictFcn(features_all);
nl = load('/Users/inbartivon/Downloads/HD Litt Lab/Data/labels.mat');
nl = nl.labels;
predt = arrayfun(@(x)mean(yfit(ptList==x)), 1:28);
predt(nl.PtStatus == 1);
nlG = nl.TandemGait(nl.PtStatus == 1) + nl.Gait(nl.PtStatus == 1)
(THE SAME) about 88.8% acc

also did for no CV, but 20% hold out
KNN model! about 86% acc

tried combined subscores (not gait and tandem gait) - SAME 84.8%

%try taking out entire patient from training
%make bins if classifier

changed testingclass to have a hold out class of patients, and train only on training patients that have HD
gait features 91% !!!
checking predictions...SAME
    
checking with combined scores 88.7%
predictions : 


8/1
regression combined scores with bins
RMSE 0.89



