function cost = newCostFunction(L,part,seq,imgList);

if part ~= 1 && part ~= 6
    cost = 0.;
    return;
end

% FolderName = '../buffy_s5e2_original/';
% imgList = {};
% 
% D = dir([FolderName, '*.jpg']);
% imgNum = length(D(not([D.isdir])));
% 
% for i=1:imgNum
%     imgList = [imgList; imread(strcat(FolderName, D(i).name))];
% end

L_x = L(1);
L_y = L(2);
L_theta = L(3);
L_scale = L(4);

h_w = 100;
h_h = 80;
t_w = 100; 
t_h = 80;

targetImage = imgList{seq};
targetImage = imrotate(targetImage,L_theta);

%omega = load('omegaTemplate_revised.mat');
%omegaShape = omega.omegaShape;

omega = load('omegaTemplate_revised.mat');
omegaShape = omega.A;

figure;
if part == 1 %head
    
    neckx = L_x;
    necky = L_y + 12*L_scale;
    
    tlx = neckx-h_w/2*L_scale;
    tly = necky-h_h/2*L_scale;
    brx = neckx+h_w/2*L_scale;
    bry = necky+h_h/2*L_scale;
    
    imshow(imgList{seq});
    hold on;
    line([tlx,tlx,brx,brx,tlx],[tly,bry,bry,tly,tly]);
    
    headPatch = targetImage(tly:bry,tlx:brx);
    figure;
    headPatch = imresize(headPatch,[size(omegaShape,1),size(omegaShape,1)]);
    imshow(headPatch);
    [hmag, hdir] = imgradient(uint8(headPatch),'sobel');
    sum(sum(double(omegaShape) .* hmag))
    cost = 1/ sum(sum(double(omegaShape) .* hmag));
elseif part == 6 %torso
    
    neckx = L_x;
    necky = L_y - t_h*L_scale;
    
    tlx = neckx-t_w/2*L_scale;
    tly = necky-t_h/2*L_scale;
    brx = neckx+t_w/2*L_scale;
    bry = necky+t_h/2*L_scale;
    
    imshow(imgList{seq});
    hold on;
    line([tlx,tlx,brx,brx,tlx],[tly,bry,bry,tly,tly]);
    
    torsoPatch = targetImage(tly:bry,tlx:brx);
    figure;
    torsoPatch = imresize(torsoPatch,[size(omegaShape,1),size(omegaShape,1)]);
    imshow(torsoPatch);
    [tmag, tdir] = imgradient(uint8(torsoPatch),'sobel');
    sum(sum(double(omegaShape) .* tmag))
    cost = 1/ sum(sum(double(omegaShape) .* tmag));
end





