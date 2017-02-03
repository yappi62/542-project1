function [ outLoc ] = convertIndexToPixels( inLoc, grid)

if (size(inLoc, 1) > 1)
    inLoc = inLoc(1,:);
end

outLoc = [grid{1}(inLoc(1)), grid{2}(inLoc(2)),grid{3}(inLoc(3)),grid{4}(inLoc(4))];

end

