function cost = deformation_cost(L1, part1, L2, part2, W)
% 01242017, Written by Kyle Byungsu Min (yappi62@gmail.com)
% L1, L2 --> [x, y, theta, scale]  end points of the query stick
% part --> 1 = torso, 2 = left upper arm, 3 = right upper arm
%          4 = left lower arm, 5 = right lower arm, 6 = head

W1 = T_Transform(part1, part2, L1, false, W);
W2 = T_Transform(part2, part1, L2, false, W);

Wdiff = abs(W1 - W2);

cost = norm(Wdiff);

end
