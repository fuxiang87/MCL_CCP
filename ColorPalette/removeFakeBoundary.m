function [ newlabel_map, seg_obj ] = removeFakeBoundary( newlabel_map, long_conts_map, lab_data, seg_obj, areaTH, merge_TH, bdRatio )
%% Remove fake boundaries
% mergeTH: if the ratio of the long contours on the common boundary is 
%          below merge_TH, these two regions will be merged
% bdRatio: significance of the common boundary,
%          which is the ratio of the length of the common boundary and the
%          minimum perimeter of the two regions

[Am, Al] = regionadjacency(newlabel_map, 4);
mapping = 1:length(Al);
label_1 = []; label_2 = []; diff_val = []; comm_val = [];
for l = 1:length(Al)
    for m = Al{l}
        if l < m
            % pair: l and m
            maskl = imdilate(newlabel_map == l, se_disk(1));
            maskm = imdilate(newlabel_map == m, se_disk(1));
            periml = sum(sum(newlabel_map == l & ~imerode(newlabel_map == l, se_disk(1))));
            perimm = sum(sum(newlabel_map == m & ~imerode(newlabel_map == m, se_disk(1))));
            combndry = maskl & maskm;
            
            den = sum(combndry(:))/2;
            nom = combndry.*long_conts_map;
            
            label_1 = [label_1;l];
            label_2 = [label_2;m];
            diff_val = [diff_val;sum(nom(:))/den];
            comm_val = [comm_val;den/min(periml,perimm)];            
        end
    end
end
[val,order_idx] = sort(comm_val(:),'descend');
for i = order_idx(val>bdRatio)'
    l = label_1(i);
    m = label_2(i);
	
	if diff_val(i) < merge_TH
		% merge m to l
		if seg_obj(l).area > seg_obj(m).area
			seg_obj(l).area = seg_obj(l).area + seg_obj(m).area;
			mapping(mapping==m) = l;
		% merge l to m
		else
			seg_obj(m).area = seg_obj(m).area + seg_obj(l).area;
			mapping(mapping==l) = m;
        end
	end
end

newlabel_map = mapping(newlabel_map);
newlabel_map = cleanupregions(newlabel_map, 0, 4);

seg_obj = calSegObj(newlabel_map, long_conts_map, lab_data, areaTH);

end

