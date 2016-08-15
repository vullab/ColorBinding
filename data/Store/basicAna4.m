%% Basic Colorbinding Analysis
% Converting Corey's basicAna.R code to Matlab...because I hate R
% v2-For all stimuli types
% v3-Developing model
% v4-Adding SEM error bars
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
imName={'cross','bulls','T','box'};
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

close all
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
        for ti=1:length(hAll)
           cr(hAll(ti),vAll(ti),ti)=1; 
        end
        tempCR(:,:,si)=mean(cr,3);
        tempCR2(:,:,si)=sum(cr,3);
    end
    colReport{ci}=tempCR;
    colReport2{ci}=tempCR2;
    
    subplot(2,2,ci)
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

fprintf('\n')
name='probSampsIndSubj.mat';
if ~exist(name)
    disp('No Diag, flip model, using fminsearchbnd')
    startParam=[.1 .15 .25 .5 .8 1.5 .1];
    numSamp=100;
    params=nan(length(stimtype),length(startParam),26); % hardcoded right now...fix that
    % P-Whole, P-Part_A/B, P-Color_A/B, sd_whole, sd_part,sd_color
    for ci=1:length(stimtype)
        disp(stimtype{ci})
        a=[];
        for si=1:size(colReport2{ci},3)
            currCount=colReport2{ci}(:,:,si);
            currCount=currCount+1;
            quickie = @(params,currCount)(fullmodel5(params,currCount));
            fx = @(params)(quickie(params,currCount));
            options = optimset('MaxFunEvals',1000000000);
            [PAR_v4{ci} fval ex]= fminsearchbnd(fx, startParam,[0 0 0 0 0 0 0],[1 1 1 inf inf inf 1],options);
            if ex==1
                params(ci,:,si)=PAR_v4{ci};
            end
            temp=PAR_v4{ci};
            %disp(temp)
            a=[a temp(1)];
        end
        %disp(PAR_v4{ci})
    end
    save(name,'params')
else
    
    load(name)
end

scale=1000;
shift=.01;
figure;set(gcf,'color','w');
%subplot(2,2,1)
hold on
for i=1:length(stimtype)
    im=imread([imName{i} '.jpg']);
    im2=imresize(im,1);
    for z=1:size(im2,3)
       im2(:,:,z)= flipud(im2(:,:,z));
    end
    image((nanmean(params(i,2,:),3)+shift)*scale,(nanmean(params(i,1,:),3)+shift)*scale,(im2))
end

errorbar(nanmean(params(:,2,:),3)*scale,nanmean(params(:,1,:),3)*scale,nanstd(params(:,1,:),[],3)*scale./sqrt(sum(~isnan(params(:,1,:)),3)),'k.')
herrorbar(nanmean(params(:,2,:),3)*scale,nanmean(params(:,1,:),3)*scale,nanstd(params(:,2,:),[],3)*scale./sqrt(sum(~isnan(params(:,2,:)),3)),'k.')
set(gca,'Xtick',linspace(max([min([nanmean(params(:,2,:),3)-shift*4]) 0])*scale,max(nanmean(params(:,2,:),3)+shift*4)*scale,3),'XTickLabel',{num2str(max([min([nanmean(params(:,2,:),3)-shift*4]) 0]),2),num2str(max(nanmean(params(:,2,:),3)+shift*4)/2,2),num2str(max(nanmean(params(:,2,:),3)+shift*4),2)})
set(gca,'Ytick',linspace(max([min([nanmean(params(:,1,:),3)-shift*4]) 0])*scale,max(nanmean(params(:,1,:),3)+shift*4)*scale,3),'YTickLabel',{num2str(max([min([nanmean(params(:,1,:),3)-shift*4]) 0]),2),num2str(max(nanmean(params(:,1,:),3)+shift*4)/2,2),num2str(max(nanmean(params(:,1,:),3)+shift*4),2)})
xlabel('P-Part')
ylabel('P-Whole')
hold off

figure;set(gcf,'color','w');
%subplot(2,2,2)
hold on
for i=1:length(stimtype)
    im=imread([imName{i} '.jpg']);
    im2=imresize(im,1);
    for z=1:size(im2,3)
       im2(:,:,z)= flipud(im2(:,:,z));
    end
    image((nanmean(params(i,2,:),3)+shift)*scale,(nanmean(params(i,3,:),3)+shift)*scale,(im2))
