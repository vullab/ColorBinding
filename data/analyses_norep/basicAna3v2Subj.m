%% Basic Colorbinding Analysis
% Converting Corey's basicAna.R code to Matlab...because I hate R
% v2-For all stimuli types
% v3-Developing model
% v3v2-Trying to simplify model, getting rid of multiple noise an switching
% parameters
% v3v2Subj-Fit each subject, use SEM
close all
clear all
fclose all;
clc;
set(0,'defaultlinelinewidth',2)
set(0, 'DefaultAxesFontSize',40)
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
fname='parsedDataV2.mat';
if ~exist(fname)
    cd ../data_norep
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
    cd ../analyses_norep
    save(fname,'fNames','numSubjs','allData','times','allComps')
    
else
    load(fname)
end

%% Probability of selecting a given position and component
% Do people sample over space?

allRes=cell(1,length(allData));
hitRate=zeros(2,length(allData));
correct=zeros(2,5,4);
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

figure('Position', [100, 100, 1049, 895]);set(gcf,'color','w');
hold on
errorbar(-2:2,mean(correct(1,:,:),3),std(correct(1,:,:),[],3)./sqrt(4),'b','LineWidth',4) % v for v
errorbar(-2:2,mean(correct(2,:,:),3),std(correct(2,:,:),[],3)./sqrt(4),'r','LineWidth',4) % h for v
xlim([-2.5 2.5])
[legh,objh,outh,outm] =legend('Correct Part-Type','Incorrect Part-Type','Location','NorthWest');
M = findobj(legh,'type','line');
m=findobj(legh);

hx1=text(-1.5,-.095,'Counterclockwise','HorizontalAlignment','center');
hx2=text(1.5,-.095,'Clockwise','HorizontalAlignment','center');
hXLabel=text(0,-.15,'Relative position to target','HorizontalAlignment','center');

set([hx1 hx2], ...
    'FontName'   , 'Helvetica','Color',[.3 .3 .3] );
set([hx1 hx2]  , ...
    'FontSize'   , 40          );

set([legh],'FontName'   , 'Helvetica','TextColor',[.3 .3 .3] )

set([legh],'FontName'   , 'Helvetica','TextColor',[.3 .3 .3] )
%hXLabel=xlabel('Relative position to target');
hYLabel=ylabel('Proportion of Responses');
set( gca                       , ...
    'FontName'   , 'Helvetica','FontSize',32 );

set([hXLabel hYLabel], ...
    'FontName'   , 'Helvetica','Color',[.3 .3 .3] );
set([hXLabel hYLabel]  , ...
    'FontSize'   , 60          );
set([ hXLabel, ], ...
    'FontName'   , 'Helvetica','Color',[.3 .3 .3] );
set([hXLabel]  , ...
    'FontSize'   , 60          );

set([ hYLabel]  , ...
    'FontSize'   , 50          );
set([ hYLabel], ...
    'FontName'   , 'Helvetica','Color',[.3 .3 .3] );
set([hXLabel, hYLabel]  , ...
    'FontSize'   , 50          );

set(gca,'box','off')
set(m(end-(3):end),'linewidth',4)
set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'LineWidth'   , 1         );

scale = 0.15;
pos = get(gca, 'Position');
pos(2) = pos(2)+scale*pos(4);
pos(4) = (1-scale)*pos(4);
set(gca, 'Position', pos)
hold off

%% Color switching reports

colReport=cell(1,length(allData));
colReport2=cell(1,length(allData));

% For given subject the matrix is Reports for h(hv) by Reports for v(hv)
figure('Position', [100, 100, 1049, 895]);set(gcf,'color','w');
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
    imagesc((mean(tempCR,3)));
    colormap(gray(256))
    title(stimtype{ci})
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    %     ylabel('H-Component')
    %     xlabel('V-Component')
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



