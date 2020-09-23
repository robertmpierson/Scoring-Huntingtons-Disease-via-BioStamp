 function [seg_data_mat,segmented_data, patientIDMap, ptNumSeg] = segmentData(data, wind, overlap, numIntervals)
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
    
    if mod(wind, 1)~=0, error('Error: variable wind is not an Integer'), end
       
    
    NumWins = @(xLen) (xLen-wind+overlap)/(overlap);
    cellify = @(mat) arrayfun(@(row){[mat(:,row)]-'0'},1:size(mat,2))';
    
    nSensors = size(data,2)/numIntervals;
    
    lens = cellfun(@length, data); 
    nWins = arrayfun(@(x)floor(NumWins(x)), lens);  
    intvl_idx = (1:size(data,2)/numIntervals:size(data,2));

    [segmented_data, ~] = cellfun(@(x) buffer(x', floor(wind), round(wind-overlap), 'nodelay'), data, 'Uni', 0);
  
    patientIDMap = arrayfun(@(x)repelem((1:size(data,1)), nWins(:,x)), intvl_idx, 'Uni', 0);
    ptNumSeg = nWins(:,intvl_idx); 
    
    % Massage into necessary format
    seg_cells = cellfun(@(x)cellify(x), segmented_data, 'UniformOutput', false);
    
    for n=1:numIntervals
        i1 = intvl_idx(n);
        i2 = i1+(nSensors-1);
        cls = seg_cells(:,i1:i2);
        seg_data_mat{n} = reshape(vertcat(cls{:}), sum(ptNumSeg(:,n)), nSensors);
    end
    
    




end

