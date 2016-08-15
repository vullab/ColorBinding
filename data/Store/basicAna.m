%% Basic Colorbinding Analysis
% Converting Corey's basicAna.R code to Matlab...because I hate R
close all
clear all
fclose all;
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

% 1) cue-loc-int-Location of the cue in the matrix (if you want to see
% other colors, allow hComp and vComp to load from original data file
% 2) refi: cue-loc-int+2
% 3) radius
% 4) ntrials
% 5) ms-st-cue
% 6) npractice
% 7) resp-h-pos
% 8) ms-stimon
% 9) actualStimOn
% 10) version
% 11) bars-or-spot
% 12) nitems
% 13) resp-h-hv
% 14) resp-v-hv
% 15) offset
% 16) cue-length
% 17) resp-v-pos
% 18) cue-loc-x
% 19) cue-loc-y
% 20) ms-precue


if ~exist('parsedData.mat')
    allData=nan(400,20,length(fNames));
    excludeData=zeros(length(fNames),1);
    for fi=1:length(fNames)
        
        try
            % Convert 
            convert_csv_sc(fNames{fi})
            newName=fNames{fi};
            newName(length(newName)-4)='2';
            fiData=csvread(newName,1,1);
            allData(:,:,fi)=fiData;
        catch
            excludeData(fi)=1;
        end
        
    end
    
    fNames(logical(excludeData))=[];
    allData(:,:,logical(excludeData))=[];
    save('parsedData.mat','fNames','allData')
else
    load('parsedData.mat')
end

%% Probability of selecting a given position and component

% For the h component did you 1) select h, v and 2) from which relative
% position?
hComp=nan(2,5,length(fNames)); 
vComp=nan(2,5,length(fNames));

for fi=1:length(fNames)
    
    % For vComp------------------------------------------------------------
    % What component did you select?
    vCompSel=allData(:,14,fi)==1; % resp-v-hv
    vPosData=allData(:,17,fi); % resp-v-pos
    
    % For v trials in which you selected the h component, what position
    % was that component?
    vselPosH=vPosData(vCompSel);
    [vselPosHCounts]=hist(vselPosH,5);
    
    
    % For v trials in which you selected the v component, what position
    % was that component?
    vselPosV=vPosData(~vCompSel);
    [vselPosVCounts]=hist(vselPosV,5);
    
    vComp(1,:,fi)=vselPosHCounts/sum([vselPosHCounts vselPosVCounts]);
    vComp(2,:,fi)=vselPosVCounts/sum([vselPosHCounts vselPosVCounts]);
    
    
    % For hComp------------------------------------------------------------
    % What component did you select?
    hCompSel=allData(:,13,fi)==1; % resp-h-hv
    hPosData=allData(:,7,fi); % resp-v-pos
    
    % For h trials in which you selected the h component, what position
    % was that component?
    hselPosH=hPosData(hCompSel);
    [hselPosHCounts]=hist(hselPosH,5);
    
    
    % For v trials in which you selected the v component, what position
    % was that component?
    hselPosV=hPosData(~hCompSel);
    [hselPosVCounts]=hist(hselPosV,5);
    
    hComp(1,:,fi)=hselPosHCounts/sum([hselPosHCounts hselPosVCounts]);
    hComp(2,:,fi)=hselPosVCounts/sum([hselPosHCounts hselPosVCounts]);
    
end

figure
set(gcf,'color','w');
subplot(1,2,1)
title('Inner Component')
hold on
errorbar(-2:2,mean(vComp(1,:,:),3),std(vComp(1,:,:),0,3)./sqrt(length(fNames)),'b')
errorbar(-2:2,mean(vComp(2,:,:),3),std(vComp(2,:,:),0,3)./sqrt(length(fNames)),'r')
xlim([-2.5 2.5])
hold off

subplot(1,2,2)
title('Outer Component')
hold on
errorbar(-2:2,mean(hComp(1,:,:),3),std(hComp(1,:,:),0,3)./sqrt(length(fNames)),'b')
errorbar(-2:2,mean(hComp(2,:,:),3),std(hComp(2,:,:),0,3)./sqrt(length(fNames)),'r')
xlim([-2.5 2.5])
legend('Outer','Inner')
hold off

%% 







