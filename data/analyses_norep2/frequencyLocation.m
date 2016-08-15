function [allRes hitRate correct]=frequencyLocation(allData,stimtype,dispRes)

%% Probability of selecting a given position and component
% Do people sample over space?

allRes=cell(1,length(allData));
hitRate=zeros(2,length(allData));
correct=zeros(2,5,length(allData));
% For each condition
for ci=1:length(allData)
    currCond=allData{ci};
    
    hComp=nan(2,5,size(currCond,3));
    vComp=nan(2,5,size(currCond,3));
    hComp2=nan(2,5,size(currCond,3));
    vComp2=nan(2,5,size(currCond,3));
    % For each subject
    for si=1:size(currCond,3)
        % For vcomp
        % What component did you select?
        vCompSel=currCond(:,2,si)==1; % selected h
        vPosData=currCond(:,4,si);
        
        % For v trials in which you selected the h component, what position
        % was that component?
        vselPosH=vPosData(vCompSel);
        [vselPosHCounts]=hist(vselPosH,5);
        
        
        % For v trials in which you selected the v component, what position
        % was that component?
        vselPosV=vPosData(~vCompSel);
        [vselPosVCounts]=hist(vselPosV,5);
        
        vComp(1,:,si)=vselPosHCounts/sum([vselPosHCounts vselPosVCounts]);
        vComp(2,:,si)=vselPosVCounts/sum([vselPosHCounts vselPosVCounts]);
        
        % For hComp------------------------------------------------------------
        % What component did you select?
        hCompSel=currCond(:,1,si)==1; % selected h
        hPosData=currCond(:,3,si);
        
        % For h trials in which you selected the h component, what position
        % was that component?
        hselPosH=hPosData(hCompSel);
        [hselPosHCounts]=hist(hselPosH,5);
        
        
        % For h trials in which you selected the v component, what position
        % was that component?
        hselPosV=hPosData(~hCompSel);
        [hselPosVCounts]=hist(hselPosV,5);
        
        hComp(1,:,si)=hselPosHCounts/sum([hselPosHCounts hselPosVCounts]);
        hComp(2,:,si)=hselPosVCounts/sum([hselPosHCounts hselPosVCounts]);
        
        hits=sum((currCond(:,2,si)==2 & currCond(:,4,si)==0 ) & (currCond(:,1,si)==1 & currCond(:,3,si)==0 ));
        hitRate(:,ci)=hitRate(:,ci)+[hits;size(currCond,1)];
        %disp(hits/size(currCond,1))
        
        correct(1,:,ci)=correct(1,:,ci)+vselPosVCounts+hselPosHCounts;
        correct(2,:,ci)=correct(2,:,ci)+hselPosVCounts+hselPosVCounts;
        
    end
    correct(:,:,ci)=correct(:,:,ci)./sum(sum(correct(1,:,ci)));
    
    allRes{ci}={vComp hComp};
    if dispRes
        disp(strcat(stimtype{ci}))
        disp(strcat('Num. Subj: ',num2str(size(currCond,3))))
        disp(strcat('Hit Rate: ',num2str(hitRate(1,ci)/hitRate(2,ci))))
    end
end