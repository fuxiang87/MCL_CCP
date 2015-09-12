function out_vals = eval_segmentation(label_img,gt_imgs)

% Five metrics are used: Cov, PRI, VoI, GCE, and BDE

out_vals.PRI = 0; out_vals.VoI = 0; out_vals.GCE = 0; out_vals.BDE = 0;
for i=1:size(gt_imgs.groundTruth,2)
    [curRI,curGCE,curVOI] = compare_segmentations(label_img,double(gt_imgs.groundTruth{i}.Segmentation));
    curBDE = compare_image_boundary_error(label_img,double(gt_imgs.groundTruth{i}.Segmentation));
    out_vals.PRI = out_vals.PRI + curRI;
    out_vals.VoI = out_vals.VoI + curVOI;
    out_vals.GCE = out_vals.GCE + curGCE;
    out_vals.BDE = out_vals.BDE + curBDE;
end
out_vals.Cov = compare_covering(label_img,gt_imgs.groundTruth);
out_vals.PRI = out_vals.PRI/size(gt_imgs.groundTruth,2);
out_vals.VoI = out_vals.VoI/size(gt_imgs.groundTruth,2);
out_vals.GCE = out_vals.GCE/size(gt_imgs.groundTruth,2);
out_vals.BDE = out_vals.BDE/size(gt_imgs.groundTruth,2);