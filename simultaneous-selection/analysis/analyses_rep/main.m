%% Colorbinding Analysis
% 6.18.2015-Loads colorbinding data from the repeated guessing (folder analyses_rep) and
% simultaneous guessing experiment (analyses_norep2)

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
    cd ../
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
    cd ../analyses_rep
    save('parsedDataV2.mat','fNames','numSubjs','allData','times')
    
else
    load('parsedDataV2.mat')
end

%% Probability of selecting a given position and component

allRes=cell(1,length(allData));
hitRate=zeros(2,length(allData));
hitRate2=nan(2,length(allData),40); % Number complete correct reports
objRate=nan(2,length(allData),40); % Whole object reports (excluding correct)
partRate=nan(2,length(allData),40); % both features bound to correct parts

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
        
        % Probability both correct
        hits=sum((currCond(:,2,si)==2 & currCond(:,4,si)==0 ) & (currCond(:,1,si)==1 & currCond(:,3,si)==0 ));
        hitRate(:,ci)=hitRate(:,ci)+[hits;size(currCond,1)];
        hitRate2(:,ci,si)=[hits;size(currCond,1)];
        
        % Probabilty whole object but not correct
        whole=sum(currCond(:,2,si)==2 & currCond(:,4,si)==currCond(:,3,si) & currCond(:,1,si)==1 )-hits;
        objRate(:,ci,si)=[whole;size(currCond,1)];
        
        % Probability features bound to correct parts
        part=sum(currCond(:,2,si)==2 & currCond(:,1,si)==1 )-hits-whole;
        partRate(:,ci,si)=[part;size(currCond,1)];
    end
    
    allRes{ci}={vComp hComp};
end

% Display statistics
hrProc=nanmean(hitRate2(1,:,:)./hitRate2(2,:,:),3);
disp(strcat('Hit Rate=',num2str(mean(hrProc)),' SEM=',num2str(std(hrProc)./sqrt(length(hrProc)))));

obProc=nanmean(objRate(1,:,:)./objRate(2,:,:),3);
disp(strcat('Object Rate=',num2str(mean(obProc)),' SEM=',num2str(std(obProc)./sqrt(length(obProc)))));

ptProc=nanmean(partRate(1,:,:)./partRate(2,:,:),3);
disp(strcat('Object Rate=',num2str(mean(ptProc)),' SEM=',num2str(std(ptProc)./sqrt(length(ptProc)))));


% Hit rates
% 1-4 have good hit rates
% 5, 6, 9 and 12 didn't have many subjects
% 7, 8, 10, 11, 13, 14 and 15 have high error rates
gc1=[1     2     3     4     7     8    10    11    13    14    15];
rep=nan(2,5,2,length(gc1));
for sti=1:length(gc1)
    
    rep(:,:,1,sti)=mean(allRes{sti}{1},3);
    rep(:,:,2,sti)=mean(allRes{sti}{2},3);
end
rep=squeeze((rep(:,:,1,:)+rep([2 1],:,2,:))/2);

figure('Position', [100, 100, 1049, 895]);set(gcf,'color','w');
hold on
errorbar(-2:2,mean(rep(2,:,:),3),std(rep(2,:,:),[],3)./sqrt(length(gc1)),'b','LineWidth',4) % v for v
errorbar(-2:2,mean(rep(1,:,:),3),std(rep(1,:,:),[],3)./sqrt(length(gc1)),'r','LineWidth',4) % h for v
xlim([-2.5 2.5])
[legh,objh,outh,outm] =legend('Correct Part-Type','Incorrect Part-Type','Location','NorthWest');
M = findobj(legh,'type','line');
m=findobj(legh);

hx1=text(-1.5,-.065,'Counterclockwise','HorizontalAlignment','center');
hx2=text(1.5,-.065,'Clockwise','HorizontalAlignment','center');
hXLabel=text(0,-.1,'Relative position to target','HorizontalAlignment','center');

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

scale = 0.18;
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
        for ti=1:sum(~isnan(hAll))
            cr(hAll(ti),vAll(ti),ti)=1;
        end
        tempCR(:,:,si)=mean(cr,3);
        tempCR2(:,:,si)=sum(cr,3);
        
    end
    colReport{ci}=tempCR;
    colReport2{ci}=tempCR2;
    gc=[1     2     3     4     7     8    10    11    13    14    15];
    if sum(ci==gc,2)==1
        subplot(3,5,ci)
        imagesc(log(mean(tempCR,3)));
        colormap(gray(256))
        title(stimtype{ci})
        set(gca,'xtick',[])
        set(gca,'ytick',[])
    end
    %     ylabel('H-Component')
    %     xlabel('V-Component')
end

%% TO DO-What parts do people recall and from where?
% Make a graph showing for Part A how often people recall a Part A vs. Part
% B and the relative locations of the recalled parts. Do the same for part
% B.


