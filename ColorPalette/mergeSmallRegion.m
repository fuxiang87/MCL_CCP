function [ newlabel_map] = mergeSmallRegion( newlabel_map, long_conts_map, lab_data, seg_obj, areaTH, boolMergeSmall )
%% Merge small regions
maxlabel = max(newlabel_map(:));

% sort the area of segments, starting from small segment
[~, seg_idx]=sortrows([{seg_obj.area}', {seg_obj.dist}'],[1,2]);
for l = 1:maxlabel
    % if the segment is small, merge it to the most similar one in the neighbors
    if seg_obj(seg_idx(l)).isLarge == 0
        mergefrom_label = seg_idx(l);

        % current small segment
        cur_reg = newlabel_map == mergefrom_label;
        cur_lab = mean(lab_data(cur_reg,:),1);

        % neighbor segments
        neighb_reg = imdilate(cur_reg,se_disk(1)) - cur_reg;
        neighb_reg = neighb_reg & ~(long_conts_map);
        neighb_label = newlabel_map(neighb_reg(:)==1);
        
        if sum(neighb_reg(:)) > 0
            if length(unique(neighb_label(:))) > 1
                neighb_lab = lab_data(neighb_reg(:)==1,:);
                [neighb_lab,neighb_label] = grpstats(neighb_lab,neighb_label,{'mean','gname'});
                neighb_label = cellfun(@str2num,neighb_label);
                
                % find the most similar neighbor
                Dist = zeros(1,length(neighb_label));
                for i = 1:length(neighb_label)
                    if boolMergeSmall
                        if seg_obj(neighb_label(i)).isLarge == 0 || seg_obj(neighb_label(i)).isLarge == 1
                            Dist(1,i) = sum((cur_lab - neighb_lab(i,:)).^2, 2);
                        else
                            Dist(1,i) = intmax;
                        end
                    else
                        Dist(1,i) = sum((cur_lab - neighb_lab(i,:)).^2, 2);
                    end
                end
                [minval, neighb_i] = min(Dist, [], 2);
                if boolMergeSmall
                    if minval < 100
                        mergeto_label = neighb_label(neighb_i);
                    else
                        continue;
                    end    
                else
                    mergeto_label = neighb_label(neighb_i);
                end
            elseif length(unique(neighb_label(:))) == 1
                mergeto_label = unique(neighb_label(:));
                if boolMergeSmall
                    if seg_obj(mergeto_label).isLarge == 2
                        continue;
                    end
                    neighb_lab = mean(lab_data(neighb_reg(:)==1,:),1);
                    minval = sum((cur_lab - neighb_lab).^2, 2);
                    if minval >= 100
                        continue;
                    end
                end                
            end

            % merge and update
            newlabel_map(newlabel_map==mergefrom_label) = mergeto_label;
            seg_obj(mergeto_label).list = [seg_obj(mergeto_label).list; seg_obj(mergefrom_label).list];
            seg_obj(mergeto_label).area = seg_obj(mergeto_label).area + seg_obj(mergefrom_label).area;
            if seg_obj(mergeto_label).area >= areaTH.large
                seg_obj(mergeto_label).isLarge = 2;
            elseif seg_obj(mergeto_label).area >= areaTH.small && seg_obj(mergeto_label).area < areaTH.large
                seg_obj(mergeto_label).isLarge = 1;
            end

            seg_obj(mergefrom_label).list = [];
            seg_obj(mergefrom_label).area = intmax;
            seg_obj(mergefrom_label).isLarge = -1;
            seg_obj(mergefrom_label).dist = realmax;
        end
    end
end
newlabel_map = cleanupregions(newlabel_map, 0, 4);

%seg_obj = calSegObj(newlabel_map, long_conts_map, lab_data, areaTH);

end