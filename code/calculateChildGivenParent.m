function [ childCost ] = calculateChildGivenParent(parent, child, parentLoc, childCost, inputGrids, W)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


row_grid  = inputGrids{1};
col_grid  = inputGrids{2};
rotations = inputGrids{3};
scales    = inputGrids{4};

parentL = [row_grid(parentLoc(1)), col_grid(parentLoc(2)), rotations(parentLoc(3)), scales(parentLoc(4))];


for x = 1:size(row_grid, 2)
    for y = 1:size(col_grid,2)
        for theta = 1:size(rotations,2)
            for s = 1:size(scales,2)
                
                L = [row_grid(x), col_grid(y), rotations(theta), scales(s)];
                
                childCost(x,y,theta,s) = childCost(x,y,theta,s) + deformation_cost_star_model(parentL, parent, L, child, W);
            end
        end
    end
end

end

