function out_img = bilateral_filter(in_img,w,sigma_c,sigma_s);
% matlab code for bilateral filter
% Pre-compute Gaussian distance weights.
[X,Y] = meshgrid(-w:w,-w:w);
C = exp(-(X.^2+Y.^2)/(2*sigma_c^2));
% Apply bilateral filter.
[m,n,c] = size(in_img);
out_img = zeros(m,n,c);
for i = 1:m
   for j = 1:n
       % Extract local region.
       I = in_img(max(i-w,1):min(i+w,m),max(j-w,1):min(j+w,n));
       % Compute Gaussian intensity weights.
       S = exp(-(I-in_img(i,j)).^2/(2*sigma_s^2));
       % Calculate bilateral filter response.
       F = S.*C((max(i-w,1):min(i+w,m))-i+w+1,(max(j-w,1):min(j+w,n))-j+w+1);
       out_img(i,j) = sum(F(:).*I(:))/sum(F(:));
   end
end