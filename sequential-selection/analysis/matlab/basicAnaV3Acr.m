%% Basic Colorbinding Analysis
% Converting Corey's basicAna.R code to Matlab...because I hate R
% v2-For all stimuli types
% v3-Using 4 parameter model, fitting to individual subjects
% Synch with basicAna3v2Subj
% v3Acr-Trying collapsing across subjects to check if replicates previous
close all
clear all
fclose all;
clc
set(0,'defaultlinelinewidth',2)

%% Parse data

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
stimtype={'Crosses','Bullseye','Eggs','Moons','Big Diff. Moons','Little Diff. Moons','Ts','Stacked boxes','Windows','Dots & Boxes','Static T','Stack T', 'Spread Box','Overlap Cross','Outlines'};
conditions2=[3.75,5,5.5,4.5,-10.5,-9];
goodVersions=[-1 0 1 2 5 6 8 9 11 12 13]; % The conditions with enough subjects
setLabels={'resp-h-hv','resp-v-hv','resp-h-pos','resp-v-pos','cue-loc-int'};
if ~exist('parsedDataV2.mat')
    allData=cell(1,15);
    numSubjs=zeros(1,15);
    times=nan(50,15,3);
    tempCount=0;
    for fi=1:length(fNames)
        
        try
            fid=fopen(fNames{fi});
            labels=fgets(fid);
            labels=strsplit(labels,',');
            fiData=csvread(fNames{fi},1,0);
            fclose all;
            if size(fiData,1)>=200
                % Regularize data structures
                labels{end+1}='subjectID';
                fiData(:,end+1)=0;
                
                if sum(strcmp('offsett',labels))>0
                    labels{strcmp('offsett',labels)}='offset';
                    labels{end+1}='offset2';
                    fiData(:,end+1)=0;
                end
                
                if size(fiData,2)==17
                    labels{end+1}='offset';
                    fiData(:,strcmp('offset',labels))=0;
                    labels{end+1}='offset2';
                    fiData(:,strcmp('offset2',labels))=0;
                    labels{end+1}='version';
                    fiData(:,strcmp('version',labels))=fiData(1,strcmp('bars-or-spot',labels))-2;
                end
                
                if size(fiData,2)<=20 & sum(strcmp('version',labels)==0)==length(labels)
                    offs=fiData(1,strcmp('offset',labels));
                    labels{end+1}='version';
                    if (offs == 3.75)
                        fiData(:,strcmp('version',labels)) = 1 ;
                        tempCount=tempCount+1;
                    elseif(offs == 5)
                        fiData(:,strcmp('version',labels)) = 2;
                    elseif(offs == 5.5)
                        fiData(:,strcmp('version',labels)) = 3;
                    elseif(offs == 4.5)
                        fiData(:,strcmp('version',labels)) = 4;
                    elseif(offs == -10.5)
                        fiData(:,strcmp('version',labels)) = 5;
                    elseif(offs == -9)
                        fiData(:,strcmp('version',labels)) = 6;
                    elseif(offs == 0)
                        print('1')
                    else
                        print('other thing')
                    end
                end
                version=fiData(1,strcmp('version',labels));
                if version==12
                   disp('') 
                end
                orgData=nan(size(fiData,1),length(setLabels));
                for i=1:length(setLabels)
                    orgData(:,i)=fiData(:,find(strcmp(setLabels{i},labels)));
                end
                if size(orgData,1)<500
                    orgData(end+1:500,:)=nan;
                end
                allData{version+2}=cat(3,allData{version+2},orgData);
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
        catch
            excludeData(fi)=1;
        end
        
    end
    
    save('parsedDataV2.mat','fNames','numSubjs','allData','times')
else
    load('parsedDataV2.mat')
end
subjGood=numSubjs>10;

%% Probability of selecting a given position and component

allRes=cell(1,length(allData));
hitRate=zeros(2,length(allData));
% For each condition
for ci=1:length(allData)
    currCond=allData{ci};
    
    hComp=nan(2,5,size(currCond,3)); 
    vComp=nan(2,5,size(currCond,3));
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
    end
    
    allRes{ci}={vComp hComp};
end

% Hit rates
% 1-4 have good hit rates
% 5, 6, 9 and 12 didn't have many subjects
% 7, 8, 10, 11, 13, 14 and 15 have high error rates
    
%% Color switching reports

colReport=cell(1,length(allData));
colReport2=cell(1,length(allData));

% For given subject the matrix is Reports for h(hv) by Reports for v(hv)
figure;set(gcf,'color','w');
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
        for ti=1:sum(~isnan(hAll))
            cr(hAll(ti),vAll(ti),ti)=1;
        end
        tempCR(:,:,si)=mean(cr,3);
        tempCR2(:,:,si)=sum(cr,3);
        
    end
    colReport{ci}=tempCR;
    colReport2{ci}=tempCR2;
    
    subplot(3,5,ci)
    imagesc(log(mean(tempCR,3)));
    colormap(gray(256))
    title(stimtype{ci})
%     ylabel('H-Component')
%     xlabel('V-Component')
end

