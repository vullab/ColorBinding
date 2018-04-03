%% Basic Colorbinding Analysis
% Converting Corey's basicAna.R code to Matlab...because I hate R
% v2-For all stimuli types
close all
clear all
fclose all;
clc;
set(0,'defaultlinelinewidth',2)

%% Parse data

colors=[255,60,160; ... Pink
    255,255,255; ... White	
    50,50,50; ... Grey 	
    255,0,0; ... Red 	
    0,160,0; ... Green	
    0,0,225; ... Blue	
    0,255,255; ... Cyan	
    70,0,50; ... Magenta	
    255,255,0; ... Yellow 	
    160,69,19]; % Brown

% Gather data files
allFiles=dir();
fNames={};
for fi=1:length(allFiles)
    if length(allFiles(fi).name)>4 && allFiles(fi).name(length(allFiles(fi).name)-4)=='1'
        fNames{length(fNames)+1}=allFiles(fi).name;
    end
end

% Gather data
% h is outside, v is inside
% 1) ms-precue- 0, no precue
% 2) resp-v-hv- Did you select an h (1) color or a v (2) color? (2 is correct)
% 3) ms-st-cue- 400 ms,
% 4) nitems- 22 items
% 5) resp-h-pos- Response for first component (0 is correct,numbers are relative position)
% 6) actualStimOn- True stim duration time (I think this is in seconds
% 7) resp-v-pos- Response for second component (0 is correct,numbers are relative position)
% 8) ms-stimon- 94 ms
% 9) resp-h-hv- Did you select an h (1) color or a v (2) color? (1 is correct)
% 10) cue-loc-int- Cued item position (integer)
% 11) cue-loc-x- Cue location x (actual spatial position)
% 12) cue-loc-y- Cue location y (actual spatial position)
% 13) radius- 5.3
% 14) bars-or-spot- 0, basic spots
% 15) npractice- 5
% 16) ntrials- 400
% 17) offsett- -10.5

a=[];
stimtype={'Cross','Bullseye','T','Stack Box'};
setLabels={'resp-h-hv','resp-v-hv','resp-h-pos','resp-v-pos','cue-loc-int','refi'};
if ~exist('parsedDataV2.mat')
    allData=cell(1,length(stimtype));
    allComps=cell(2,length(stimtype));
    numSubjs=zeros(1,length(stimtype));
    times=nan(50,length(stimtype),3);
    tempCount=0;
    for fi=1:length(fNames)
        
        try
            [hComps vComps]=convert_csv_sc2(fNames{fi}); % Cut out color arrays
            newName=fNames{fi};
            newName(length(newName)-4)='2';
            
            fid=fopen(newName);
            labels=fgets(fid);
            labels=strsplit(labels,',');
            
            fiData=csvread(newName,1,0);
            fclose all;
            if size(fiData,1)>=200
                
                % Identify version number
                version=fiData(1,strcmp('version',labels));
                if version==5
                    version=1;
                elseif version==6
                    version=2;
                end
                
                
                orgData=nan(size(fiData,1),length(setLabels));
                for i=1:length(setLabels)
                    orgData(:,i)=fiData(:,find(strcmp(setLabels{i},labels)));
                end
                
                allData{version+2}=cat(3,allData{version+2},orgData);
                allComps{1,version+2}=cat(3,allComps{1,version+2},hComps);
                allComps{2,version+2}=cat(3,allComps{2,version+2},vComps);
                numSubjs(version+2)=numSubjs(version+2)+1;
                times(numSubjs(version+2),version+2,1)=fiData(1,strcmp('ms-st-cue',labels));
                times(numSubjs(version+2),version+2,2)=fiData(1,strcmp('ms-precue',labels));
                times(numSubjs(version+2),version+2,3)=fiData(1,strcmp('ms-stimon',labels));
                %
                %             if size(fiData,2)==17
                %                 version=fiData(1,find(strcmp('bars-or-spot',labels)));
                %             elseif size(fiData,2)<=20 && sum(strcmp('version',labels))==0
                %                 version=fiData(1,find(strcmp('bars-or-spot',labels)));
                %
                %             end
            end
            delete(newName)
        catch
            excludeData(fi)=1;
        end
        
    end
    
    save('parsedDataV2.mat','fNames','numSubjs','allData','times','allComps')
else
    load('parsedDataV2.mat')
end

%% Probability of selecting a given position and component
% Do people sample over space?

allRes=cell(1,length(allData));
hitRate=zeros(2,length(allData));
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
    end
    
    allRes{ci}={vComp hComp};
    figure
    set(gcf,'color','w');
    subplot(1,2,1)
    title(strcat(stimtype{ci},': V-Comp'))
    hold on
    errorbar(-2:2,mean(vComp(1,:,:),3),std(vComp(1,:,:),0,3)./sqrt(length(fNames)),'b')
    errorbar(-2:2,mean(vComp(2,:,:),3),std(vComp(2,:,:),0,3)./sqrt(length(fNames)),'r')
    xlim([-2.5 2.5])
    hold off
    
    subplot(1,2,2)
    title(strcat(stimtype{ci},': H-Comp'))
    hold on
    errorbar(-2:2,mean(hComp(1,:,:),3),std(hComp(1,:,:),0,3)./sqrt(length(fNames)),'b')
    errorbar(-2:2,mean(hComp(2,:,:),3),std(hComp(2,:,:),0,3)./sqrt(length(fNames)),'r')
    xlim([-2.5 2.5])
    legend('Outer','Inner')
    hold off
    
    disp(strcat(stimtype{ci}))
    disp(strcat('Num. Subj: ',num2str(size(currCond,3))))
    disp(strcat('Hit Rate: ',num2str(hitRate(1,ci)/hitRate(2,ci))))