%% TO DO-How often do people recall a whole object?
% Make a graph showing for each location how often people recall a Part A
% from location X and a Part B from location Y where X==Y.


%% TO DO-How often do people recall colors bound to parts?
% Make a graph showing how often people recall two features that are
% correctly bound to parts but come from different objects (so exclude
% whole objects).

%% Model Fit

% for fm6v2
quickie = @(params,currCount)(fullmodel6v2(params,currCount));
startParam=[.1 .15 .2 .8]; % whole, part, color, double guess
lbound=[0 0 0 0 ];
ubound=[1 1 .5 inf ];
name='probSampsInd_fm6v2.mat';

numSamp=40;
if ~exist(name)
    params=nan(length(stimtype),length(startParam),numSamp);
    % P-Whole, P-Part_A/B, P-Color_A/B, sd_whole, sd_part,sd_color
    for ci=1:length(stimtype)
        disp(stimtype{ci})
        a=[];
        for si=1:size(colReport2{ci},3)

            % Sample subjects
            currCount=colReport2{ci}(:,:,si);
            
            if sum(sum(colReport2{ci}(:,:,si)))>=400 % Eliminate subjects without enough samples
                fx = @(params2)(quickie(params2,currCount));
                [PAR_v4{ci} fval]= fminsearchbnd(fx, startParam,lbound,ubound);
                
                params(ci,:,si)=PAR_v4{ci};
                temp=PAR_v4{ci};
                %disp(temp)
                a=[a temp(1)];
            else
                disp('hi')
            end
        end
        %disp(PAR_v4{ci})
    end
    save(name,'params')
else
    
    load(name)
end

goodCond=sum(~isnan(params(:,1,:)),3)>10; % Eliminate conds without enough subjs

figure('Position', [100, 100, 1049, 895]);set(gcf,'color','w');
modllk=nan(10,10,length(stimtype));
modcounts=nan(10,10,length(stimtype));
for ci=1:length(stimtype)
    currCount=sum(colReport2{ci},3);
    if sum(~isnan(squeeze(params(ci,:,:))),2)>10
        [residual mllk]=fullmodel6v2_llk(nanmean(params(ci,:,:),3),currCount);
        modllk(:,:,ci)=mllk;
        modcounts(:,:,ci)=mllk.*sum(currCount(:));
        subplot(3,5,ci)
        imagesc(log(modcounts(:,:,ci)));
        colormap(gray(256))
        title(stimtype{ci})
        set(gca,'xtick',[])
        set(gca,'ytick',[])
    else
        disp(ci)
    end
end

close all
%% Get params
pWhole=params(goodCond,1,:);
pPart=params(goodCond,2,:);
pColor=params(goodCond,3,:);
sdSamp=params(goodCond,4,:);

pWholeMu=nanmean(params(goodCond,1,:),3);
pPartMu=nanmean(params(goodCond,2,:),3);
pColorMu=nanmean(params(goodCond,3,:),3);
sdSampMu=nanmean(params(goodCond,4,:),3);

pWholeSE=nanstd(params(goodCond,1,:),[],3)./sqrt(sum(~isnan(params(goodCond,1,:)),3));
pPartSE=nanstd(params(goodCond,2,:),[],3)./sqrt(sum(~isnan(params(goodCond,2,:)),3));
pColorSE=nanstd(params(goodCond,3,:),[],3)./sqrt(sum(~isnan(params(goodCond,3,:)),3));
sdSampSE=nanstd(params(goodCond,4,:),[],3)./sqrt(sum(~isnan(params(goodCond,4,:)),3));

%% Plot
figure('Position', [100, 100, 895, 895]);set(gcf,'color','w');
hold on
errorbar(sdSampMu,pWholeMu,pWholeSE,'k.')
herrorbar(sdSampMu,pWholeMu,sdSampSE,'k.')
hXLabel=xlabel('SD');hYLabel=ylabel('Pr(Whole)');
disp('SD vs. Whole')
[a b]=corr(pPartMu,pWholeMu);
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

figure('Position', [100, 100, 895, 895]);set(gcf,'color','w');
hold on
errorbar(pPartMu,pWholeMu,pWholeSE,'k.')
herrorbar(pPartMu,pWholeMu,pPartSE,'k.')
hXLabel=xlabel('Pr(Part)');hYLabel=ylabel('Pr(Whole)');
disp('Part vs. Whole')
[a b]=corr(pPartMu,pWholeMu);
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

figure('Position', [100, 100, 895, 895]);set(gcf,'color','w');
hold on
errorbar(pPartMu,pColorMu,pColorSE,'k.')
herrorbar(pPartMu,pColorMu,pPartSE,'k.')
disp('Part vs. Color')
[a b]=corr(pPartMu,pColorMu);
disp(strcat('r: ',num2str(a),' p: ',num2str(b)))
hXLabel=xlabel('Pr(Part)');hYLabel=ylabel('Pr(Color)');
ylim([0 .3])
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

