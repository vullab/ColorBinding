function [pWhole pPart pColor sdSamp ...
    pWholeMu pPartMu pColorMu sdSampMu ...
    pWholeSE pPartSE pColorSE sdSampSE]=main_norep()
%% main

%% Load data

[stimtype allVersion allData allSubj]=loadData(); % Read comments in this
% allData-Ok this is a big one. All comps is a 1x11 cell array
% corresponding to which of the two components and which of the 11
% conditions. Each cell in turn contains a 400x6xN array corresponding
% to the # of trials, 6 types of data and the # of subjects. The 6 types fo
% data are very important. Let us say there are components A and B. allData
% contains:
% (1)-For component A, did you select an A (correct==1) or B (==2) component?
% (2)-For component B, did you select an A (==1) or B (correct==2) component?
% (3)-Where did the component you selected in (1) come from relative to the
% target? Values -2:2 (2 spots clockwise from target to 2 spots counterclockwise)
% (4)-Where did the component you selected in (2) come from relative to the
% target? Values -2:2
% (5) Where the item was in the circle grid and (6) Where the unique
% objects start from. These problably aren't important/washout from the
% random placement of objects

%% The fit isn't working for 10th condition, 24th subject
% colReport2{10}(:,:,24) 
% Subject appeared to just not really select targets...
allData{10}(:,:,24)=[];

%% Accuracy-This code will tell you how many whole objects people recalled 

hitRate=zeros(30,2,length(allData)); % #Subj x #TrialCorrect vs. #TrialTotal x #Conditions
% Set 30 because it's about right and too lazy to look up how many subjects
% there are

% For each condition
for ci=1:length(allData)
    currCond=allData{ci};
    
    % For each subject
    if ~isempty(currCond)
        for si=1:size(currCond,3)
            % Identify trials in which each part was recalled correctly
            % Interpreting the line below each clause is asking 1) Did you recall the correct type of part and if you did, 2) did you recll it from the correct place 
            hits=sum(   (currCond(:,2,si)==2 & currCond(:,4,si)==0 ) & (currCond(:,1,si)==1 & currCond(:,3,si)==0 ));
            hitRate(si,1,ci)=hits; % Number of correctly recalled whole objects
            hitRate(si,2,ci)=size(currCond,1); % Total number of trials
        end
    end
    
end
hitProp=squeeze(hitRate(:,1,:)./hitRate(:,2,:)); % Find the proportion of correct answers

% Let's plot the mean hit rate with error bars
figure
hold on
bar(nanmean(hitProp,1)) % The average hit rate
errorbar(1:length(nanmean(hitProp,1)),nanmean(hitProp,1),nanstd(hitProp)./sqrt(sum(~isnan(hitProp),1)),'k.') % Give it error bars
set(gca,'XTick',1:length(nanmean(hitProp,1)),'XTickLabel',stimtype,'FontSize', 10) % Give it labels
hold on

%% Frequency as a function of location
[allRes hitRate correct]=frequencyLocation(allData,stimtype,0);
plotFrequencyLocation(correct);

%% Counts 
[colReport colReport2]=locationCounts(allData,stimtype,0);

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



%% Model fit

% for fm6
quickie = @(params,currCount)(fullmodel6(params,currCount));
startParam=[.1 .15 .25 .8];
lbound=[0 0 0 0 ];
ubound=[1 1 1 inf ];
name='probSampsInd_fm6.mat';

numSamp=30;
if ~exist(name)
    params=nan(length(stimtype),length(startParam),numSamp);
    % P-Whole, P-Part_A/B, P-Color_A/B, sd_whole, sd_part,sd_color
    for ci=1:length(stimtype)
        disp(stimtype{ci})
        a=[];
        for si=1:size(colReport2{ci},3)
            currCount=colReport2{ci}(:,:,si);
            
            fx = @(params)(quickie(params,currCount));
            options=optimset('MaxIter',1000);
            [PAR_v4{ci} fval]= fminsearchbnd(fx, startParam,lbound,ubound,options);

            params(ci,:,si)=PAR_v4{ci};
            temp=PAR_v4{ci};
            a=[a temp(1)];
        end
    end
    save(name,'params')
else    
    load(name)
end

%% Plot model results



[pWhole pPart pColor sdSamp ...
    pWholeMu pPartMu pColorMu sdSampMu ...
    pWholeSE pPartSE pColorSE sdSampSE]=plotModelResults(params,stimtype);


