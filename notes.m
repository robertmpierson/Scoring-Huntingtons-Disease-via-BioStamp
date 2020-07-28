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
    
    


