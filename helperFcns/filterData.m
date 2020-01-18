function [filtered_data] = filterData(data, fs, order, f_high, f_low)
    % TODO: update header
    % Syntax: [filtered_data] = filterData(data, fs, order, f_high, f_low)
    % THIS FUNCTION CENTERS THE SIGNAL VIA "MOVMEAN()" BUILT-IN MATLAB 
    % FUNCTION.  IT THEN DOES A 5TH-ORDER BUTTERWORTH FILTER (BANDPASS
    % 1-16HZ).
    % CENTER THE DATA USING MATLAB'S BUILT-IN "MOVMEANS()" FUNCTION.
    % BANDPASS FILTER (1-16HZ) TO REMOVE ARTIFACTS SUCH AS DRIFT AND NOISE
    % FROM THE MAIN ELECTRICAL POWER LINE USING A FIFTH-ORDER BUTTERWORTH
    % FILTER.
    filtered_data = cell(size(data));
    for i = 1:size(data,1)
        for j = 1:size(data,2)
            data_centered = data{i,j} - movmean(data{i,j},100);
            [b,a] = butter(order,[f_high,f_low]/(fs/2),'bandpass'); % 5th-Order Butter
            filtered_data{i,j} = filter(b,a,data_centered);
        end
    end
end