end
errorbar(nanmean(params(:,2,:),3)*scale,nanmean(params(:,3,:),3)*scale,nanstd(params(:,3,:),[],3)*scale./sqrt(sum(~isnan(params(:,3,:)),3)),'k.')
herrorbar(nanmean(params(:,2,:),3)*scale,nanmean(params(:,3,:),3)*scale,nanstd(params(:,2,:),[],3)*scale./sqrt(sum(~isnan(params(:,2,:)),3)),'k.')

set(gca,'Xtick',linspace(max([min([params(:,2)-shift*4]) 0])*scale,max(params(:,2)+shift*4)*scale,3),'XTickLabel',{num2str(max([min([params(:,2)-shift*4]) 0]),2),num2str(max(params(:,2)+shift*4)/2,2),num2str(max(params(:,2)+shift*4),2)})
set(gca,'Ytick',linspace(max([min([params(:,3)-shift*4]) 0])*scale,max(params(:,3)+shift*4)*scale,3),'YTickLabel',{num2str(max([min([params(:,3)-shift*4]) 0]),2),num2str(max(params(:,3)+shift*4)/2,2),num2str(max(params(:,3)+shift*4),2)})
xlabel('P-Part')
ylabel('P-Color')
hold off

figure;set(gcf,'color','w');
%subplot(2,2,3)
hold on
for i=1:length(stimtype)
    im=imread([imName{i} '.jpg']);
    im2=imresize(im,1);
    for z=1:size(im2,3)
       im2(:,:,z)= flipud(im2(:,:,z));
    end
    image((nanmean(params(i,3,:),3)+shift)*scale,(nanmean(params(i,1,:),3)+shift)*scale,(im2))
end

errorbar(nanmean(params(:,3,:),3)*scale,nanmean(params(:,1,:),3)*scale,nanstd(params(:,1,:),[],3)*scale./sqrt(sum(~isnan(params(:,1,:)),3)),'k.')
herrorbar(nanmean(params(:,3,:),3)*scale,nanmean(params(:,1,:),3)*scale,nanstd(params(:,3,:),[],3)*scale./sqrt(sum(~isnan(params(:,3,:)),3)),'k.')

set(gca,'Xtick',linspace(max([min([params(:,3)-shift*4]) 0])*scale,max(params(:,3)+shift*4)*scale,3),'XTickLabel',{num2str(max([min([params(:,3)-shift*4]) 0]),2),num2str(max(params(:,3)+shift*4)/2,2),num2str(max(params(:,3)+shift*4),2)})
set(gca,'Ytick',linspace(max([min([params(:,1)-shift*4]) 0])*scale,max(params(:,1)+shift*4)*scale,3),'YTickLabel',{num2str(max([min([params(:,1)-shift*4]) 0]),2),num2str(max(params(:,1)+shift*4)/2,2),num2str(max(params(:,1)+shift*4),2)})
xlabel('P-Color')
ylabel('P-Whole')
hold off

%% Prob switching

figure;set(gcf,'color','w');
%subplot(2,2,1)
hold on
for i=1:length(stimtype)
    im=imread([imName{i} '.jpg']);
    im2=imresize(im,1);
    for z=1:size(im2,3)
       im2(:,:,z)= flipud(im2(:,:,z));
    end
    image((nanmean(params(i,1,:),3)+shift)*scale,(nanmean(params(i,7,:),3)+shift)*scale,(im2))
end

errorbar(nanmean(params(:,1,:),3)*scale,nanmean(params(:,7,:),3)*scale,nanstd(params(:,7,:),[],3)*scale./sqrt(sum(~isnan(params(:,1,:)),3)),'k.')
herrorbar(nanmean(params(:,1,:),3)*scale,nanmean(params(:,7,:),3)*scale,nanstd(params(:,1,:),[],3)*scale./sqrt(sum(~isnan(params(:,3,:)),3)),'k.')
set(gca,'Xtick',linspace(max([min([params(:,1)-shift*4]) 0])*scale,max(params(:,1)+shift*4)*scale,3),'XTickLabel',{num2str(max([min([params(:,1)-shift*4]) 0]),2),num2str(max(params(:,1)+shift*4)/2,2),num2str(max(params(:,1)+shift*4),2)})
set(gca,'Ytick',linspace(max([min([params(:,7)-shift*4]) 0])*scale,max(params(:,7)+shift*4)*scale,3),'YTickLabel',{num2str(max([min([params(:,7)-shift*4]) 0]),2),num2str(max(params(:,7)+shift*4)/2,2),num2str(max(params(:,7)+shift*4),2)})

