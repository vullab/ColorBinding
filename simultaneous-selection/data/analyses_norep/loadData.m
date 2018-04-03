%% Basic Colorbinding Analysis

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
version=[-1 0 1 2 5 6 8 9 11 12 13];
stimtype={'Empty Cross','Bullseye','Eggs','Moon','T','Stack Box','Dots & Boxes','Stable T','Spread Stack Box','Overlap Cross','Outlines'};
setLabels={'resp-h-hv','resp-v-hv','resp-h-pos','resp-v-pos','cue-loc-int','refi'};
if ~exist('parsedDataV3.mat')
    
    cd ../data_norep
    allFiles=dir();
    fNames={};
    for fi=1:length(allFiles)
        if length(allFiles(fi).name)>4 && allFiles(fi).name(length(allFiles(fi).name)-4)=='1'
            fNames{length(fNames)+1}=allFiles(fi).name;
        end
    end
    
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
            end
            delete(newName)
        catch
            excludeData(fi)=1;
        end
        
    end
    cd ../analyses_norep
    save('parsedDataV3.mat','fNames','numSubjs','allData','times','allComps')
    
else
    load('parsedDataV3.mat')
end