figure('Position', [100, 100, 895, 895]);set(gcf,'color','w');
hold on
errorbar(pColorMu,pWholeMu,pWholeSE,'k.')
herrorbar(pColorMu,pWholeMu,pColorSE,'k.')
disp('Color vs. Whole')
[a b]=corr(pColorMu,pWholeMu);
disp(strcat('r: ',num2str(a),' p: ',num2str(b)))

hXLabel=xlabel('Pr(Color)');hYLabel=ylabel('Pr(Whole)');
xlim([0 .3])
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

%% Visual search analysis
% cd ../../visSearch/NeedHayAnalysis1/
% [rtDifs1 stims1]=behavAnalysis();
% [rtDifs2 stims2]=behavAnalysis2();
% [rtDifs3 stims3]=behavAnalysis3();
% cd ../../data/analyses_norep

cd ../../visSearch/NeedHayAnalysis2/
[rtDifs1 stims1 stimsCorr]=behavAnalysis();
cd ../../data/analyses_rep

rtDifs=[rtDifs1];
stims=stimsCorr;
stimIn=stimtype(goodCond);
% Note several of these stimuli got the wrong name...currsel 
currsel=[10 2 5 3 7 1 4 11];

mu_rtDifs=nanmean(rtDifs,2);
sem_rtDifs=nanstd(rtDifs,[],2)./sqrt(sum(~isnan(rtDifs),2));

figure('Position', [100, 100, 1049, 895]);set(gcf,'Color','white');
[a b]=sort(mu_rtDifs);
hold on
bar(1:length(stims),mu_rtDifs(b))
errorbar(1:length(stims),mu_rtDifs(b),sem_rtDifs(b),'k.')
set(gca,'XTick',[1:length(stims)],'XTickLabel',stims((b)))
set(gca,'xtick',[])
hYLabel=ylabel('Search slope (ms/object)');
set( gca                       , ...
    'FontName'   , 'Helvetica','FontSize',40 );

set([ hYLabel], ...
    'FontName'   , 'Helvetica','Color',[.3 .3 .3] );
set([ hYLabel]  , ...
    'FontSize'   , 40          );
set([  hYLabel], ...
    'FontName'   , 'Helvetica','Color',[.3 .3 .3] );
set([ hYLabel]  , ...
    'FontSize'   , 40          );
set(gca,'box','off')

set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
   'YGrid'       , 'on'      , ... 
   'TickLength'  , [.02 .02] , ...
   'YMinorTick' , 'on', ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'LineWidth'   , 1         );

scale = 0.15;
pos = get(gca, 'Position');
pos(2) = pos(2)+scale*pos(4);
pos(4) = (1-scale)*pos(4);
set(gca, 'Position', pos)
hold off


% Calculate general binding measure
bindMetric=log((pWhole+pPart)./pColor);
bindMetricMu=nanmean(bindMetric,3);
bindMetricSE=nanstd(bindMetric,[],3)./sqrt(sum(~isnan(bindMetric),3));

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

%% Compare to no_rep experiment

cd ../analyses_norep2
[pWhole_nr pPart_nr pColor_nr sdSamp_nr ...
    pWholeMu_nr pPartMu_nr pColorMu_nr sdSampMu_nr ...
    pWholeSE_nr pPartSE pColorSE_nr sdSampSE_nr]=main_norep();
cd ../analyses_rep

bindMetric_nr=log((pWhole_nr+pPart_nr)./pColor_nr);
bindMetricMu_nr=nanmean(bindMetric_nr,3);
bindMetricSE_nr=nanstd(bindMetric_nr,[],3)./sqrt(sum(~isnan(bindMetric_nr),3));

figure('Position', [100, 100, 1049, 895]);set(gcf,'Color','white')
hold on
errorbar(bindMetricMu,bindMetricMu_nr,bindMetricSE_nr,'k.')
herrorbar(bindMetricMu,bindMetricMu_nr,bindMetricSE,'k.')
hXLabel=xlabel('Binding Metric (rep.)');
hYLabel=ylabel('Binding Metric (no rep.)');
disp('Binding metric (rep.) vs. Binding Metric (no rep.)')
[a b]=corr(bindMetricMu,bindMetricMu_nr);
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


figure('Position', [100, 100, 1049, 895]);set(gcf,'Color','white')
hold on
errorbar(mu_rtDifs,bindMetricMu_nr(currsel),bindMetricSE_nr(currsel),'k.')
herrorbar(mu_rtDifs,bindMetricMu_nr(currsel),sem_rtDifs,'k.')
hXLabel=xlabel('Search slope (ms/object)');
hYLabel=ylabel('Binding Metric (no rep.)');
disp('RT vs. Binding Metric (no rep.)')
[a b]=corr(mu_rtDifs,bindMetricMu_nr(currsel));
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