xlabel('P-Whole')
ylabel('P-Switch')
hold off

figure;set(gcf,'color','w');
%subplot(2,2,2)
hold on
for i=1:length(stimtype)
    im=imread([imName{i} '.jpg']);
    im2=imresize(im,1);
    for z=1:size(im2,3)
       im2(:,:,z)= flipud(im2(:,:,z));
    end
    image((nanmean(params(i,2,:),3)+shift)*scale,(nanmean(params(i,7,:),3)+shift)*scale,(im2))
end

errorbar(nanmean(params(:,2,:),3)*scale,nanmean(params(:,7,:),3)*scale,nanstd(params(:,7,:),[],3)*scale./sqrt(sum(~isnan(params(:,1,:)),3)),'k.')
herrorbar(nanmean(params(:,2,:),3)*scale,nanmean(params(:,7,:),3)*scale,nanstd(params(:,2,:),[],3)*scale./sqrt(sum(~isnan(params(:,3,:)),3)),'k.')
xlim([max([min([params(:,2)-shift*4]) 0])*scale max(params(:,2)+shift*4)*scale])
ylim([max([min([params(:,7)-shift*4]) 0])*scale max(params(:,7)+shift*4)*scale])
set(gca,'Xtick',linspace(max([min([params(:,2)-shift*4]) 0])*scale,max(params(:,2)+shift*4)*scale,3),'XTickLabel',{num2str(max([min([params(:,2)-shift*4]) 0]),2),num2str(max(params(:,2)+shift*4)/2,2),num2str(max(params(:,2)+shift*4),2)})
set(gca,'Ytick',linspace(max([min([params(:,7)-shift*4]) 0])*scale,max(params(:,7)+shift*4)*scale,3),'YTickLabel',{num2str(max([min([params(:,7)-shift*4]) 0]),2),num2str(max(params(:,7)+shift*4)/2,2),num2str(max(params(:,7)+shift*4),2)})

xlabel('P-Part')
ylabel('P-Switch')
hold off

figure;set(gcf,'color','w');
hold on
for i=1:length(stimtype)
    im=imread([imName{i} '.jpg']);
    im2=imresize(im,1);
    for z=1:size(im2,3)
       im2(:,:,z)= flipud(im2(:,:,z));
    end
    image((nanmean(params(i,3,:),3)+shift)*scale,(nanmean(params(i,7,:),3)+shift)*scale,(im2))
end

errorbar(nanmean(params(:,3,:),3)*scale,nanmean(params(:,7,:),3)*scale,nanstd(params(:,7,:),[],3)*scale./sqrt(sum(~isnan(params(:,1,:)),3)),'k.')
herrorbar(nanmean(params(:,3,:),3)*scale,nanmean(params(:,7,:),3)*scale,nanstd(params(:,3,:),[],3)*scale./sqrt(sum(~isnan(params(:,3,:)),3)),'k.')

set(gca,'Xtick',linspace(max([min([params(:,3)-shift*4]) 0])*scale,max(params(:,3)+shift*4)*scale,3),'XTickLabel',{num2str(max([min([params(:,3)-shift*4]) 0]),2),num2str(max(params(:,3)+shift*4)/2,2),num2str(max(params(:,3)+shift*4),2)})
set(gca,'Ytick',linspace(max([min([params(:,7)-shift*4]) 0])*scale,max(params(:,7)+shift*4)*scale,3),'YTickLabel',{num2str(max([min([params(:,7)-shift*4]) 0]),2),num2str(max(params(:,7)+shift*4)/2,2),num2str(max(params(:,7)+shift*4),2)})

xlabel('P-Color')
ylabel('P-Switch')
hold off

figure;set(gcf,'color','w');
hold on
[a b]=sort(mean(params(:,7,:),3));
bar((1:length(stimtype))*scale/10,(sort(nanmean(params(:,7,:),3)))*scale)
low=mean(params(:,7,:),3)-prctile(params(:,7,:),2.5,3);
high=prctile(params(:,7,:),97.5,3)-mean(params(:,7,:),3);
errorbar((1:length(stimtype))*scale/10,(sort(nanmean(params(:,7,:),3)))*scale,nanstd(params(b,7,:),[],3)*scale./sqrt(sum(~isnan(params(:,7,:)),3)),'k.')

