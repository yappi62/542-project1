function mincost = bonus2(L,part,seq)
% L = {x,y,theta,scale);
% part = 6 : head, part = 1 : torso
% seq = image seqeunce

if part != 1 && part != 6
   mincost = 0;
   return;
end

close all;
clear all;
%file annotated data read code.

% Open file
fid = fopen('../annotationdata.txt', 'r');
if fid < 1,
    error([' Can not open file ', txtfile]);
end

FolderName = '../buffy_s5e2_original/';
imgList = {};
patchscale = linspace(54,6);

D = dir([FolderName, '*.jpg']);
imgNum = length(D(not([D.isdir])));

for i=1:imgNum
    imgList = [imgList; imread(strcat(FolderName, D(i).name))];
end


tline = fgets(fid);
annotatedData = {};

numData = 1;
while ischar(tline)
    
    C = strsplit(tline);
    annotatedData(numData).seq = str2num(C{1});
    annotatedData(numData).coor(1) = str2num(C{2});
    annotatedData(numData).coor(2) = str2num(C{3});
    annotatedData(numData).coor(3) = str2num(C{4});
    annotatedData(numData).coor(4) = str2num(C{5});
    numData = numData + 1;
    tline = fgets(fid);
end
fclose(fid);

omegaSize = 128;
omegaShape = zeros(omegaSize,omegaSize);

figure
for i=1:numData-1
    idx = annotatedData(i).coor(:);
    x = round(idx(1));
    y = round(idx(2));
    w = round(idx(3));
    h = round(idx(4));

    patchtemp = double(imgList{i}(y:y+h,x:x+w));  %% image should be rotated by L(theta)
    
    [Gmag, Gdir] = imgradient(uint8(patchtemp),'sobel');
    omegaShape = omegaShape + imresize(Gmag,[omegaSize,omegaSize]);
    
    imshow(omegaShape, []), title('Gradient magnitude')
    hold on;
end

omegaShape = omegaShape/norm(omegaShape);

[U,S,V] = svd(omegaShape);

figure
plot(diag(S),'ob')
truncated_sigma = 5;
omegaShape = zeros(omegaSize,omegaSize);
S(truncated_sigma:end,truncated_sigma:end) = 0;
omegaShape = U*S*V';

figure, imshow(omegaShape, []);

save('omegaTemplate.mat','omegaShape');

%% test %%
head = double(imgList{1}(213:213+128,198:198+128));
figure
imshow(head)
figure
[Hmag, Hdir] = imgradient(uint8(head),'sobel');
imresize(Hmag,[omegaSize,omegaSize]);
imshow(Hmag)
sum(sum(Hmag .* omegaSize))










