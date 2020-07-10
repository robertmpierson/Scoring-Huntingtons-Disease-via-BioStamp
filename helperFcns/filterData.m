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
    
    if f_high == 0
        if f_low == Inf
            a=1; b=1; % No filtering
        else
            [b,a] = butter(order,f_low/(fs/2), 'low');
        end
    elseif f_low == Inf
        [b,a] = butter(order,f_high/(fs/2), 'high');
    else
        [b,a] = butter(order,[f_high,f_low]/(fs/2),'bandpass'); % 5th-Order Butter  
    end
            
    
    
    for i = 1:size(data,1)
        for j = 1:size(data,2)
            data_centered = data{i,j} - movmean(data{i,j},100);
            filtered_data{i,j} = filtfilt(b,a,data_centered);
        end
    end
end