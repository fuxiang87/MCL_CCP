function [ bound_disp, color_disp ] = display_color_seg( img, labels )
%DISPLAY_COLOR_SEG displays the segmentation in color
% Input:
%   img:        width*height*3, color image or
%               width*height, grayscale image
%   labels:     (width*height)*1, segmentation labels
% Output:
%   color_disp:	width*height*3, color display

[H, W, C] = size(img); L = max(labels);
if C > 1,
    gray_img = rgb2gray(img);
else
    gray_img = img;
end;
labels = labels(1:H*W,1);

%bound_disp = zeros(H,W,C);    for i=1:C, bound_disp(:,:,i) = gray_img; end; 
bound_disp = img;
label_img = reshape(labels,H,W); [~,~,bound_disp]=segoutput(bound_disp,label_img);

color_disp = zeros(H,W,C);
for i=1:L
    idx = find(labels==i);
    for j=1:C
        tmp = color_disp(:,:,j); tmp1 = img(:,:,j);
        tmp(idx) = mean(tmp1(idx)); 
        color_disp(:,:,j) = tmp; 
        clear tmp tmp1;
    end;
    clear idx;
end;

%% If you need a red boundaries for the segmentation result, please uncomment the code below
%[~,~,color_disp]=segoutput(color_disp,label_img);

end

