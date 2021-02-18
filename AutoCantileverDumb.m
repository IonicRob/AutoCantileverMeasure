%% Auto Cantilever Dumb
% Written by Robert J Scales Feb 2021
clc
clear
close all

cd_code = cd;

cd_StartFolderLocation = '.\Cantilelver Data';

if isempty(cd_StartFolderLocation)
    cd_StartFolderLocation = cd_code;
end

cd(cd_StartFolderLocation);
[cant_files,cant_path] = uigetfile('*.png','MultiSelect','off');
cant_filenames = string(cant_files);
cant_fullfiles = string(fullfile(cant_path,cant_files));
cd(cd_code);

if isa(cant_files,'char') % If one file is selected it will be loaded in as a char and not a cell.
    cant_files = cellstr(cant_files);
end


cd(cd_StartFolderLocation);
filter = '*.tif';
[files,path] = uigetfile(filter,'MultiSelect','on');
filenames = string(files);
fullfiles = string(fullfile(path,files));
cd(cd_code);

if isa(files,'char') % If one file is selected it will be loaded in as a char and not a cell.
    files = cellstr(files);
end

%% Step 1 - Select Region Of Interest
close all
clc
I = cant_fullfiles{1};
J = fullfiles{1};

boxImage = (imread(I));
sceneImage = rgb2gray(imread(J));
initial_sceneImage = sceneImage;

figure('Name','sceneImage');
imshow(sceneImage);
% roi = drawrectangle;
roi = drawpolygon;
m = size(sceneImage,1);
n = size(sceneImage,2);
roi_2 = poly2mask(roi.Position(:,1),roi.Position(:,2),m,n);
sceneImage = sceneImage.*uint8(roi_2);
% % roi = roipoly(sceneImage); %drawpolygon;
% Vertices = roi.Position;
% sceneImage = imcrop(sceneImage, roi);
% % sceneImage = imcrop(sceneImage,Vertices);

figure('Name','Masked');
imshow(sceneImage);
pause(1);

%% Step 2 - Binarize Image & Augment It

BW = imbinarize(sceneImage,0.2); % im2bw
imshow(BW);
% [row, col] = ginput(1);
% row = round(row,0);
% col = round(col,0);
% boundary = bwtraceboundary(BW,[row, col],'N');

imshow(sceneImage)
hold on;
% plot(boundary(:,2),boundary(:,1),'g','LineWidth',3);

BW_filled = imfill(BW,'holes');
imshow(BW_filled);
boundaries = bwboundaries(BW_filled);
% % for k=1:10
% %    b = boundaries{k};
% %    plot(b(:,2),b(:,1),'g','LineWidth',3);
% % end
% 
mask_boundary = cell2mat(boundaries);
% 
% % contx = mask_boundary(:,1);
% % conty = mask_boundary(:,2);
% % userConfig = struct('xy',[contx(:) conty(:)]);
% % resultStruct = tsp_nn(userConfig);
% 
% [x_out,y_out] = f_IA_NSP(mask_boundary(:,2),mask_boundary(:,1));
% close all
% plot(x_out,y_out);

plot(mask_boundary(:,2),mask_boundary(:,1),'g','LineWidth',3);

% % Create a logical image that defines a rectangular boundary.
% mask = false(size(mask_boundary));
% mask(10:100,10:100) = true;
% % Assign a fill value of 40 to all pixels within the boundary
% mask_boundary(mask) = 40;
% figure, imagesc(mask_boundary)

% close all
% clc
% imshow(sceneImage);
% 
% for i = 10:20
%     j = i/100;
%     disp(j);
%     BW = imbinarize(sceneImage,j); % im2bw
%     % BW = imbinarize(sceneImage,'adaptive','Sensitivity',0.45); % im2bw
%     imshow(BW);
%     pause(2);
% end
% close all

sceneImage = BW_filled;
figure;
imshow(double(sceneImage));
montage({uint8(initial_sceneImage), double(sceneImage)});

%%

% BW2 = bwmorph(sceneImage,'remove');
% figure
% imshow(BW2)