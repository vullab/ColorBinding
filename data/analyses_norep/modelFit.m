function [allParam currFit accept]=modelFit(data,numSamps,numBurn)
% Fit colorbinding models using mh
totalSamp=numSamps+numBurn;

% 1) P-Whole
% 2) P-Part A
% 3) P-Part B
% 4) P-Color A
% 5) P-Color B
% 6) SD Whole
% 7) SD Part A
% 8) SD Part B
% 9) SD Color A
% 10) SD Color B
% 11) Prob flip
startParam=[.1 .15 .15 .3 .3 .5 .8 .8 1.5 1.5 0];
allParam=nan(totalSamp,length(startParam));
allParam(1,:)=startParam;


currFit=nan(totalSamp,1);
llk=fullmodel(allParam(1,2),allParam(1,1),allParam(1,3),allParam(1,4));
currFit(1)=sum(nansum(llk(:).*data(:)));
accept=0;
for si=2:totalSamp
    if si==numBurn
       disp('') 
    end
    currParams=allParam(si-1,:);
    sampParams=normrnd(currParams,.5);
    
    llk=fullmodel(sampParams(1,2),sampParams(1,1),sampParams(1,3),sampParams(1,4));
    tempFit=sum(nansum((llk(:)).*data(:)));
    
    if tempFit/currFit(si-1)>rand()*.5+.5
        accept=accept+1;
        allParam(si,:)=sampParams;
        currFit(si,:)=tempFit;
    else
        allParam(si,:)=currParams;
        currFit(si,:)=currFit(si-1,:);
    end
    
    
end

end