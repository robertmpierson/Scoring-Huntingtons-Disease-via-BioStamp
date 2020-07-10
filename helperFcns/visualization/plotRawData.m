function plotRawData(dataTables, suffix, task, sensor, pts)
% USAGE: PlotRawData(dataTables, suffix, task, sensor, pts)
% INPUTS:
%   dataTables- structure of dataTables
%   suffix- either 'clean' or 'raw'
%   task- string name of task in task list
%   sensor- string name of sensor to gather data from
%   pts- array of patient ID numbers to plot. 

data = dataTables.([task, '_', suffix]);
names= fieldnames(data);
inds= find(contains(names, sensor));

npts = length(pts); %height(raw_data);

for i_pt = 1:npts
    
    subplot(npts,2,2*i_pt-1); 
    hold on
    plot(data{pts(i_pt), inds(1)}{1})
    plot(data{pts(i_pt), inds(2)}{1})
    plot(data{pts(i_pt), inds(3)}{1})
    title(sprintf('pt %d Accel', pts(i_pt)))
    legend({'X', 'Y', 'Z'})
    
    
    subplot(npts,2,2*i_pt); 
    hold on
    plot(data{pts(i_pt), inds(4)}{1})
    plot(data{pts(i_pt), inds(5)}{1})
    plot(data{pts(i_pt), inds(6)}{1})
    title(sprintf('pt %d Gyro', pts(i_pt)))
    legend({'X', 'Y', 'Z'})
end

suptitle(sprintf('%s task %s sensor', task, sensor))

end