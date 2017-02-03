function [] = DrawHeatMap(image, tensor, scale, theta, scaling)


z(:,:) = tensor(:,:,scale,theta);
z = imresize(z, [size(image,2) , size(image,1)]);
z = z - min(min(z));
z = z ./ max(max(z));
z = 1 - z';

% scaling = 100;

z = floor (z * scaling);

z1 = (z == scaling-1);
z2 = (z == scaling-2);
z3 = (z == scaling-3);

image = im2double(image);

image(:,:, 1) = image(:,:,1) + z1;
image(:,:, 2) = image(:,:,2) + z2;
image(:,:, 3) = image(:,:,3) + z3;

fig = figure;

% colormap('hot');
imagesc(image);
end

