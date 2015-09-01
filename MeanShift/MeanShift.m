
 function [numclust,clusters,centerindex] = MeanShift(dataPts,sigma,clustertol);

%   clear all;clc;
% load('testdatainfo.mat');
% dataPts = testdata;
% sigma = 0.3;
%  dataPts=[2 1;1 3;6 7;4 7;5 7;1.5,2];
%  sigma=1;
%  clustertol=0.1;

[numPts,numDim] = size(dataPts);
tol=1e-4;

% sigma2=2*sigma*sigma;
p=zeros(1,numPts);
newp=zeros(1,numPts);
beenvistedFlag=zeros(1,numPts);
initPtInds      = 1:numPts;
distc = zeros(numPts,1);
gausskernel=zeros(1,numPts);
newgausskernel=zeros(1,numPts);
for n=1:numPts                                             %Mean shift
    x=dataPts(n,:);
    for i=1:numPts
        distance(i)=norm((x-dataPts(i,:))/sigma).^2;
        gausskernel(i)=exp(-distance(i)/2);
        %p(i)=gausskernel(i)/sum(gausskernel);
    end
    sumgauss=sum(gausskernel);
    for j=1:numPts
        p(j)=gausskernel(j)/sumgauss;
    end
    x=p*dataPts;
    error=realmax;
    while error>tol
        
        oldx=x;
        for i=1:numPts
        newdistance(i)=norm((x-dataPts(i,:))/sigma).^2;
        newgausskernel(i)=exp(-newdistance(i)/2);
%         newp(i)=newgausskernel(i)/sum(newgausskernel);
        end
        sumnewgauss=sum(newgausskernel);
        for j=1:numPts
            newp(j)=newgausskernel(j)/sum(newgausskernel);
        end
        newx=newp*dataPts;
        x=newx;
        error=norm(newx-oldx);
    end
    z(n,:)=x;
    
%     ind = sprintf('%d', n);
%     disp(ind);
   
end
% disp(z);
% cluster based on the result of the meanshift
clusters={};
clustersdata={};
numclust=0;
numInitPts=numPts;
cycle=0;
while numInitPts
    tempInd         = ceil( (numInitPts-1e-6)*rand) ;      %pick a random seed point
    stInd           = initPtInds(tempInd); %use this point as start of mean
    
    y=z(stInd,:);

    yy=repmat(y,numInitPts,1);
 
    %distc=sum((yy-dataPts).^2,2);

    distc=sum((yy-z(initPtInds,:)).^2,2);
    %[mindist,minindex]=min(distc);
      
       tempindclust=find(distc<clustertol);
       indclust=initPtInds(tempindclust);
       if length(indclust(:))==0
           break;
       else
       beenvistedFlag(indclust)=1;
       initPtInds      = find(beenvistedFlag == 0);           %we can initialize with any of the points not yet visited
       numInitPts      = length(initPtInds(:)) ;              %number of active points in set  
        numclust        =numclust+1;
      
       clusters{numclust}=indclust;
       clustersdata{numclust}=dataPts(indclust,:);
        end
  cycle=cycle+1;
%   ss_disp = sprintf('cycle = %d',cycle);
%   disp(ss_disp);
end
  
  numcell = length(clusters);
     
  celldisp(clusters);
     %find the center of the corresponding clusters
    for i=1:numcell
         tempnum=length(clusters{i});%the size of the i'st 
        cluster_i=clusters{i};
        clustersdata_i=clustersdata{i};
        [numdata,numdim]=size(clustersdata_i);
        
        clustermean=mean(clustersdata_i,1);
    

        tempdist=dist(clustersdata_i,clustermean');
        [tempdata,tempindex]=min(tempdist);
        centerindex(i)=cluster_i(tempindex);
        centerdata(i,:)=clustersdata_i(tempindex,:);
    end
      for i=1:numcell
          templength=length(clusters{i});
          if templength<9
              centerindex(i)=0;
          end
      end
         disp(centerindex);
%     disp(centerdata);
%     celldisp(clustersdata);