% % for fm5
% quickie = @(params,currCount)(fullmodel5(params,currCount));
% startParam=[.1 .15 .25 .5 .8 1.5 .1];
% lbound=[0 0 0 0 0 0 0];
% ubound=[1 1 1 inf inf inf 1];
% 
% for fm6
quickie = @(params,currCount)(fullmodel6(params,currCount));
startParam=[.1 .15 .25 .8];
lbound=[0 0 0 0 ];
ubound=[1 1 1 inf ];
name='probSampsInd_fm6.mat';

% % for fm7
% % Has trouble converging, but giving pretty similar results
% quickie = @(params,currCount)(fullmodel7(params,currCount));
% startParam=[.1 .15 .25 .5 .8 1.5 ];
% lbound=[0 0 0 0 0 0];
% ubound=[1 1 1 inf inf inf ];
% name='probSampsInd_fm7.mat';

% for fm9
% No redistributing
% quickie = @(params,currCount)(fullmodel9(params,currCount));
% startParam=[.1 .15 .25 .8];
% lbound=[0 0 0 0 ];
% ubound=[1 1 1 inf ];
% name='probSampsInd_fm9.mat';

numSamp=30;
if ~exist(name)
    params=nan(length(stimtype),length(startParam),numSamp);
    % P-Whole, P-Part_A/B, P-Color_A/B, sd_whole, sd_part,sd_color
    for ci=1:length(stimtype)
        disp(stimtype{ci})
        a=[];
        for si=1:size(colReport2{ci},3)
            
            % Sample uniformly across data
%             currCount2=repmat([0 cumsum(sum(currCount(:,1:9)))],10,1)+cumsum(currCount);
%             currCount2(logical(eye(10)))=0;
%             ind=randi([1 sum(currCount(:))],1,sum(currCount(:)));
%             currCount3=zeros(10,10);
%             for ii=1:length(ind)
%                 % This is inefficient, probably a good vectorized way to do
%                 % this...
%                 [a b]=find(ind(ii)<=currCount2);
%                 currCount3(a(1),b(1))=currCount3(a(1),b(1))+1;
%             end

            % Sample subjects
            currCount=colReport2{ci}(:,:,si);
            
            fx = @(params)(quickie(params,currCount));
            [PAR_v4{ci} fval]= fminsearchbnd(fx, startParam,lbound,ubound);

            params(ci,:,si)=PAR_v4{ci};
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

figure('Position', [100, 100, 1049, 895]);set(gcf,'color','w');
modllk=nan(10,10,length(stimtype));
modcounts=nan(10,10,length(stimtype));
for ci=1:length(stimtype)
    start=zeros(10,10);
    
    for si=1:size(colReport2{ci},3)
        currCount=colReport2{ci}(:,:,si);
        currCount(logical(eye(10)))=0;
        [residual mllk]=fullmodel6_llk(params(ci,:,si),currCount);
        start=start+mllk*sum(currCount(:));
    end
    modcounts(:,:,ci)=start;
    subplot(2,2,ci)
    imagesc((modcounts(:,:,ci)));
    colormap(gray(256))
    title(stimtype{ci})
    set(gca,'xtick',[])
    set(gca,'ytick',[])
%     ylabel('H-Component')
%     xlabel('V-Component')
end

%% Get params
pWhole=params(:,1,:);
pPart=params(:,2,:);
pColor=params(:,3,:);
sdSamp=params(:,4,:);

pWhole2=nanmean(params(:,1,:),3);
pPart2=nanmean(params(:,2,:),3);
pColor2=nanmean(params(:,3,:),3);
sdSamp2=nanmean(params(:,4,:),3);

pWholeSE=nanstd(params(:,1,:),[],3)./sqrt(sum(~isnan(params(:,1,:)),3));
pPartSE=nanstd(params(:,2,:),[],3)./sqrt(sum(~isnan(params(:,2,:)),3));
pColorSE=nanstd(params(:,3,:),[],3)./sqrt(sum(~isnan(params(:,3,:)),3));
sdSampSE=nanstd(params(:,4,:),[],3)./sqrt(sum(~isnan(params(:,4,:)),3));

