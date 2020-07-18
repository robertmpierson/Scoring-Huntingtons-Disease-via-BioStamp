function [segmented_data] = segmentData(data, wind, overlap, fs)
   	NumWins = @(xLen, fs, winLen, winDisp) (xLen-winLen*fs+winDisp*fs)/(winDisp*fs);
    segmented_data = cell(size(data));
    for i = 1:size(data,1)
        for j = 1:size(data,2)
            l = length(data{i,j});
            numW = floor(NumWins(l,fs,wind/fs,overlap/fs));
            segmented_data{i,j} = cell(1,numW);
            for k = 1:numW
                segmented_data{i,j}{k} = data{i,j}(k:k+wind);
            end
        end
    end


  
end

