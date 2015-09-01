function out_img = bilateral_filter_color(in_img,w,sigma_c,sigma_s);
% matlab code for bilateral filter
% Convert input sRGB image to CIELab color space.
in_img = colorspace('Lab<-RGB',in_img);
% Pre-compute Gaussian distance weights.
[X,Y] = meshgrid(-w:w,-w:w);
C = exp(-(X.^2+Y.^2)/(2*sigma_c^2));
% Rescale range variance (using maximum luminance).
% sigma_s = 100*sigma_s;
% Apply bilateral filter.
[m,n,c] = size(in_img);
out_img = zeros(m,n,c);
for i = 1:m
   for j = 1:n
       % Extract local region.
       I = in_img(max(i-w,1):min(i+w,m),max(j-w,1):min(j+w,n),:);
       % Compute Gaussian intensity weights.
       dL = I(:,:,1)-in_img(i,j,1);
       da = I(:,:,2)-in_img(i,j,2);
       db = I(:,:,3)-in_img(i,j,3);
       S = exp(-(dL.^2+da.^2+db.^2)/(2*sigma_s^2));
       
       % Calculate bilateral filter response.
       F = S.*C((max(i-w,1):min(i+w,m))-i+w+1,(max(j-w,1):min(j+w,n))-j+w+1);  
       out_img(i,j,1) = sum(sum(F.*I(:,:,1)))/sum(F(:));
       out_img(i,j,2) = sum(sum(F.*I(:,:,2)))/sum(F(:));
       out_img(i,j,3) = sum(sum(F.*I(:,:,3)))/sum(F(:));
   end
end
% Convert filtered image back to sRGB color space.
out_img = colorspace('RGB<-Lab',out_img); 