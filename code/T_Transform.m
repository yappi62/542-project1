function L_out = T_Transform(part1, part2, L_in, option_inv, w)

% 01292017, Written by Kyle Byungsu Min (yappi62@gmail.com)

% L_in, L_out --> [x, y, theta, scale]
% part --> 1 = torso, 2 = left upper arm, 3 = right upper arm
%          4 = left lower arm, 5 = right lower arm, 6 = head
% w --> weight vector, 1xn cell(there will be n possible pairs),
%       and each cell is 1x4 matrix (each indicates wx, wy, wt, and ws)
% Pairs (1,2), (1,3) -> w{1}
% Pair  (1,6)        -> w{2}
% Paris (2,4), (3,5) -> w{3}

% If you want to get T_ij(l), then T_Transform(i, j, w)
% If you want to get T_ji(l), then T_Transform(j, i, w)
% If you want to get inv_T_ij(l), then T_Transform(i, j, l, true, w)
% If you want to get inv_T_ji(l), then T_Transform(j, i, l, true, w)
%{
% The following is the test code (ideal configuration)
L1 = [0, 80, 0, 1];
L2 = [-107.5, 20, 0, 1];
L = T_Transform(1, 2, L1);
Li1 = T_Transform(1, 2, L, true);
Li2 = T_Transform(2, 1, L, true);
L1==Li1
L2==Li2


L3 = [107.5, 20, 0, 1];
L = T_Transform(1, 3, L1);
Li1 = T_Transform(1, 3, L, true);
Li3 = T_Transform(3, 1, L, true);
L1==Li1
L3==Li3


L1 = [100, 180, 0, 1];
L2 = [-7.5, 120, 0, 1];
L = T_Transform(1, 2, L1);
Li1 = T_Transform(1, 2, L, true);
Li2 = T_Transform(2, 1, L, true);
L1==Li1
L2==Li2


L3 = [207.5, 120, 0, 1];
L = T_Transform(1, 3, L1);
Li1 = T_Transform(1, 3, L, true);
Li3 = T_Transform(3, 1, L, true);
L1==Li1
L3==Li3
%}

if nargin < 5
    w = { [1, 1, 1, 1], ...
        [1, 1, 1, 1], ...
        [1, 1, 1, 1] };
    if nargin < 4
        option_inv = false;
    end
end

theta_ideal = 0;
scale_ideal = 1;

% Set fixed size and aspect ratio
torso_height = 160;
uarm_length = 95;
larm_length = 65;
head_length = 60;
torso_ratio = 3/4;
%arm_ratio = 4;
torso_arm_shrink = 0.75;
torso_neck_stretch = 1.09375;
head_neck_stretch = 1.25;

% The location of joint, w.r.t 1 and 2
jpos = zeros(2,1);

w_index = get_pair_index(part1, part2);
wi = w{w_index};
if option_inv
    L_in(3) = L_in(3) / wi(3) + theta_ideal/2;
    L_in(4) = exp ( L_in(4) / wi(4) + log(scale_ideal)/2 );
end

co = cos(L_in(3));
si = -sin(L_in(3));

% Find the locations of joint, with valid pairs only
if part1 == 1
    if part2 == 2
        jpos(1) = - torso_height * torso_ratio * L_in(4) / 2;
        jpos(2) = - torso_height * L_in(4) / 2 * torso_arm_shrink;
        
    elseif part2 == 3
        jpos(1) = torso_height * torso_ratio * L_in(4) / 2;
        jpos(2) = - torso_height * L_in(4) / 2 * torso_arm_shrink;
    elseif part2 == 6
        jpos(2) = - torso_height * L_in(4) / 2 * torso_neck_stretch;
    end
elseif part1 == 2
    if part2 == 1
        jpos(1) = uarm_length * L_in(4) / 2;
    elseif part2 == 4
        jpos(1) = - uarm_length * L_in(4) / 2;
    end
elseif part1 == 3
    if part2 == 1
        jpos(1) = - uarm_length * L_in(4) / 2;
    elseif part2 == 5
        jpos(1) = uarm_length * L_in(4) / 2;
    end
elseif part1 == 4
    if part2 == 2
        jpos(1) = larm_length * L_in(4) / 2;
    end
elseif part1 == 5
    if part2 == 3
        jpos(1) = - larm_length * L_in(4) / 2;
    end
elseif part1 == 6
    if part2 == 1
        jpos(2) = head_length * L_in(4) / 2 * head_neck_stretch;
    end
end

x = L_in(4) * (jpos(1)*co + jpos(2)*si);
y = L_in(4) * (-jpos(1)*si + jpos(2)*co);

if option_inv
    L_out(1) = L_in(1) / wi(1) - x;
    L_out(2) = L_in(2) / wi(2) - y;
    L_out(3) = L_in(3);
    L_out(4) = L_in(4);
else
    L_out(1) = wi(1) * (L_in(1) + x);
    L_out(2) = wi(2) * (L_in(2) + y);
    L_out(3) = wi(3) * (L_in(3) - theta_ideal/2);
    L_out(4) = wi(4) * (log(L_in(4)) - log(scale_ideal)/2);
end

end

function w_index = get_pair_index(part1, part2)
% Find the locations of joint, with valid pairs only
errorMsg = 'Wrong pairing of parts';
if part1 == 1
    if part2 == 2
        w_index = 1;
    elseif part2 == 3
        w_index = 1;
    elseif part2 == 6
        w_index = 2;
    else
        error(errorMsg);
    end
elseif part1 == 2
    if part2 == 1
        w_index = 1;
    elseif part2 == 4
        w_index = 3;
    else
        error(errorMsg);
    end
elseif part1 == 3
    if part2 == 1
        w_index = 1;
    elseif part2 == 5
        w_index = 3;
    else
        error(errorMsg);
    end
elseif part1 == 4
    if part2 == 2
        w_index = 3;
    else
        error(errorMsg);
    end
elseif part1 == 5
    if part2 == 3
        w_index = 3;
    else
        error(errorMsg);
    end
elseif part1 == 6
    if part2 == 1
        w_index = 2;
    else
        error(errorMsg);
    end
end
end