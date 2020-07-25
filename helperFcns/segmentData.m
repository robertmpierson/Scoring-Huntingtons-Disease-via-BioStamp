function [seg_data_mat,segmented_data, patientIDMap] = segmentData(data, wind, overlap, fs, numIntervals)
    patientIDMap = cell(1,numIntervals); %for gait: each interval has different amount of windows, need a map for each interval
    intv = (size(data,2))/ numIntervals; 
    NumWins = @(xLen, fs, winLen, winDisp) (xLen-winLen*fs+winDisp*fs)/(winDisp*fs);
    segmented_data = cell(size(data));
    seg_data_mat = cell(size(data,2),1);
    
    for n = 1:numIntervals
        for j = (n-1)*24+1:n*24
            for i = 1:size(data,1)
                l = length(data{i,j});
                numW = floor(NumWins(l,fs,wind/fs,overlap/fs));

                if rem(j,intv) == 0
                    patientIDMap{n} = [patientIDMap{n},i*ones(numW,1)']; 

                end
                for k = 1:numW
                    %segmented_data{i,j}{k} = data{i,j}(k:k+wind);
                    segmented_data{i,j} = [segmented_data{i,j},data{i,j}(k:k+wind)];
                end
            end
            seg_data_mat{j} = cell2mat(segmented_data(:,j)');
        end
    end



end

