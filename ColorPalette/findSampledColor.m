function [ long_conts_map, sampledColor ] = findSampledColor( lab_img, edgelist, lengthTH )
%FINDCOLORPALETTE finds long contours map and sampled colors for color palette given edge list
% Input:
%   lab_img:        height*width*3,     color image in lab space
%   edgelist:       1*num_edges,        (r,c) locations for each edge
%   lengthTH:       const,              long contours are the edges with length longer than this TH
% Output:
%   long_conts_map: height*width,       long contours map
%	sampledColor:   num_color*3,        sampled colors in lab space

[H,W,C] = size(lab_img);
lab_data = reshape(lab_img,H*W,C);

% find long contours and sampled color
long_conts_map = false(H,W);
sampledColor = [];
tmp = 1;
for i = 1:length(edgelist)
    if size(edgelist{i},1) > lengthTH
        long_cont_map = false(H,W);
        corner_map = false(H,W);
        
        edgelist{tmp} = edgelist{i};
        tmp = tmp + 1;
        % locations for each long contour and two corners
        long_cont_map(edgelist{i}(:,1) + (edgelist{i}(:,2)-1)*H) = true;
        corner_map(edgelist{i}([1;end],1) + (edgelist{i}([1;end],2)-1)*H) = true;
        long_conts_map = long_conts_map | long_cont_map;
        
        % neigbhor samples
        neighb_edge = (imdilate(long_cont_map,se_disk(2)) - imdilate(long_cont_map,se_disk(1))) & ~imdilate(corner_map,se_disk(2));
        
        % each side of the contour
        CC = bwconncomp(neighb_edge==1,8);
        for idx_CC = 1:CC.NumObjects
            side_map = false(H,W);
            side_map(CC.PixelIdxList{idx_CC}) = true;
            if sum(side_map(:)) < 10
                continue;
            end
            sidelist = edgelink(side_map);
            idx_side = 1; max_side = size(sidelist{1},1);
            for s = 2:length(sidelist)
                if size(sidelist{s},1) > max_side
                    idx_side = s;
                    max_side = size(sidelist{s},1);
                end
            end
                        
            lablist = lab_data(sidelist{idx_side}(:,1) + (sidelist{idx_side}(:,2)-1)*H,:);
            labdiff = sum((lablist(2:end,:) - lablist(1:end-1,:)).^2, 2);
            
            % find large jumps along the contour
            cut_point = [0, find(labdiff' > 1000), length(labdiff)+1];
            for s = 1:length(cut_point)-1
                if cut_point(s+1) - cut_point(s) > lengthTH
                    sampledColor = [sampledColor;repmat(mean(lablist(cut_point(s)+1:cut_point(s+1),:)),cut_point(s+1) - cut_point(s),1)];
                end
            end
        end
    end
end

end

