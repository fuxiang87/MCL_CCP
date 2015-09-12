%A MATLAB Toolbox
%
%Compare two segmentation results using Segmentation Covering
% based on PASCAL evaluation code:
% http://pascallin.ecs.soton.ac.uk/challenges/VOC/voc2010/index.html#devkit
%
%IMPORTANT: The two input images must have the same size!
%
%Authors: John Wright, and Allen Y. Yang
%Contact: Allen Y. Yang <yang@eecs.berkeley.edu>
%
%(c) Copyright. University of California, Berkeley. 2007.
%
%Notice: The packages should NOT be used for any commercial purposes
%without direct consent of their author(s). The authors are not responsible
%for any potential property loss or damage caused directly or indirectly by the usage of the software.

function [cov]=compare_covering(seg,groundTruth)

% compare_covering
%
%   Computes several simple segmentation benchmarks. Written for use with
%   images, but works for generic segmentation as well (i.e. if the
%   sampleLabels inputs are just lists of labels, rather than rectangular
%   arrays).
%
%   The measures:
%       Segmentation Covering
%
%
%   Oct. 2006 
%       Questions? John Wright - jnwright@uiuc.edu

nsegs = numel(groundTruth);
if nsegs == 0,
    error(' bad gtFile !');
end

regionsGT = [];
total_gt = 0;
for s = 1 : nsegs
    groundTruth{s}.Segmentation = double(groundTruth{s}.Segmentation);
    regionsTmp = regionprops(groundTruth{s}.Segmentation, 'Area');
    regionsGT = [regionsGT; regionsTmp];
    total_gt = total_gt + max(groundTruth{s}.Segmentation(:));
end

[matches ] = match_segmentations(seg, groundTruth);
matchesSeg = max(matches, [], 2);
matchesGT = max(matches, [], 1);

cntP = 0; sumP = 0; cntR = 0; sumR = 0;
regionsSeg = regionprops(seg, 'Area');
for r = 1 : numel(regionsSeg)
    cntP = cntP + regionsSeg(r).Area*matchesSeg(r);
    sumP = sumP + regionsSeg(r).Area;
end

for r = 1 : numel(regionsGT),
    cntR = cntR + regionsGT(r).Area*matchesGT(r);
    sumR = sumR + regionsGT(r).Area;
end

% if cntP/sumP > cntR/sumR,
% 	cov = cntP/sumP;
% else
% 	cov = cntR/sumR;
% end

cov = (cntP/sumP + cntR/sumR)/2;