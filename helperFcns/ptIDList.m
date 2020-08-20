function [ptList, ftIntv, n] = ptIDList(patientIDMap, ftG)
%patientidmap maps each patient in ftG to one of the 28 patients
%ftG = cell(1,numIntervals);

%output: n 1x28 with how many versions of each patient there are
% ptList is 1xnumber of expanded patients
% ftIntv is a Mx1 cell where M is the number of expanded patients
n = zeros(1,max(patientIDMap{1}));

for i = 1: length(patientIDMap)
    p = patientIDMap{i};
    for j = 1: length(p)
        n(p(j)) = n(p(j)) + 1;
    end
end
pts = 1:max(patientIDMap{1});

ptList = repelem(pts, n);
ftIntv = cell(length(ptList), 1);
for i = 1: length(ftG)
    f = ftG{i};
    p = patientIDMap{i};
    for j = 1: length(f)
        iD = p(j);
        idx = find(cellfun(@isempty,ftIntv)' & ptList == iD ==1,1);
        ftIntv(idx,:) = f(j);
        

    end
end

end