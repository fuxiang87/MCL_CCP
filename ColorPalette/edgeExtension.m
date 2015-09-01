function [ bin_edge_map ] = edgeExtension( bin_edge_map, extRange )
%EDGEEXTENSION extend the binary edge to the image boundary
% Input:
%   bin_edge_map:   height*width,   binary edge map
%   extRange:       1 scaler,       extension range
% Output:
%   bin_edge_map:   height*width,   new binary edge map

[H, W] = size(bin_edge_map);

bin_edge_map = filledgegaps(bin_edge_map,1);

for i = extRange:-1:1
    bin_edge_map(i,:) = bin_edge_map(i,:) | bin_edge_map(i+1,:);
    bin_edge_map(:,i) = bin_edge_map(:,i) | bin_edge_map(:,i+1);
end
for i = H-extRange+1:H
    bin_edge_map(i,:) = bin_edge_map(i,:) | bin_edge_map(i-1,:);
end
for i = W-extRange+1:W
    bin_edge_map(:,i) = bin_edge_map(:,i) | bin_edge_map(:,i-1);
end
bin_edge_map = bwmorph(bin_edge_map,'thin',Inf);
bin_edge_map(1,:) = bin_edge_map(1,:) | bin_edge_map(2,:);
bin_edge_map(:,1) = bin_edge_map(:,1) | bin_edge_map(:,2);
bin_edge_map(end,:) = bin_edge_map(end,:) | bin_edge_map(end-1,:);
bin_edge_map(:,end) = bin_edge_map(:,end) | bin_edge_map(:,end-1);
bin_edge_map = bwmorph(bin_edge_map,'thin',Inf);

%figure, imshow(1-bin_edge_map);

end