%ylim([max([min([params(:,7)-shift*4])*scale 0]) max(params(:,7)+shift*4)*scale])
set(gca,'Ytick',linspace(max([min([params(:,7)-shift*4]) 0])*scale,max(params(:,7)+shift*4)*scale,3),'YTickLabel',{num2str(max([min([params(:,7)-shift*4]) 0]),2),num2str(max(params(:,7)+shift*4)/2,2),num2str(max(params(:,7)+shift*4),2)})
set(gca,'Xtick',(1:length(stimtype))*scale/10,'XTickLabel',imName(b))
ylabel('P-Switch')
%xlabel('Condition')
hold off

%% Visual search analysis
cd ../visSearch/NeedHayAnalysis1/
[rtDifs stims]=behavAnalysis();
cd ../../data

mu_rtDifs=mean(rtDifs,2);
sem_rtDifs=std(rtDifs,[],2)./sqrt(size(rtDifs,2));

figure;set(gcf,'Color','white');
[a b]=sort(mu_rtDifs);
hold on
bar(1:4,mean(rtDifs(b,:),2))
errorbar(1:4,mean(rtDifs(b,:),2),std(rtDifs(b,:),[],2)./sqrt(size(rtDifs,2)),'k.')
set(gca,'XTick',[1 2 3 4],'XTickLabel',stims(b))
ylabel('Reaction time dif. (ms)')
hold off

figure;set(gcf,'Color','white')
hold on
low=mean(params(:,1,:),3)-prctile(params(:,1,:),2.5,3);
high=prctile(params(:,1,:),97.5,3)-mean(params(:,1,:),3);
errorbar(mu_rtDifs,nanmean(params(:,1,:),3),nanstd(params(:,1,:),[],3)./sqrt(sum(~isnan(params(:,1,:)),3)),'k.')
xlabel('RT Dif')
ylabel('P-Whole')
hold off

figure;set(gcf,'Color','white')
low=mean(params(:,2,:),3)-prctile(params(:,2,:),2.5,3);
high=prctile(params(:,2,:),97.5,3)-mean(params(:,2,:),3);
errorbar(mu_rtDifs,nanmean(params(:,2,:),3),nanstd(params(:,2,:),[],3)./sqrt(sum(~isnan(params(:,1,:)),3)),'k.')
xlabel('RT Dif')
ylabel('P-Part')

figure;set(gcf,'Color','white')
low=mean(params(:,3,:),3)-prctile(params(:,3,:),2.5,3);
high=prctile(params(:,3,:),97.5,3)-mean(params(:,3,:),3);
errorbar(mu_rtDifs,nanmean(params(:,3,:),3),nanstd(params(:,3,:),[],3)./sqrt(sum(~isnan(params(:,1,:)),3)),'k.')
xlabel('RT Dif')
ylabel('P-Color')

figure;set(gcf,'Color','white')
low=mean(params(:,7,:),3)-prctile(params(:,7,:),2.5,3);
high=prctile(params(:,7,:),97.5,3)-mean(params(:,7,:),3);
errorbar(mu_rtDifs,nanmean(params(:,7,:),3),nanstd(params(:,7,:),[],3)./sqrt(sum(~isnan(params(:,1,:)),3)),'k.')
xlabel('Reaction time dif. (ms)')
ylabel('P-Switch')

















