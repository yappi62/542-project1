% Calculates the parent's tensor given the children tensors and a tensor 
% describing the unary function of the parent. Deformation function as 
% described in Efficient matching for pictorial structures by Felzenswalb et al.
% Author: Mohamed El Banani
function [ parentTensor ] = calculateParentTensor( parentEnergy, childrenTensorStruct )

childTensor = zeros(size(parentEnergy));

for i = 1:max(size(struct))
    childTensor = childTensor + childrenTensorStruct{i};
end

% f(w) = m(I, Tji(w)) + sum_{children} Bc(Tji(w))
parentTensor = parentEnergy + childTensor;

end

