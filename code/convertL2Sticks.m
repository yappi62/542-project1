function [ sticks ] = convertL2Sticks(L, partNum)
% Converts an L vector and its associated part to its corresponding stick
%   inputs:     L = [x y scale theta]
%               partNum     - The part number for sizing reasons
%   outputs:    sticks = [x1 y1 x2 y2]

% 1=torso, 2=left upper arm, 3=right upper arm, 4=left lower arm, 5=right lower arm, 6= head
idealSizes = [160 95 95 65 65 60];

if partNum == 2 || partNum == 3 || partNum == 4 || partNum == 5
    L(3) = L(3) + pi/2;
end

% sticks = [x1 y1 x2 y2]
% L      = [x y s theta]
sinTerm = 0.5 * L(4) * idealSizes(partNum) * sin(L(3));
cosTerm = 0.5 * L(4) * idealSizes(partNum) * cos(L(3));

x1 = L(1) + sinTerm;
y1 = L(2) - cosTerm;
x2 = L(1) - sinTerm;
y2 = L(2) + cosTerm;

sticks = [x1 y1 x2 y2]';
end

