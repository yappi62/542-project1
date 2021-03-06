function out = pipeline(buffydir,episodenr)
% function out = DummyBuffyPoseEstimation(buffydir,episodenr)
% this routine provides a dummy example of pose estimation pipeline
% for each image in the dataset it returns from 0-10 random detections with a dummy pose
% this routine was prepared to demonstrate the way to obtain data structure suitable for our evaluation routine.
% Input:
%   buffydir - relative or absolute path to buffy frames directory
%   episodenr - episode number (value stored in out(i).episode
% Output:
%   out - is a stucture as excpected by the BatchEvalBuffy evaluation routine, it is an array of structs (one entry per frame) with the following fields:
%           .episode - corresponding episode number
%           .frame - corresponding frame number
%           .stickmen - array of structs containing multiple stickmen to be evaluated with fields:
%             .coor - stickman end-points coordinates coor(:,nparts) = [x1 y1 x2 y2]'
%             .det - is the detection bounding box associated with the stickman in [minx miny maxx maxy]
%


% In order to hand-tune the parameters, weights vectors are defined here.
% w --> weight vector, 1xn cell(there will be n possible pairs),
%       and each cell is 1x4 matrix (each indicates wx, wy, wt, and ws)
% Pairs (1,2), (1,3) -> w{1}
% Pair  (1,6)        -> w{2}
% Paris (2,4), (3,5) -> w{3}
% k --> [kx, ky, kt, ks];

W = { [1, 1, .01, 1], ...
    [.5, .5, 0.05, .5], ...
    [.8, .8, 0.08, .8] };
K = [20, 10, pi/10, 1];



Files = dir(buffydir);
invalid = false(length(Files),1);
for i=1:numel(Files)
    invalid(i) = isempty(regexpi(Files(i).name, '.jpg'));
end
Files(invalid) = [];
N = length(Files);
out(N) = struct('frame',[],'stickmen',[]);
lF = ReadStickmenAnnotationTxt('../data/buffy_s5e2_sticks.txt');

%Define Input Grids
inputGrids{1} = 1:20:720;
inputGrids{2} = 1:10:400;
inputGrids{3} = -pi/2: pi/10: pi/2;
inputGrids{4} = [0.5, .6, .7, .9, 1, 1.1, 1.3, 1.5, 2];
% inputGrids{3} = -pi/2: pi/5: pi/2;
% inputGrids{4} = [0.5, .7, 1, 1.3, 1.5];

elementsToCheck = [1:N];
elementsToCheck(1:5:N) = [];
elementsToCheck(1:32) = [];
for i= elementsToCheck
    img = imread(fullfile(buffydir,Files(i).name));
    out(i).frame = str2double(Files(i).name(1:end-4));
    out(i).episode = episodenr;

    
    startTime = tic;
    % part is the query part, 1=torso, 2=left upper arm, 3=right upper arm,
    %                         4=left lower arm, 5=right lower arm, 6= head
    
    % calculate match cost term
    [torsoTensor, torsoLoc] = parts_tensor(1, 1, i, lF, inputGrids, W);
    [lleftArmTensor, lleftArmLoc] = parts_tensor(4, 2, i, lF, inputGrids, W);
    [lrightArmTensor, lrightArmLoc] = parts_tensor(5, 3, i, lF, inputGrids, W);
    [leftArmTensor, leftArmLoc] = parts_tensor(2, 1, i, lF, inputGrids, W);
    [rightArmTensor, rightArmLoc] = parts_tensor(3, 1, i, lF, inputGrids, W);
    [headTensor , headLoc] = parts_tensor(6, 1, i, lF, inputGrids, W);
    
%     [torsoEnergy, torsoLocTensor] = genDistanceApprox(torsoTensor, K, torsoLoc);
    
    % calculate approximation for leafs
    [lleftArmEnergy, lleftArmLoc] = genDistanceApprox(lleftArmTensor, W{2}.*K, lleftArmLoc);
    [lrightArmEnergy, lrightArmLoc] = genDistanceApprox(lrightArmTensor, W{3}.*K, lrightArmLoc);
    [headEnergy, headLoc] = genDistanceApprox(headTensor, W{2}.*K, headLoc);
    
    % calculate Tensors and approximations for upper arms
    [leftArmTensor] = calculateParentTensor(leftArmTensor, {lleftArmEnergy});
    [rightArmTensor] = calculateParentTensor(rightArmTensor, {lrightArmEnergy});
    [leftArmEnergy, leftArmLoc] = genDistanceApprox(leftArmTensor, W{1}.*K, leftArmLoc);
    [rightArmEnergy, rightArmLoc] = genDistanceApprox(rightArmTensor, W{1}.*K, rightArmLoc);
    
    % calculate tensor and approximation for torso
    childrenTensors  = {leftArmEnergy, rightArmEnergy, headEnergy};
    [torsoTensor] = calculateParentTensor(torsoTensor, childrenTensors);
    [torsoEnergy, torsoLocTensor] = genDistanceApprox(torsoTensor, K, torsoLoc);
    
    torsoLoc         = minIndex(torsoEnergy);
    disp(['Number of minimized torsoCosts = ' num2str(size(torsoLoc, 1))]);
    
    if(size(torsoLoc,1) >= 2)    
        torsoLoc         = minIndex(torsoTensor);
        if (size(torsoLoc,1) >= 2)
            torsoLoc = torsoLoc(1, :);
        end
    end
    
%     torsoLocation    = convertIndexToPixels(torsoLoc, inputGrids);
    
    torsoLocation    = torsoLocTensor{torsoLoc(1), torsoLoc(2), torsoLoc(3), torsoLoc(4)};
    rightArmLocation = rightArmLoc{torsoLoc(1), torsoLoc(2), torsoLoc(3), torsoLoc(4)};
    leftArmLocation = leftArmLoc{torsoLoc(1), torsoLoc(2), torsoLoc(3), torsoLoc(4)};
    headLocation     = headLoc{torsoLoc(1), torsoLoc(2), torsoLoc(3), torsoLoc(4)};
    
    rightArmIndex = [findNearestIndex(inputGrids{1}, rightArmLocation(1)), ...
                    findNearestIndex(inputGrids{2}, rightArmLocation(2)), ...
                    findNearestIndex(inputGrids{3}, rightArmLocation(3)), ...
                    findNearestIndex(inputGrids{4}, rightArmLocation(4))];
                
    leftArmIndex = [findNearestIndex(inputGrids{1}, leftArmLocation(1)), ...
                    findNearestIndex(inputGrids{2}, leftArmLocation(2)), ...
                    findNearestIndex(inputGrids{3}, leftArmLocation(3)), ...
                    findNearestIndex(inputGrids{4}, leftArmLocation(4))];
    
    lrightArmLocation = lrightArmLoc{rightArmIndex(1), rightArmIndex(2), rightArmIndex(3), rightArmIndex(4)};
    llefttArmLocation = lleftArmLoc{leftArmIndex(1), leftArmIndex(2), leftArmIndex(3), leftArmIndex(4)};
    
    torsoStick = convertL2Sticks(torsoLocation, 1);
    rArmStick  = convertL2Sticks(rightArmLocation, 2);
    lArmStick  = convertL2Sticks(leftArmLocation, 3);
    lrArmStick  = convertL2Sticks(lrightArmLocation, 4);
    llArmStick  = convertL2Sticks(llefttArmLocation, 5);
    headStick  = convertL2Sticks(headLocation, 6);
    
    imageTime = toc(startTime);
    disp(['Time for image (', num2str(i), ') was ', num2str(imageTime), ' seconds.']);
    
    sticks = [torsoStick, rArmStick, lArmStick, lrArmStick, llArmStick, headStick];
    hdl = DrawStickman(sticks, img);
    print(gcf, '-djpeg', ['ResultsEfficient-Update/image' num2str(i)]);

    
  
    out(i).stickmen = DummyDetect(img);
    for j=1:length(out(i).stickmen)
        out(i).stickmen(j).coor = DummyPose(img,out(i).stickmen(j).det);
    end
end
end





