function [filtered_data] = filterData(data, fs, order, f_high, f_low)
    % Syntax: [filtered_data] = filterData(data, fs, order, f_high, f_low)
    %
    % INPUTS:
    % data- cell array containing data matrices with timeseries along the columns
    % fs- sampling rate
    % order- butterworth filter order
    % f_high- high-pass cuttoff
    % f_low- low-pass cuttoff
    %
    % OUTPUT: 
    %  filtered_data: cell array containing filtered data matrices
    
    filtered_data = cell(size(data));
    for i = 1:size(data,1)
        for j = 1:size(data,2)
            data_centered = data{i,j} - movmean(data{i,j},100);
            [b,a] = butter(order,[f_high,f_low]/(fs/2),'bandpass'); % 5th-Order Butter
            filtered_data{i,j} = filter(b,a,data_centered);
        end
    end
end