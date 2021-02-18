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
filter = '*.tif';
[files,path] = uigetfile(filter,'MultiSelect','off');
filenames = string(files);
fullfiles = string(fullfile(path,files));
cd(cd_code);

if isa(files,'char') % If one file is selected it will be loaded in as a char and not a cell.
    files = cellstr(files);
end

OutPutCell = f_ScaleFinder(fullfiles(1),1);

Scale_Value = OutPutCell{1,1};
Scale_Unit = OutPutCell{1,2};

%% Step 1 - Select Region Of Interest
close all
clc
J = fullfiles{1};

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



%%
close all
sceneImage = BW_filled;
figure;
imshow(double(sceneImage));
% montage({uint8(initial_sceneImage), double(sceneImage)});
roi_line = drawline;

%%
roi_line_pos = roi_line.Position;
roi_line_x_diff = (roi_line_pos(2,1)-roi_line_pos(1,1));
roi_line_y_diff = (roi_line_pos(1,2)-roi_line_pos(2,2));
roi_line_width = sqrt((roi_line_x_diff)^2);
roi_line_height = sqrt((roi_line_y_diff)^2);
roi_line_length = sqrt((roi_line_width)^2 + (roi_line_height)^2);
roi_line_mp = nan(1,2);
roi_line_mp(:,:) = [mean(roi_line_pos(:,1)), mean(roi_line_pos(:,2))];
hold on
plot (roi_line_mp,'rx');

% [~, roi_line_idx_b] = min(roi_line_pos(:,2));
% [~, roi_line_idx_t] = max(roi_line_pos(:,2));
roi_line_raw_angle = atand(roi_line_height/roi_line_width);

if roi_line_x_diff > 0 && roi_line_y_diff > 0
    roi_line_angle = roi_line_raw_angle;
elseif roi_line_x_diff < 0 && roi_line_y_diff > 0
    roi_line_angle = 180-abs(roi_line_raw_angle);
elseif roi_line_x_diff < 0 && roi_line_y_diff < 0
    roi_line_angle = 180+abs(roi_line_raw_angle);
elseif roi_line_x_diff > 0 && roi_line_y_diff < 0
    roi_line_angle = 360-abs(roi_line_raw_angle);
end

vp = [-roi_line_y_diff, roi_line_x_diff]/2;
% vp = vp/norm(vp);
% A = dot([roi_line_x_diff,roi_line_y_diff], vp);

new_line_pos_1 = [roi_line_mp;roi_line_mp+vp];
new_line_pos_2 = [roi_line_mp;roi_line_mp-vp];

roi_line_2 = drawline('Position',new_line_pos_1);
roi_line_3 = drawline('Position',new_line_pos_2);

roi_line_2_mode = improfile(sceneImage,new_line_pos_1(:,1),new_line_pos_1(:,2));
roi_line_3_mode = improfile(sceneImage,new_line_pos_2(:,1),new_line_pos_2(:,2));

if mode(roi_line_2_mode) == 1
    roi_normal_line_pos = new_line_pos_1;
    roi_normal_line = roi_line_2;
    roi_normal_line_pos = [roi_line_mp;roi_line_mp+(vp*2)];
elseif mode(roi_line_3_mode) == 1
    roi_normal_line_pos = new_line_pos_2;
    roi_normal_line = roi_line_3;
    roi_normal_line_pos = [roi_line_mp;(roi_line_mp-(vp*5))];
else
    warning('Did not work');
    return
end

current_lines = findobj(gca,'Type','images.roi.line');
delete(current_lines);
try
    roi_normal_line = drawline('Position',roi_normal_line_pos);
catch
    warning('Could not draw line');
end
roi_normal_line_profile = improfile(sceneImage,roi_normal_line_pos(:,1),roi_normal_line_pos(:,2));

last_one = find(roi_normal_line_profile,1,'last')
% BW2 = bwmorph(sceneImage,'remove');
% figure
% imshow(BW2)