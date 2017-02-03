function [ index ] = findNearestIndex(vector, element)

diffVec = abs(vector - element);
index = find( diffVec == min(diffVec));

end

