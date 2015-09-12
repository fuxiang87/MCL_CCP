function [ newlabel_map, seg_obj ] = aggreg_regions( label_map, img, long_conts_map, lab_data, areaTH )
%AGGREG_REGIONS fine-tunes the segmentation by three post-processing techniques
% (1) Leakage Avoidance by Contours
%     Partition the region that are separated by long contour
% (2) Fake Boundary Removal
%     Check each common boundary between two adjacent regions
% (3) Small Region Mergence
%     Check each small region with area less than areaTH.small
% Input:
%   label_map:      width*height,       initial labels
%   img:            width*height,       color image in rgb for display
%   long_conts_map: width*height,       binary long contour map
%   lab_data:       (width*height)*3,	lab data for each pixel
%   areaTH:         .large, .small      >= large(stable segments), < small (segments to be cleaned)
% Output:
%   newlabel_map:	width*height,       updated labels
%   seg_obj:        num_segments*1,     segmentation structure

%% seg_obj: segmentation structure
% 	.list      indices of pixels for each segment
%	.area      area for each segment (4-connect), intmax (invalid)
%	.isLarge   2 (large area), 1 (middle area), 0 (small area), -1 (invalid)
%	.dist      the closest distance to the neighbor segments, realmax (invalid)

% For fake boundary removal: if the ratio of the long contours on the
% common boundary is below merge_TH, these two regions will be merged 
merge_TH = 0.1;

%% Step 1: Leakage Avoidance by Contours
[newlabel_map] = avoidLeakage(label_map, long_conts_map, lab_data, areaTH);

%% Step 2: Fake Boundary Removal
[newlabel_map, seg_obj] = removeFakeBoundary(newlabel_map, long_conts_map, lab_data, areaTH, merge_TH, 0.5);

%% Step 3: Small Region Mergence
[newlabel_map] = mergeSmallRegion(newlabel_map, long_conts_map, lab_data, seg_obj, areaTH, 1);

%% Step 4: Fake Boundary Removal
[newlabel_map, seg_obj] = removeFakeBoundary(newlabel_map, long_conts_map, lab_data, areaTH, merge_TH, 0.3);

%% Step 5: Small Region Mergence
[newlabel_map] = mergeSmallRegion(newlabel_map, long_conts_map, lab_data, seg_obj, areaTH, 0);

%% Step 6: Fake Boundary Removal
[newlabel_map, seg_obj] = removeFakeBoundary(newlabel_map, long_conts_map, lab_data, areaTH, merge_TH, 0.25);
%[bound_segment, color_segment] = display_color_seg(img, newlabel_map(:));
%figure, imshow(bound_segment);
%figure, imshow(color_segment);

end

%% Leakage Avoidance: Split the region that are separated by long contour
function [ newlabel_map ] = avoidLeakage( newlabel_map, long_conts_map, lab_data, areaTH )

maxlabel = max(newlabel_map(:));

seg_obj = struct;
for l = 1:maxlabel
    % current segment
    cur_reg = newlabel_map == l;
    tmp_reg = cur_reg & ~(long_conts_map);
    CC = bwconncomp(tmp_reg,4);
    if CC.NumObjects > 1        
        for idx_CC = 2:CC.NumObjects
            maxlabel = maxlabel + 1;
            newlabel_map(CC.PixelIdxList{idx_CC}) = maxlabel;
        end
        tmp_cont = cur_reg & long_conts_map;
        CC_ct = bwconncomp(tmp_cont,8);
        for idx_CC_ct = 1:CC_ct.NumObjects
            maxlabel = maxlabel + 1;
            newlabel_map(CC_ct.PixelIdxList{idx_CC_ct}) = maxlabel;
        end        
    end
    cur_reg = newlabel_map == l;
    cur_lab = mean(lab_data(cur_reg,:));
    
    seg_obj(l).list = find(cur_reg);
    seg_obj(l).area = sum(cur_reg(:));
    if seg_obj(l).area >= areaTH.large
        seg_obj(l).isLarge = 2;
        seg_obj(l).dist = realmax;
        l = l + 1;
        continue;
    elseif seg_obj(l).area < areaTH.small
        seg_obj(l).isLarge = 0;
    else
        seg_obj(l).isLarge = 1;  
    end
    
    % neighbor segments
    neighb_reg = imdilate(cur_reg,se_disk(1)) & ~cur_reg;
	neighb_reg = neighb_reg & ~long_conts_map;
    neighb_label = newlabel_map(neighb_reg(:)==1);
    
    if length(unique(neighb_label(:))) > 1
        neighb_lab = lab_data(neighb_reg(:)==1,:);
        [neighb_lab,neighb_label] = grpstats(neighb_lab,neighb_label,{'mean','gname'});
        neighb_label = cellfun(@str2num,neighb_label);

        % find the closest distance to the neighbor segments
        Dist = zeros(1,length(neighb_label));
        for i = 1:length(neighb_label)
            Dist(1,i) = sum((cur_lab - neighb_lab(i,:)).^2, 2);
        end
        seg_obj(l).dist = min(Dist, [], 2);
    elseif length(unique(neighb_label(:))) == 1
        neighb_lab = mean(lab_data(neighb_reg(:)==1,:));
        Dist = sum((cur_lab - neighb_lab).^2, 2);
        seg_obj(l).dist = Dist;
    else
        seg_obj(l).dist = realmax;
    end
end

newlabel_map = cleanupregions(newlabel_map, 0, 4);

%seg_obj = calSegObj(newlabel_map, long_conts_map, lab_data, areaTH);

end
