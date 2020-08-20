 function [seg_data_mat,segmented_data, patientIDMap, ptNumSeg] = segmentData(data, wind, overlap, fs, numIntervals)
    % input: cleanfiltered data, window size, window overlap, fs sample
    % rate  (from Settings file), and numIntervals - either 1 or 5
    % output: seg_data_mat is a 1x size(clean_data,2) table
    % segmented data is 28 x size(clean_data,2) table
    % patientIDMap is a map is a cell containing a double array of the
    % patient ids for the expanded patients
    % ptNumSeg is 1x28 with how many new patients were created from each of
    % the 28 patients.
    
    %this function uses a moving window to segment data into multiple
    %patients per original patient.
    
    patientIDMap = cell(1,numIntervals);
    intv = (size(data,2))/ numIntervals; 
    NumWins = @(xLen, fs, winLen, winDisp) (xLen-winLen*fs+winDisp*fs)/(winDisp*fs);
    segmented_data = cell(size(data));
    seg_data_mat = cell(size(data,2),1);
    ptNumSeg = cell(numIntervals,size(data,1));
    
    for n = 1:numIntervals
        for j = (n-1)*intv+1:n*intv
            for i = 1:size(data,1)
                l = length(data{i,j});
                % find number of windows
                numW = floor(NumWins(l,fs,wind/fs,overlap/fs));
                %record which patient for patient id map
                if rem(j,intv) == 0
                    patientIDMap{n} = [patientIDMap{n},i*ones(numW,1)']; 
                    ptNumSeg{n, i} = numW;
                end
                for k = 1:numW
                    segmented_data{i,j} = [segmented_data{i,j},data{i,j}(k:k+wind)];
                end
            end
            seg_data_mat{j} = cell2mat(segmented_data(:,j)');
        end
    end



end