%% Without flipping
% fprintf('\n')
% 
% disp('No Diag, flip model, using fminsearchbnd')
% startParam=[.1 .15 .3 .5 .8 1.5 0];
% params=nan(length(stimtype),length(startParam));
% % P-Whole, P-Part_A/B, P-Color_A/B, sd_whole, sd_part,sd_color
% for ci=1:length(stimtype)
%     disp(stimtype{ci})
%     currCount=sum(colReport2{ci},3);
%     currCount(logical(eye(10)))=0;
%     quickie = @(params,currCount)(fullmodel5(params,currCount));
%     fx = @(params)(quickie(params,currCount));
%     [PAR_v4{ci} fval]= fminsearchbnd(fx, startParam,[0 0 0 0 0 0 0],[1 1 1 inf inf inf 1]); 
%     params(ci,:)=PAR_v4{ci};
%     %disp(PAR_v4{ci})
% end
% scale=700;
% shift=.02;
% figure
% subplot(2,2,1)
% hold on
% for i=1:length(stimtype)
%     im=imread([imName{i} '.jpg']);
%     im2=imresize(im,1);
%     for z=1:size(im2,3)
%        im2(:,:,z)= flipud(im2(:,:,z));
%     end
%     image((params(i,2)+shift)*scale,(params(i,1)+shift)*scale,(im2))
% end
% plot(params(:,2)*scale,params(:,1)*scale,'k.')
% xlim([max([min([params(:,2)-shift*4]) 0])*scale max(params(:,2)+shift*4)*scale])
% ylim([max([min([params(:,1)-shift*4]) 0])*scale max(params(:,1)+shift*4)*scale])
% set(gca,'Xtick',linspace(max([min([params(:,2)-shift*4]) 0])*scale,max(params(:,2)+shift*4)*scale,3),'XTickLabel',{num2str(max([min([params(:,2)-shift*4]) 0])),num2str(max(params(:,2)+shift*4)/2),num2str(max(params(:,2)+shift*4))})
% set(gca,'Ytick',linspace(max([min([params(:,1)-shift*4]) 0])*scale,max(params(:,1)+shift*4)*scale,3),'YTickLabel',{num2str(max([min([params(:,1)-shift*4]) 0])),num2str(max(params(:,1)+shift*4)/2),num2str(max(params(:,1)+shift*4))})
% xlabel('P-Part')
% ylabel('P-Whole')
% hold off
% 
% subplot(2,2,2)
% hold on
% for i=1:length(stimtype)
%     im=imread([imName{i} '.jpg']);
%     im2=imresize(im,1);
%     for z=1:size(im2,3)
%        im2(:,:,z)= flipud(im2(:,:,z));
%     end
%     image(params(i,2)*scale,params(i,3)*scale,(im2))
% end
% plot(params(:,2)*scale,params(:,3)*scale,'k.')
% xlim([max([min([params(:,2)-shift*4]) 0])*scale max(params(:,2)+shift*4)*scale])
% ylim([max([min([params(:,3)-shift*4]) 0])*scale max(params(:,3)+shift*4)*scale])
% set(gca,'Xtick',linspace(max([min([params(:,2)-shift*4]) 0])*scale,max(params(:,2)+shift*4)*scale,3),'XTickLabel',{num2str(max([min([params(:,2)-shift*4]) 0])),num2str(max(params(:,2)+shift*4)/2),num2str(max(params(:,2)+shift*4))})
% set(gca,'Ytick',linspace(max([min([params(:,3)-shift*4]) 0])*scale,max(params(:,3)+shift*4)*scale,3),'YTickLabel',{num2str(max([min([params(:,3)-shift*4]) 0])),num2str(max(params(:,3)+shift*4)/2),num2str(max(params(:,3)+shift*4))})
% xlabel('P-Part')
% ylabel('P-Color')
% hold off
% 
% subplot(2,2,3)
% hold on
% for i=1:length(stimtype)
%     im=imread([imName{i} '.jpg']);
%     im2=imresize(im,1);
%     for z=1:size(im2,3)
%        im2(:,:,z)= flipud(im2(:,:,z));
%     end
%     image(params(i,3)*scale,params(i,1)*scale,(im2))
% end
% plot(params(:,3)*scale,params(:,1)*scale,'k.')
% xlim([max([min([params(:,3)-shift*4]) 0])*scale max(params(:,3)+shift*4)*scale])
% ylim([max([min([params(:,1)-shift*4]) 0])*scale max(params(:,1)+shift*4)*scale])
% set(gca,'Xtick',linspace(max([min([params(:,3)-shift*4]) 0])*scale,max(params(:,3)+shift*4)*scale,3),'XTickLabel',{num2str(max([min([params(:,3)-shift*4]) 0])),num2str(max(params(:,3)+shift*4)/2),num2str(max(params(:,3)+shift*4))})
% set(gca,'Ytick',linspace(max([min([params(:,1)-shift*4]) 0])*scale,max(params(:,1)+shift*4)*scale,3),'YTickLabel',{num2str(max([min([params(:,1)-shift*4]) 0])),num2str(max(params(:,1)+shift*4)/2),num2str(max(params(:,1)+shift*4))})
% xlabel('P-Color')
% ylabel('P-Whole')
% hold off
% 
% figure
% subplot(2,2,1)
% hold on
% for i=1:length(stimtype)
%     im=imread([imName{i} '.jpg']);
%     im2=imresize(im,1);
%     for z=1:size(im2,3)
%        im2(:,:,z)= flipud(im2(:,:,z));
%     end
%     image(params(i,1)*scale,params(i,7)*scale,(im2))
% end
% plot(params(:,1)*scale,params(:,7)*scale,'k.')
% xlim([max([min([params(:,1)-shift*4]) 0])*scale max(params(:,1)+shift*4)*scale])
% ylim([max([min([params(:,7)-shift*4]) 0])*scale max(params(:,7)+shift*4)*scale])
% set(gca,'Xtick',linspace(max([min([params(:,1)-shift*4]) 0])*scale,max(params(:,1)+shift*4)*scale,3),'XTickLabel',{num2str(max([min([params(:,1)-shift*4]) 0])),num2str(max(params(:,1)+shift*4)/2),num2str(max(params(:,1)+shift*4))})
% set(gca,'Ytick',linspace(max([min([params(:,7)-shift*4]) 0])*scale,max(params(:,7)+shift*4)*scale,3),'YTickLabel',{num2str(max([min([params(:,7)-shift*4]) 0])),num2str(max(params(:,7)+shift*4)/2),num2str(max(params(:,7)+shift*4))})
% 
% xlabel('P-Whole')
% ylabel('P-Switch')
% hold off
% 
% subplot(2,2,2)
% hold on
% for i=1:length(stimtype)
%     im=imread([imName{i} '.jpg']);
%     im2=imresize(im,1);
%     for z=1:size(im2,3)
%        im2(:,:,z)= flipud(im2(:,:,z));
%     end
%     image(params(i,2)*scale,params(i,7)*scale,(im2))
% end
% plot(params(:,2)*scale,params(:,7)*scale,'k.')
% xlim([max([min([params(:,2)-shift*4]) 0])*scale max(params(:,2)+shift*4)*scale])
% ylim([max([min([params(:,7)-shift*4]) 0])*scale max(params(:,7)+shift*4)*scale])
% set(gca,'Xtick',linspace(max([min([params(:,2)-shift*4]) 0])*scale,max(params(:,2)+shift*4)*scale,3),'XTickLabel',{num2str(max([min([params(:,2)-shift*4]) 0])),num2str(max(params(:,2)+shift*4)/2),num2str(max(params(:,2)+shift*4))})
% set(gca,'Ytick',linspace(max([min([params(:,7)-shift*4]) 0])*scale,max(params(:,7)+shift*4)*scale,3),'YTickLabel',{num2str(max([min([params(:,7)-shift*4]) 0])),num2str(max(params(:,7)+shift*4)/2),num2str(max(params(:,7)+shift*4))})
% 
% xlabel('P-Part')
% ylabel('P-Switch')
% hold off
% 
% subplot(2,2,3)
% hold on
% for i=1:length(stimtype)
%     im=imread([imName{i} '.jpg']);
%     im2=imresize(im,1);
%     for z=1:size(im2,3)
%        im2(:,:,z)= flipud(im2(:,:,z));
%     end
%     image(params(i,3)*scale,params(i,7)*scale,(im2))
% end
% plot(params(:,3)*scale,params(:,7)*scale,'k.')
% xlim([max([min([params(:,3)-shift*4]) 0])*scale max(params(:,3)+shift*4)*scale])
% ylim([max([min([params(:,7)-shift*4]) 0])*scale max(params(:,7)+shift*4)*scale])
% set(gca,'Xtick',linspace(max([min([params(:,3)-shift*4]) 0])*scale,max(params(:,3)+shift*4)*scale,3),'XTickLabel',{num2str(max([min([params(:,3)-shift*4]) 0])),num2str(max(params(:,3)+shift*4)/2),num2str(max(params(:,3)+shift*4))})
% set(gca,'Ytick',linspace(max([min([params(:,7)-shift*4]) 0])*scale,max(params(:,7)+shift*4)*scale,3),'YTickLabel',{num2str(max([min([params(:,7)-shift*4]) 0])),num2str(max(params(:,7)+shift*4)/2),num2str(max(params(:,7)+shift*4))})
% 
% xlabel('P-Color')
% ylabel('P-Switch')
% hold off


% disp('Orig model, flip model')
% startParam=[.1 .15 .25 .5 .8 1.5 .1];
% % P-Whole, P-Part_A/B, P-Color_A/B, sd_whole, sd_part,sd_color
% for ci=1:length(stimtype)
%     disp(stimtype{ci})
%     currCount=sum(colReport2{ci},3);
%     currCount(logical(eye(10)))=0;
%     quickie = @(params,currCount)(fullmodel3(params,currCount));
%     fx = @(params)(quickie(params,currCount));
%     PAR_v3{ci} = fminsearchbnd(fx, startParam,[0 0 0 0 0 0 0],[1 1 1 inf inf inf 1]); 
%     disp(PAR_v3{ci})
% end






