% Geneneralized Distance Approximation from Efficicent Matching of Pictorial 
% Structures - Felzenswalb et al. Input is the initializtion of the
% distance tensor, and the output is the result of the output and a
% location tensor tracing back the origin of the minimum value (probably
% needs to be chained when used in practice. 
% Author: Mohamed El Banani
function [outTensor, locTensor] = genDistanceApprox(inTensor, k, locTensor)

% Get constants from input
kx = k(1);
ky = k(1);
kt = k(1);
ks = k(1);

%first pass
for s = [2:size(inTensor, 4)]
    for t = [2:size(inTensor, 3)]
        for y = [2:size(inTensor, 2)]
            for x = [2:size(inTensor, 1)]
                % equations on page 5
                neighbors = [inTensor(x,y,t,s), ... 
                    inTensor(x - 1, y, t, s) + kx, ... 
                    inTensor(x, y - 1, t, s) + ky, ...
                    inTensor(x, y, t - 1, s) + ks, ... 
                    inTensor(x, y, t, s - 1) + kt];
                minCost = min(neighbors);
                minLoc  = find(neighbors == minCost, 1, 'first');
                inTensor(x,y,t,s) = minCost;
                switch(minLoc)
                    case 2
                        locTensor{x,y,t,s} = locTensor{x - 1, y, t, s};
                    case 3
                        locTensor{x,y,t,s} = locTensor{x, y - 1, t, s};
                    case 4
                        locTensor{x,y,t,s} = locTensor{x, y, t - 1, s};
                    case 5
                        locTensor{x,y,t,s} = locTensor{x, y, t, s - 1};
                end
            end
        end
    end
end

%second pass
for s = [size(inTensor, 4)-1: -1: 1]
    for t = [size(inTensor, 3)-1: -1: 1]
        for y = [size(inTensor, 2)-1: -1: 1]
            for x = [size(inTensor, 1)-1: -1: 1]
                % equations on page 5
                neighbors = [inTensor(x,y,t,s), ... 
                    inTensor(x + 1, y, t, s) + kx, ... 
                    inTensor(x, y + 1, t, s) + ky, ...
                    inTensor(x, y, t + 1, s) + ks, ... 
                    inTensor(x, y, t, s + 1) + kt];
                
                minCost = min(neighbors);
                minLoc  = find(neighbors == minCost, 1, 'first');
                inTensor(x,y,t,s) = minCost;
                
                switch(minLoc)
                    case 2
                        locTensor{x,y,t,s} = locTensor{x + 1, y, t, s};
                    case 3
                        locTensor{x,y,t,s} = locTensor{x, y + 1, t, s};
                    case 4
                        locTensor{x,y,t,s} = locTensor{x, y, t + 1, s};
                    case 5
                        locTensor{x,y,t,s} = locTensor{x, y, t, s + 1};
                end
            end
        end
    end
end

outTensor = inTensor;

end
