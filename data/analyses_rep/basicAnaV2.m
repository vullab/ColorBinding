%% Basic Colorbinding Analysis
% Converting Corey's basicAna.R code to Matlab...because I hate R
% v2-For all stimuli types
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
    




