% Find the location with the minimum value in a 4d Tensor
% Author: Mohamed El Banani
function [partLoc] = minIndex( inputTensor )
[x, y, s, th] = ind2sub(size(inputTensor),find(inputTensor == min(min(min((min(inputTensor)))))));
partLoc = [x,y,s,th];

end

