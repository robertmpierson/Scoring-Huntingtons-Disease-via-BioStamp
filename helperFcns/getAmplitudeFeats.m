function [ampFeats] = getAmplitudeFeats(data, minpkdist)
%getAmplitudeFeats - quantify statistics of peak to peak features in a
%signal
%
% Syntax: [ampFeats] = getAmplitudeFeats(data, minpkdist)
%
% Inputs:
%    data - TxN matrix with timeseries data in columns
%    minpkdist - minimum spacing between detected peaks, input to findpeaks
%    function
%
% Outputs:
%    ampFeats - a 6xN feature array with mean, max, min, std peak-to-peak
%    amplitudes, and mean & std of the absolute regularity for each time
%    series along the columns.  

%------------- BEGIN CODE --------------
    
    num_amplitude_feats = 6;
    num_sensors = size(data,2); 
    ampFeats=zeros(num_amplitude_feats, num_sensors);
    
    for col= 1:num_sensors
        x= data(:,col);
        prom = mean(abs(x));
        [~,locs] = findpeaks(x,'MinPeakDistance',minpkdist,'MinPeakProminence',mean(abs(x))); 
        TF = find(islocalmin(x,'MinSeparation',minpkdist,'MinProminence',mean(abs(x))));
        
        prom_init = prom;
        
        while isempty(locs) || isempty(TF)
            prom = prom * 0.1;
            [~,locs] = findpeaks(x,'MinPeakProminence', prom); 
            TF = find(islocalmin(x,'MinProminence', prom));
            
            if prom < .001*prom_init
                [~,locs] = findpeaks(x,'MinPeakDistance',minpkdist); 
                TF = find(islocalmin(x,'MinSeparation',minpkdist));
                break
            end
                
        end
            
        % Get consecutive local min-to-max (amp1) and max-to-min (amp2) pairs
        [s1,inds1]=sort([locs;TF]);  i_p1=s1(diff(inds1)<0); i_v1=s1(find(diff(inds1)<0)+1);
        [s2,inds2]=sort([TF; locs]);  i_p2=s2(diff(inds2)<0); i_v2=s2(find(diff(inds2)<0)+1);
        
        amps= [abs(x(i_p1)-x(i_v1)); abs(x(i_p2)-x(i_v2))];   
        regularity= diff(locs); 
        
        if isempty(regularity); regularity = diff([locs; TF]); end
        ampFeats(:,col)=[mean(amps), max(amps), min(amps), std(amps), ...
            mean(abs(regularity)), std(abs(regularity))];

    end
    
