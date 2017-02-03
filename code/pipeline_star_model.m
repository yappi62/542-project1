function out = pipeline_star_model(buffydir,episodenr)
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
K = [20, 10, 10, 10];

FolderName = '../buffy_s5e2_original/';
imgList = {};
 
D = dir([FolderName, '*.jpg']);
imgNum = length(D(not([D.isdir])));
 
for i=1:imgNum
   imgList = [imgList; imread(strcat(FolderName, D(i).name))];
end


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
% inputGrids{1} = 20:20:380;
% inputGrids{2} = 20:20:700;
% inputGrids{3} = -pi/2: (pi)/5 : pi/2;
% inputGrids{4} = [0.5 0.75 1 1.25 1.5];


inputGrids{1} = 1:20:720;
inputGrids{2} = 1:10:400;
inputGrids{3} = -pi/2: pi/10: pi/2;
inputGrids{4} = [0.5, .6, .7, .9, 1, 1.1, 1.3, 1.5, 2];

omega = load('omegaTemplate_revised.mat');
omegaShape = omega.A;

for i=1:10:N
        img = imread(fullfile(buffydir,Files(i).name));
    out(i).frame = str2double(Files(i).name(1:end-4));
    out(i).episode = episodenr;
    
    %{
    % Use new match cost function
    [torsoTensor]    = parts_tensor_star(1, i, lF, inputGrids, W, imgList,omegaShape);
    [leftArmTensor]  = parts_tensor_star(2, i, lF, inputGrids, W,imgList,omegaShape);
    [leftLArmTensor]  = parts_tensor_star(4, i, lF, inputGrids, W,imgList,omegaShape);
    [rightArmTensor] = parts_tensor_star(3, i, lF, inputGrids, W,imgList,omegaShape);
    [rightLArmTensor] = parts_tensor_star(5, i, lF, inputGrids, W,imgList,omegaShape);
    [headTensor ]    = parts_tensor_star(6, i, lF, inputGrids, W,imgList,omegaShape);
    %}
    
    [torsoTensor]    = parts_tensor_star(1, i, lF, inputGrids, W);
    [leftArmTensor]  = parts_tensor_star(2, i, lF, inputGrids, W);
    [leftLArmTensor]  = parts_tensor_star(4, i, lF, inputGrids, W);
    [rightArmTensor] = parts_tensor_star(3, i, lF, inputGrids, W);
    [rightLArmTensor] = parts_tensor_star(5, i, lF, inputGrids, W);
    [headTensor ]    = parts_tensor_star(6, i, lF, inputGrids, W);
    
    torsoLoc    = minIndex(torsoTensor);
    torsoLoc    = torsoLoc(1,:);
    
    leftArmTensor   = calculateChildGivenParent(1,2, torsoLoc, leftArmTensor, inputGrids, W);
    rightArmTensor  = calculateChildGivenParent(1,3, torsoLoc, rightArmTensor, inputGrids, W);
    headTensor      = calculateChildGivenParent(1,6, torsoLoc, headTensor, inputGrids, W);
    
    leftArmLoc = minIndex(leftArmTensor);
    leftArmLoc = leftArmLoc(1,:);
    rightArmLoc = minIndex(rightArmTensor);
    rightArmLoc = rightArmLoc(1,:);
    headLoc = minIndex(headTensor);
    headLoc = headLoc(1,:);
    
    leftLArmTensor  = calculateChildGivenParent(2,4, leftArmLoc, leftLArmTensor, inputGrids, W);
    rightLArmTensor  = calculateChildGivenParent(3,5, rightArmLoc, rightLArmTensor, inputGrids, W);
    leftLArmLoc = minIndex(leftLArmTensor);
    leftLArmLoc = leftLArmLoc(1,:);
    rightLArmLoc = minIndex(rightLArmTensor);
    rightLArmLoc = rightLArmLoc(1,:);
    
    torsoLocation    = convertIndexToPixels(torsoLoc, inputGrids);
    rightArmLocation = convertIndexToPixels(rightArmLoc, inputGrids);
    rightLArmLocation = convertIndexToPixels(rightLArmLoc, inputGrids);
    lefttArmLocation = convertIndexToPixels(leftArmLoc, inputGrids);
    lefttLArmLocation = convertIndexToPixels(leftLArmLoc, inputGrids);
    headLocation     = convertIndexToPixels(headLoc, inputGrids);
    
    torsoStick = convertL2Sticks(torsoLocation, 1);
    lArmStick  = convertL2Sticks(lefttArmLocation, 2);
    rArmStick  = convertL2Sticks(rightArmLocation, 3);
    lLArmStick  = convertL2Sticks(lefttLArmLocation, 4);
    rLArmStick  = convertL2Sticks(rightLArmLocation, 5);
    headStick  = convertL2Sticks(headLocation, 6);
    
    sticks = [torsoStick, lArmStick, rArmStick, lLArmStick, rLArmStick, headStick];
    DrawStickman(sticks, img);
    drawnow;
    
    out(i).stickmen = DummyDetect(img);
    for j=1:length(out(i).stickmen)
        out(i).stickmen(j).coor = DummyPose(img,out(i).stickmen(j).det);
    end
end
end