%% Get parameter distribution
for pi=1:3
    figure
    for ci=1:4
        subplot(2,2,ci)
        hist(squeeze(params(ci,pi,:)))
        title(stimtype{ci})
    end
end

%% Plot
close all
scale=1;
shift=0;
figure('Position', [100, 100, 1049, 895]);set(gcf,'color','w');

%subplot(2,2,1)
hold on
% for i=1:length(stimtype)
%     im=imread([imName{i} '.jpg']);
%     im2=imresize(im,1);
%     for z=1:size(im2,3)
%        im2(:,:,z)= flipud(im2(:,:,z));
%     end
%     image((pPart2(i)+shift)*scale,(pWhole2(i)+shift)*scale,(im2))
% end
errorbar((pPart2+shift)*scale,(pWhole2+shift)*scale,(pWholeSE+shift)*scale,'k.')
herrorbar((pPart2+shift)*scale,(pWhole2+shift)*scale,(pPartSE+shift)*scale,'k.')

set(gca,'Xtick',linspace(max([min([pPart2-shift*4]) 0])*scale,max(pPart2+shift*4)*scale,3),'XTickLabel',{num2str(max([min([pPart2-shift*4]) 0]),2),num2str(max(pPart2+shift*4)/2,2),num2str(max(pPart2+shift*4),2)})
set(gca,'Ytick',linspace(max([min([pWhole2-shift*4]) 0])*scale,max(pWhole2+shift*4)*scale,3),'YTickLabel',{num2str(max([min([pWhole2-shift*4]) 0]),2),num2str(max(pWhole2+shift*4)/2,2),num2str(max(pWhole2+shift*4),2)})
xlabel('P-Part')
ylabel('P-Whole')
shiftFig;
hold off

figure('Position', [100, 100, 1049, 895]);set(gcf,'color','w');
%subplot(2,2,2)
hold on
% for i=1:length(stimtype)
%     im=imread([imName{i} '.jpg']);
%     im2=imresize(im,1);
%     for z=1:size(im2,3)
%        im2(:,:,z)= flipud(im2(:,:,z));
%     end
%     image(pPart2(i)*scale,pColor2(i)*scale,(im2))
% end
errorbar((pPart2+shift)*scale,(pColor2+shift)*scale,(pColorSE +shift)*scale,'k.')
herrorbar((pPart2+shift)*scale,(pColor2+shift)*scale,(pPartSE+shift)*scale,'k.')
set(gca,'Xtick',linspace(max([min([pPart2-shift*4]) 0])*scale,max(pPart2+shift*4)*scale,3),'XTickLabel',{num2str(max([min([pPart2-shift*4]) 0]),2),num2str(max(pPart2+shift*4)/2,2),num2str(max(pPart2+shift*4),2)})
set(gca,'Ytick',linspace(max([min([pColor2-shift*4]) 0])*scale,max(pColor2+shift*4)*scale,3),'YTickLabel',{num2str(max([min([pColor2-shift*4]) 0]),2),num2str(max(pColor2+shift*4)/2,2),num2str(max(pColor2+shift*4),2)})
xlabel('P-Part')
ylabel('P-Color')
shiftFig;
hold off

figure('Position', [100, 100, 1049, 895]);set(gcf,'color','w');
%subplot(2,2,3)
hold on
% for i=1:length(stimtype)
%     im=imread([imName{i} '.jpg']);
%     im2=imresize(im,1);
%     for z=1:size(im2,3)
%        im2(:,:,z)= flipud(im2(:,:,z));
%     end
%     image(pColor2(i)*scale,pWhole2(i)*scale,(im2))
% end
errorbar((pColor2+shift)*scale,(pWhole2+shift)*scale,(pWholeSE+shift)*scale,'k.')
herrorbar((pColor2+shift)*scale,(pWhole2+shift)*scale,(pColorSE+shift)*scale,'k.')
set(gca,'Xtick',linspace(max([min([pColor2-shift*4]) 0])*scale,max(pColor2+shift*4)*scale,3),'XTickLabel',{num2str(max([min([pColor2-shift*4]) 0]),2),num2str(max(pColor2+shift*4)/2,2),num2str(max(pColor2+shift*4),2)})
set(gca,'Ytick',linspace(max([min([pWhole2-shift*4]) 0])*scale,max(pWhole2+shift*4)*scale,3),'YTickLabel',{num2str(max([min([pWhole2-shift*4]) 0]),2),num2str(max(pWhole2+shift*4)/2,2),num2str(max(pWhole2+shift*4),2)})
xlabel('P-Color')
ylabel('P-Whole')
shiftFig;
hold off

