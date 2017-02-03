function cost = deformation_cost(L1, part1, L2, part2)
% 01242017, Written by Kyle Byungsu Min (yappi62@gmail.com)
% L1, L2 --> [x, y, theta, scale]  end points of the query stick
% part --> 1 = torso, 2 = left upper arm, 3 = right upper arm
%          4 = left lower arm, 5 = right lower arm, 6 = head

% Set weights
wx = 10;
wy = 10;
wt = 1;
ws = 10;

theta_ideal = 0;
scale_ideal = 1;
%centroids = [0, 80; -47.5, 20; 47.5, 20; -127.5, 20; 127.5, 20; 0, -45];

% Set fixed aspect ratio
torso_ratio = 3/4;
%arm_ratio = 4;
torso_arm_shrink = 0.75;
torso_neck_stretch = 1.09375;
head_neck_stretch = 1.25;

% Descending ordering
if part2 < part1
    L = L1;
    part = part1;
    L1 = L2;
    part1 = part2;
    L2 = L;
    part2 = part;
end

% The location of joint, w.r.t 1 and 2
jpos12 = zeros(2,1);
jpos21 = zeros(2,1);

% Find the locations of joint, with valid pairs only
errorMsg = 'Wrong pairing of parts';
if part1 == 1
    if part2 == 2
        jpos12(1) = - torso_ratio * L1(4) / 2;
        jpos12(2) = - L1(4) / 2 * torso_arm_shrink;
        jpos21(1) = L2(4) / 2;
    elseif part2 == 3
        jpos12(1) = torso_ratio * L1(4) / 2;
        jpos12(2) = - L1(4) / 2 * torso_arm_shrink;
        jpos21(1) = - L2(4) / 2;
    elseif part2 == 6
        jpos12(2) = - L1(4) / 2 * torso_neck_stretch;
        jpos21(2) = L2(4) / 2 * head_neck_stretch;
    else
        error(errorMsg);
    end
elseif part1 == 2
    if part2 == 4
        jpos12(1) = - L1(4) / 2;
        jpos21(1) = L2(4) / 2;
    else
        error(errorMsg);
    end
elseif part1 == 3
    if part2 == 5
        jpos12(1) = L1(4) / 2;
        jpos21(1) = - L2(4) / 2;
    else
        error(errorMsg);
    end
end

% Find the transform T12 and T21 (Lo1 and Lo2, respectively)
Lo1 = L1;
Lo2 = L2;
co = cos(L1(3));
si = sin(L1(3));
Lo1(1) = wx * (L1(1) + co*jpos12(1) - si*jpos12(2));
Lo1(2) = wy * (L1(2) + si*jpos12(1) + co*jpos12(2));
Lo1(3) = wt * (L1(3) - theta_ideal/2);
Lo1(4) = ws * (log(L1(4)) - log(scale_ideal)/2);

co = cos(L2(3));
si = sin(L2(3));
Lo2(1) = wx * (L2(1) + co*jpos21(1) - si*jpos21(2));
Lo2(2) = wy * (L2(2) + si*jpos21(1) + co*jpos21(2));
Lo2(3) = wt * (L2(3) - theta_ideal/2);
Lo2(4) = ws * (log(L2(4)) - log(scale_ideal)/2);

cost = sum(abs(Lo1 - Lo2));

end