end


%% Color switching reports

colReport=cell(1,length(allData));
colReport2=cell(1,length(allData));

% For given subject the matrix is Reports for h(hv) by Reports for v(hv)
for ci=1:length(allData)
    currCond=allData{ci};
    
    tempCR=nan(10,10,size(currCond,3));
    tempCR2=nan(10,10,size(currCond,3));
    % For each subject
    for si=1:size(currCond,3)
        % For vcomp
        % What component did you select?
        vCompSel=currCond(:,2,si)==1; % selected h
        vPosData=currCond(:,4,si);
        
        % For the v-component did you select an h-comp (1:5) or a v-comp(6:10)?
        vAll=nan(size(vPosData));
        vAll(vCompSel)=vPosData(vCompSel)+3;
        vAll(~vCompSel)=vPosData(~vCompSel)+8;
        
        % For hComp
        % What component did you select?
        hCompSel=currCond(:,1,si)==1; % selected h
        hPosData=currCond(:,3,si);
        
        % For the h-component did you select an h-comp (1:5) or a v-comp(6:10)?
        hAll=nan(size(hPosData));
        hAll(hCompSel)=hPosData(hCompSel)+3;
        hAll(~hCompSel)=hPosData(~hCompSel)+8;
        
        % Count matrix
        cr=zeros(10,10,length(hAll));
        for ti=1:length(hAll)
           cr(hAll(ti),vAll(ti),ti)=1; 
        end
        tempCR(:,:,si)=mean(cr,3);
        tempCR2(:,:,si)=sum(cr,3);
    end
    colReport{ci}=tempCR;
    colReport2{ci}=tempCR2;
    
    figure
    set(gcf,'color','w');
    imagesc(log(mean(tempCR,3)));
    colormap(gray(256))
    title(stimtype{ci})
    ylabel('H-Component')
    xlabel('V-Component')
end

%% Did subjects localize colors without binding them to specific parts?
% In Vul and Rich 2010, they found that recall of two features (letter and
% color) were independent. Were they independent here? Maybe because
% they're in the same dimension. So basically, was there spatially
% dependent color sampling?

% Measure covariance
covLoc=nan(3,5); % h-var, y-var, co-var
for ci=1:length(allData)
    currCond=allData{ci};
    allTrials=reshape(currCond,400*size(currCond,3),6);
    
    % For each component, what location did people sample from?
    temph=squeeze(currCond(:,3,:));
    temph=temph(:);
    tempv=squeeze(currCond(:,4,:));
    tempv=tempv(:);
    tempCov=cov(temph,tempv);
    covLoc(:,ci)=[var(temph) var(tempv) tempCov(1,2)];

end

% Colors are not being bound to locations.

%% Model fit
startParam=[.1 .15 .15 .3 .3 .5 .8 .8 1.5 1.5 0];
for ci=1:length(stimtype)
    currCount=sum(colReport2{ci},3);
    currCount(logical(eye(10)))=0;
    quickie = @(params,currCount)(fullmodel(params,currCount));
    fx = @(params)(quickie(params,currCount));
    PAR{T} = fminsearch(fx, [0 0 0 0 0]);
    
    
end


% disp('Fitting model')
% for ci=1:length(stimtype)
%     currCount=sum(colReport2{ci},3);
%     currCount(logical(eye(10)))=nan;
%     [allParam currFit accept]=modelFit(currCount,200,1000);
%     
% end

%% Were subjects more likely to confuse similar colors?
% colDist=nan(size(colors,1),size(colors,1));
% for c1=1:size(colors,1)
%     for c2=1:size(colors,1)
%         colDist(c1,c2)=sqrt(sum((colors(c1,:)-colors(c2,:)).^2));
%     end
% end
% colDist(logical(eye(10)))=Inf;
% 
% for ci=1:length(allData)
%     currCond=allData{ci};
%        
%     % Subject x color distance rank x hv
%     colSwitch=nan(size(currCond,3),9,2);
%     
%     % For each subject
%     for si=1:size(currCond,3)
%         hComps=allComps{ci,1}(:,:,si)';
%         vComps=allComps{ci,2}(:,:,si)';
%         currComps=cat(3,hComps,vComps);
%         refhv=allData{ci}(:,5:6,si)+1;
%         correctColHV=nan(size(refhv));
%         for coli=1:size(refhv,1)
%            correctColHV(coli,:)=[currComps(refhv(coli,1),coli,1) currComps(refhv(coli,2),coli,2)];
%         end
%         
%         % For vcomp
%         % What component did you select?
%         vCompSel=currCond(:,2,si)==1; % selected h
%         vPosData=currCond(:,4,si);
% 
%     end
% end





