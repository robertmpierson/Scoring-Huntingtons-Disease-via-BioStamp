function [ptList, ftIntv, n] = ptIDList(patientIDMap, ftG)
n = zeros(1,max(patientIDMap{1}));

for i = 1: length(patientIDMap)
    p = patientIDMap{i};
    for j = 1: length(p)
        n(p(j)) = n(p(j)) + 1;
    end
end
pts = 1:max(patientIDMap{1});

ptList = repelem(pts, n);
ftIntv = zeros(length(ptList), length(ftG{1,1}{1}));
for i = 1: length(ftG)
    f = ftG{i};
    p = patientIDMap{i};
    for j = 1: length(f)
        iD = p(j);
        idx = find((all(ftIntv ==0,2))' & ptList == iD ==1,1);
        ftIntv(idx,:) = cell2mat(f(j));
        

    end
end

end