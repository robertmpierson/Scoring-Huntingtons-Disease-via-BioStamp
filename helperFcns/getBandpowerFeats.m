function [feats_Frequency] = getBandpowerFeats(data,fs,frange)
%getBandpowerFeats - quantify statistics of the signal in the frequency domain
%
% Syntax: [feats_Frequency] = getBandpowerFeats(data,fs,frange)
%
% Inputs:
%    data - TxN matrix with timeseries data in columns
%    fs - data sampling rage
%    frange- frequency range endpoints for computing average frequency
%
% Outputs:
%    feats_Frequency - a 4xN feature array with mean frequency, and signal
%    power in low, middle, and high bands for each time series along the columns.  

%------------- BEGIN CODE --------------
     
     favg = meanfreq(data,fs,frange);
     
     % Constrain high/mid/low frequency bands between 6 Hz: 
     tremor_range= mean([max(frange(1), favg'-3), min(favg'+3,frange(2))]); 
     
     split= round(linspace(tremor_range(:,1),tremor_range(:,2),4)); 
     pLow = bandpower(data,fs,split(1:2));
     pMid = bandpower(data,fs,split(2:3));
     pHigh = bandpower(data,fs,split(3:4));

    feats_Frequency = [favg', pLow', pMid', pHigh'];
end