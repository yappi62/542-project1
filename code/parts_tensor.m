function [cost_tensor, loc_tensor] = parts_tensor(part, parent, sequence, lF, inputGrids, w)
% part is the query part, 1=torso, 2=left upper arm, 3=right upper arm, 
%                         4=left lower arm, 5=right lower arm, 6= head
%parts 

row_grid  = inputGrids{1};
col_grid  = inputGrids{2};
rotations = inputGrids{3};
scales    = inputGrids{4};

size_x = length(row_grid);
size_y = length(col_grid);
size_r = length(rotations);
size_s = length(scales);

cost_tensor = zeros( size_x, size_y, size_r, size_s);
loc_tensor = cell( size_x, size_y, size_r, size_s);

for x = 1:size(row_grid, 2)
    for y = 1:size(col_grid,2)
        for theta = 1:size(rotations,2)
            for s = 1:size(scales,2)
                 %match = match_energy_cost([x y theta s ], part, sequence);
%                  tic;
                 L_in = [row_grid(x), col_grid(y), rotations(theta), scales(s),];
                 if part ~= 1
                     W = T_Transform(parent, part, L_in, false, w);
                     L_out = T_Transform(part, parent, W, true, w);
                 else
                     L_out = L_in;
                 end
%                  if x == 13 && y == 35
%                      disp('pause');
%                  end
                 
%                  if (L_out(1) < 20 || L_out(1) > 370 || L_out(2) < 20 || L_out(2) > 680)
%                      match = realmax;
%                  else                     
%                   match = match_energy_cost(L_out, part, sequence, lF);
                   match = match_energy_cost(L_out, part, sequence, lF);
%                  end
                 cost_tensor(x,y,theta,s) = match;
                 loc_tensor{x,y,theta,s} = L_out;
%                  toc;
                 if L_in(1) > 80 && L_in(2) > 60 && part > 1
                     disp([]);
                 end
            end
        end
    end
end


end

