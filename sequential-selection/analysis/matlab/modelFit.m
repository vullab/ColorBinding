function [allParam currFit]=modelFit(data,numSamps,numBurn)

totalSamp=numSamps+numBurn;

startParam=[0 0 0 0];
allParam=nan(totalSamp,length(startParam));
allParam(1,:)=startParam;


currFit=nan(totalSamp,1);
llk=fullmodel2(allParam(1,2),allParam(1,1),allParam(1,3),allParam(1,4));
currFit(1)=sum(nansum(llk(:).*data(:)));

for si=2:totalSamp
    currParams=allParam(si-1,:);
    sampParams=normrnd(currParams,.01);
    
    llk=fullmodel2(allParam(1,2),allParam(1,1),allParam(1,3),allParam(1,4));
    tempFit=sum(nansum(llk(:).*data(:)));
    
    if tempFit/currFit(si-1)>rand()
        allParam(si,:)=sampParams;
        currFit(si,:)=tempFit;
    end
    
    
end

end