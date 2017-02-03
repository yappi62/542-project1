function [cost_tensor] = parts_tensor_star(part, sequence, lF, inputGrids, w, imgList,omegaShape)
% part is the query part, 1=torso, 2=left upper arm, 3=right upper arm, 
%                         4=left lower arm, 5=right lower arm, 6= head
%parts 

useNew = true;
if nargin < 6
    useNew = false;
end

row_grid  = inputGrids{1};
col_grid  = inputGrids{2};
rotations = inputGrids{3};
scales    = inputGrids{4};

size_x = length(row_grid);
size_y = length(col_grid);
size_r = length(rotations);
size_s = length(scales);

cost_tensor = zeros( size_x, size_y, size_r, size_s);

for x = 1:size(row_grid, 2)
    for y = 1:size(col_grid,2)
        for theta = 1:size(rotations,2)
            for s = 1:size(scales,2)
                L = [row_grid(x), col_grid(y), rotations(theta), scales(s)];
                if useNew
                    cost_tensor(x,y,theta,s) = newCostFunction(L,part,sequence,imgList,omegaShape);
                else
                    cost_tensor(x,y,theta,s) = match_energy_cost(L, part, sequence, lF);
                end
            end
        end
    end
end


end

