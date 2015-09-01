function [ seg_obj ] = calSegObj( newlabel_map, long_conts_map, lab_data, areaTH )
%% Calculate seg_obj
maxlabel = max(newlabel_map(:));
seg_obj = struct;
for l = 1:maxlabel
    % current segment
    cur_reg = newlabel_map == l;
    cur_lab = mean(lab_data(cur_reg,:),1);
    
    seg_obj(l).list = find(cur_reg);
    seg_obj(l).area = sum(cur_reg(:));
    if seg_obj(l).area >= areaTH.large
        seg_obj(l).isLarge = 2;
        seg_obj(l).dist = realmax;
        continue;
    elseif seg_obj(l).area < areaTH.small
        seg_obj(l).isLarge = 0;
    else
        seg_obj(l).isLarge = 1;
    end
    
    % neighbor segments
    neighb_reg = imdilate(cur_reg,se_disk(1)) - cur_reg;
    neighb_reg = neighb_reg & ~(long_conts_map);
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

end