% for fm6v2
% Basic 4 parameter model
quickie = @(params,currCount)(fullmodel6v2(params,currCount));
startParam=[.1 .15 .25 .8]; % whole, part, color, double guess
lbound=[0 0 0 0 ];
ubound=[1 1 1 inf ];
name='probSampsInd_fm6v2Acr.mat';

% % for fm7v2-Separate noise
% quickie = @(params,currCount)(fullmodel7v2(params,currCount));
% startParam=[.1 .15 .25 .5 .8 1.5]; % whole, part, color, double guess
% lbound=[0 0 0 0 0 0];
% ubound=[1 1 1 inf inf inf];
% name='probSampsInd_fm7v2Acr.mat';

% % for fm8v2-Separate probability
% quickie = @(params,currCount)(fullmodel8v2(params,currCount));
% startParam=[.1 .15 .15 .3 .3 .8]; % whole, part, color, double guess
% lbound=[0 0 0 0 0 0 ];
% ubound=[1 1 1 1 1 inf ];
% name='probSampsInd_fm8v2Acr.mat';



numSamp=40;
bcount=0;
if ~exist(name)
    params=nan(length(stimtype),length(startParam),numSamp);
    % P-Whole, P-Part_A/B, P-Color_A/B, sd_whole, sd_part,sd_color
    for ci=1:length(stimtype)
        disp(stimtype{ci})
        a=[];
        for si=1:numSamp
            e=0;
            while e==0
                % Sample subjects
                currCount=sum(colReport2{ci}(:,:,randsample(size(colReport2{ci},3),size(colReport2{ci},3),true)),3);
                
                fx = @(params2)(quickie(params2,currCount));
                [PAR_v4{ci} fval e]= fminsearchbnd(fx, startParam,lbound,ubound);
                if e==0
                    bcount=bcount+1;
                end
            end
            params(ci,:,si)=PAR_v4{ci};
            temp=PAR_v4{ci};
            %disp(temp)
            a=[a temp(1)];
            [residual mllk]=fullmodel6v2_llk(nanmean(params(ci,:,:),3),currCount);
            temp=mllk.*sum(currCount(:));
        end
        %disp(PAR_v4{ci})
    end
    save(name,'params')
else
    
    load(name)
end

figure;set(gcf,'color','w');
modllk=nan(10,10,length(stimtype));
modcounts=nan(10,10,length(stimtype));
for ci=1:length(stimtype)
    currCount=sum(colReport2{ci},3);
    if sum(isnan(nanmean(params(ci,:,:),3)))~=4
        [residual mllk]=fullmodel6v2_llk(nanmean(params(ci,:,:),3),currCount);
        modllk(:,:,ci)=mllk;
        modcounts(:,:,ci)=mllk.*sum(currCount(:));
        subplot(3,5,ci)
        imagesc(log(modcounts(:,:,ci)));
        colormap(gray(256))
        title(stimtype{ci})
    end
end

%% Get params
pWhole=params(subjGood,1,:);
pPart=params(subjGood,2,:);
pColor=params(subjGood,3,:);
sdSamp=params(subjGood,4,:);

pWholeMu=nanmean(params(subjGood,1,:),3);
pPartMu=nanmean(params(subjGood,2,:),3);
pColorMu=nanmean(params(subjGood,3,:),3);
sdSampMu=nanmean(params(subjGood,4,:),3);

% For sep A B parameters
% pWhole=params(subjGood,1,:);
% pPart=mean(params(subjGood,2:3,:),2);
% pColor=mean(params(subjGood,4:5,:),2);
% sdSamp=mean(params(subjGood,6,:),2);
% 
% pWholeMu=nanmean(params(subjGood,1,:),3);
% pPartMu=nanmean(mean(params(subjGood,2:3,:),2),3);
% pColorMu=nanmean(mean(params(subjGood,4:5,:),2),3);
% sdSampMu=nanmean(mean(params(subjGood,6,:),2),3);

pWholeSEL=mean(pWhole,3)-prctile(pWhole,2.5,3);
pWholeSEH=prctile(pWhole,97.5,3)-mean(pWhole,3);
pPartSEL=mean(pPart,3)-prctile(pPart,2.5,3);
pPartSEH=prctile(pPart,97.5,3)-mean(pPart,3);
pColorSEL=mean(pColor,3)-prctile(pColor,2.5,3);
pColorSEH=prctile(pColor,97.5,3)-mean(pColor,3);
sdSampSE=nanstd(sdSamp,[],3)./sqrt(sum(~isnan(params(subjGood,4,:)),3));

%% Plot
figure
hold on
errorbar(pPartMu,pWholeMu,pWholeSEL,pWholeSEH,'k.')
herrorbar(pPartMu,pWholeMu,pPartSEL,pPartSEH,'k.')
xlabel('P-Part');ylabel('P-Whole')
hold off

figure
hold on
errorbar(pPartMu,pColorMu,pColorSEL,pColorSEH,'k.')
herrorbar(pPartMu,pColorMu,pPartSEL,pPartSEH,'k.')
xlabel('P-Part');ylabel('P-Color')
hold off

figure
hold on
errorbar(pColorMu,pWholeMu,pWholeSEL,pWholeSEH,'k.')
herrorbar(pColorMu,pWholeMu,pColorSEL,pColorSEH,'k.')
xlabel('P-Color');ylabel('P-Whole')
hold off





