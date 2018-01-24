[baseName, folder] = uigetfile();
fullFileName = fullfile(folder, baseName);
I = imread(fullFileName); % Read the image file %
I = imcomplement(I);
J = rgb2gray(I);            % Turn the image to gray-scale %
K = imresize(J,[200,200]);      % Resize the image %
K = im2double(K);           % Conver the image from uint8 to double 

K = floor(K*1000);

figure();
imagesc(K);