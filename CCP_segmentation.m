% This code is to implement contour-guided color palette segmentation method described in:
% "Robust Image Segmentation Using Contour-guided Color Palettes" 
% by Xiang Fu, Chien-Yi Wang, Chen Chen, Changhu Wang, and C.-C. Jay Kuo. ICCV 2015
% {xiangfu, chienyiw, chen80}@usc.edu, chw@microsoft.com, cckuo@sipi.usc.edu
%
% Please contact the corresponding author if you have any questions.
% Xiang Fu: xiangfu AT usc DOT edu or fuxiang87 AT gmail DOT com

%%% Contour-guided Color Palette Segmentation
clear all; close all; clc;

addpath(genpath('./'));
% addpath(genpath('piotr_toolbox'))
% addpath(genpath('StructuredEdgeDetection'))
% addpath 'PeterKovesi'
% addpath(genpath('others'))
% addpath 'ColorPalette'
% addpath 'MeanShift'

%% parameter setting
% parameters for downscaling
scale   = 1.0;      % downscale

% parameters for bilateral filter (denoising)
w       = 5;        % half-width
sigma_c = 5;        % standard deviations of color
sigma_s = 5;        % standard deviations of space

% parameters for edge detection
extRange = 4;       % edge extension to improve edge detection
lengthTH = 10;      % length above this number is long ontour

% parameters for mean shift (KEY parameter)
msradius = 5;       % spectral radius for mean shift on sampled color space

% parameters for region cleaning
areaTH.large = 500; % area above this number is large region
areaTH.small = 200; % area blow this number is small region

%% read color image
img_name = '8068.jpg';
ori_img  = imread(img_name);
ori_img = imresize(ori_img, scale); % scale the image
[H,W,C] = size(ori_img);
figure, imshow(ori_img);

%% image denoising (shiftableBF for O(1) version)
lab_img = colorspace('Lab<-', ori_img);
Lcolumn = lab_img(:,:,1); % [  0 - 100]
Acolumn = lab_img(:,:,2); % [-50 -  50]
Bcolumn = lab_img(:,:,3); % [-50 -  50]
%Lcolumn = bilateral_filter(Lcolumn,w,sigma_c,sigma_s);
Lcolumn = shiftableBF(Lcolumn,sigma_s,sigma_c,w,0.01);
lab_denoise = cat(3,Lcolumn,Acolumn,Bcolumn);
lab_data = reshape(lab_denoise,H*W,C);
rgb_denoise = colorspace('RGB<-Lab', lab_denoise);   
figure, imshow(rgb_denoise)

%% structured edge detection
%Need Piotr's Computer Vision Matlab Toolbox
setParametersSED;
edge_map = edgesDetect(ori_img,model);
figure, imshow(1-edge_map);
% edge extension
bin_edge_map = edgeExtension(edge_map>0.1, extRange);
[edgelist, labelededgeim] = edgelink(bin_edge_map, lengthTH);

%% Contour-guided Color Palette
% Color Palette Generation
tic;
[long_conts_map,sampledColor] = findSampledColor(lab_denoise, edgelist, lengthTH);
t1 = toc;
figure, imshow(1-long_conts_map);

colorPalette = MeanShiftCluster(sampledColor', msradius)';
% quantized image
Dist = zeros(H*W,size(colorPalette,1));
for i = 1:size(colorPalette,1)
    Dist(:,i) = sum((lab_data - colorPalette(repmat(i,H*W,1),:)).^2, 2);
end
[~, labels] = min(Dist, [], 2);
[~, color_segment] = display_color_seg(im2double(ori_img), labels);
figure, imshow(color_segment);

tic;
% Post-Processing
label_map = reshape(labels,H,W);%cleanupregions(reshape(labels,H,W), 0, 4);
[newlabel_map,seg_obj] = aggreg_regions(label_map, rgb_denoise, long_conts_map, lab_data, areaTH);
[bound_segment, color_segment] = display_color_seg(im2double(ori_img), newlabel_map(:));
figure, imshow(color_segment);
t2 = toc;