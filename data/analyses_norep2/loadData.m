function [stimtype allVersion allData allSubj]=loadData()
%% Load color binding data
% This code organizes the data from the color binding experiment
% Assumes that the data is stored in folder called data that is at the same
% level as this function...could not hard code but meh.
% Output
% stimtype-The names of the stimuli
% allVersion-The version number

% allData-Ok this is a big one. All comps is a 1x11 cell array
% corresponding to which of the two components and which of the 11
% conditions. Each cell in turn contains a 400x6xN array corresponding
% to the # of trials, 6 types of data and the # of subjects. The 6 types fo
% data are very important. Let us say there are components A and B. allData
% contains:
% (1)-For component A, did you select an A (correct==1) or B (==2) component?
% (2)-For component B, did you select an A (==1) or B (correct==2) component?
% (3)-Where did the component you selected in (1) come from relative to the
% target? Values -2:2
% (4)-Where did the component you selected in (2) come from relative to the
% target? Values -2:2
% (5) Where the item was in the circle grid and (6) Where the unique
% objects start from. These problably aren't important/washout from the
% random placement of objects

close all
clear all
fclose all;
clc;

%% Parse data

% How to read the raw data
% h is outside, v is inside
% 1) ms-precue- 0, no precue
% 2) resp-v-hv- Did you select an h (1) color or a v (2) color? (2 is correct)
% 3) ms-st-cue- 400 ms,
% 4) nitems- 22 items
% 5) resp-h-pos- Response for first component (0 is correct,numbers are relative position)
% 6) actualStimOn- True stim duration time (This is in seconds)
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
dataFolder='data';
allVersion=[-1 0 1 2 5 6 8 9 11 12 13];
stimtype={'Empty Cross','Bullseye','Eggs','Moon','T','Stack Box','Dots & Boxes','Stable T','Spread Stack Box','Overlap Cross','Outlines'};
setLabels={'resp-h-hv','resp-v-hv','resp-h-pos','resp-v-pos','cue-loc-int','refi'};
if ~exist('parsedDataV3.mat')
    
    %% Find how many data files there are
    cd(dataFolder)
    allFiles=dir();
    fNames={};
    for fi=1:length(allFiles)
        if length(allFiles(fi).name)>4 && allFiles(fi).name(length(allFiles(fi).name)-4)=='1'
            fNames{length(fNames)+1}=allFiles(fi).name;
        end
    end
    cd ..
    
    %% Analyze data
    allData=cell(1,length(stimtype));
    allComps=cell(2,length(stimtype));
    numSubjs=zeros(1,length(stimtype));
    allSubj=cell(30,length(stimtype));
    times=nan(50,length(stimtype),3);
    tempCount=0;
    for fi=1:length(fNames)
        
        try
            fn=fullfile(dataFolder,fNames{fi});
            [hComps vComps]=convert_csv_sc2(fn); % Cut out color arrays
            newName=fNames{fi};
            newName(length(newName)-4)='2';
            
            fn2=fullfile(dataFolder,newName);
            fid=fopen(fn2);
            labels=fgets(fid);
            labels=strsplit(labels,',');
            
            fiData=csvread(fn2,1,0);
            fclose all;
            if size(fiData,1)>=400
                
                % Identify version number
                currV=fiData(1,strcmp('version',labels));
                indV=find(allVersion==currV);
                
                orgData=nan(size(fiData,1),length(setLabels));
                for i=1:length(setLabels)
                    orgData(:,i)=fiData(:,find(strcmp(setLabels{i},labels)));
                end
                
                allData{indV}=cat(3,allData{indV},orgData);
                allComps{1,indV}=cat(3,allComps{1,indV},hComps);
                allComps{2,indV}=cat(3,allComps{2,indV},vComps);
                numSubjs(indV)=numSubjs(indV)+1;
                times(numSubjs(indV),indV,1)=fiData(1,strcmp('ms-st-cue',labels));
                times(numSubjs(indV),indV,2)=fiData(1,strcmp('ms-precue',labels));
                times(numSubjs(indV),indV,3)=fiData(1,strcmp('ms-stimon',labels));
                allSubj{numSubjs(indV),indV}=fNames{fi};
                
                delete(fn2)
            end
        catch err
            disp(fNames{fi})
            disp(num2str(err.stack(end).line));
            excludeData(fi)=1;
        end
        
    end
    save('parsedDataV3.mat','fNames','numSubjs','allData','times','allComps','allSubj')
else
    load('parsedDataV3.mat')
end