%% Visual search analysis
cd ../../visSearch/NeedHayAnalysis1/
[rtDifs stims]=behavAnalysis();
cd ../../data/analyses_norep

mu_rtDifs=mean(rtDifs/12,2);
sem_rtDifs=std(rtDifs/12,[],2)./sqrt(size(rtDifs,2));

% Calculate general binding measure
bindMetric=log((pWhole+pPart)./pColor);
bindMetricMu=nanmean(bindMetric,3);
bindMetricSE=nanstd(bindMetric,[],3)./sqrt(sum(~isnan(bindMetric),3));

currsel=[1:4];
figure('Position', [100, 100, 1049, 895]);set(gcf,'Color','white')
hold on
errorbar(mu_rtDifs,bindMetricMu(currsel),bindMetricSE(currsel),'k.')
herrorbar(mu_rtDifs,bindMetricMu(currsel),sem_rtDifs,'k.')
hXLabel=xlabel('Search slope (ms/object)');
hYLabel=ylabel('Binding Metric');
disp('RT vs. Binding Metric')
[a b]=corr(mu_rtDifs,bindMetricMu(currsel));
disp(strcat('r: ',num2str(a),' p: ',num2str(b)))
set( gca                       , ...
    'FontName'   , 'Helvetica','FontSize',40 );

set([hXLabel hYLabel], ...
    'FontName'   , 'Helvetica','Color',[.3 .3 .3] );
set([hXLabel hYLabel]  , ...
    'FontSize'   , 60          );
set([ hXLabel, hYLabel], ...
    'FontName'   , 'Helvetica','Color',[.3 .3 .3] );
set([hXLabel, hYLabel]  , ...
    'FontSize'   , 60          );
set(gca,'box','off')

set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'LineWidth'   , 1         );

scale = 0.15;
pos = get(gca, 'Position');
pos(2) = pos(2)+scale*pos(4);
pos(4) = (1-scale)*pos(4);
set(gca, 'Position', pos)
hold off




% 
% 
% figure('Position', [100, 100, 1049, 895]);set(gcf,'Color','white');
% [a b]=sort(mu_rtDifs);
% hold on
% bar(1:4,mean(rtDifs(b,:)/12,2))
% errorbar(1:4,mean(rtDifs(b,:),2),std(rtDifs(b,:),[],2)./sqrt(size(rtDifs,2)),'k.')
% set(gca,'XTick',[1 2 3 4],'XTickLabel',stims(b))
% ylabel('Reaction time dif. (ms)')
% shiftFig;
% hold off
% 
% figure('Position', [100, 100, 1049, 895]);set(gcf,'Color','white')
% hold on
% errorbar(mu_rtDifs,nanmean(pWhole,3),pWholeSE,'k.')
% xlabel('RT Dif')
% ylabel('P-Whole')
% shiftFig;
% hold off
% 
% figure('Position', [100, 100, 1049, 895]);set(gcf,'Color','white')
% errorbar(mu_rtDifs,nanmean(pPart,3),pPartSE,'k.')
% xlabel('RT Dif')
% ylabel('P-Part')
% shiftFig;
% 
% 
% figure('Position', [100, 100, 1049, 895]);set(gcf,'Color','white')
% errorbar(mu_rtDifs,nanmean(pColor,3),pColorSE,'k.')
% xlabel('RT Dif')
% ylabel('P-Color')
% shiftFig;
% 
% 










