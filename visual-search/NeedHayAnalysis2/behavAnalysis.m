function [rtDifs stims stims2]=behavAnalysis()
%% Analyze object visual search
%close all
%clear all
%clc
%% Load data

fpath=cd;
fname=fullfile('fullData');
datafile=fopen(fullfile(fpath,strcat(fname,'.txt')));
data =textscan(datafile,'%s %s %f %f %s %f %s %f %f %f %f', 'delimiter',';');

% Shift so starts at 1
data{3}=data{3}+1;
data{4}=data{4}+1;

numTrial=6;
numFlip=2;
numItems=[5 17];
numLen=length(numItems);
presAbs=2;
totTrials=sum(numTrial*numFlip*numLen*presAbs/length(numItems)*ones(size(numItems)).*numItems);
numBlocks=2;
numTrials2=numTrial*numLen*presAbs;

% stims={'cross','bull','T2','stack','eggs','dotbo','empty','moon','outbo','windo'};
% % Actual names-I gave the experiment code different names...
% stims2={'Overlap Cross','Bullseye','Ts','Stacked boxes','Eggs','Dots & Boxes','Crosses','Moon', 'Spread Box','Outlines'};


stims={'cross','bull','T2','eggs','dotbo','empty','moon','windo'};
% Actual names-I gave the experiment code different names...
stims2={'Overlap Cross','Bullseye','Ts','Eggs','Dots & Boxes','Crosses','Moon','Outlines'};

numStims=length(stims);
type='Zel6';

%% Process data
if ~exist(strcat(fname,'.mat'))
    subjCount=zeros(length(stims),1);
    allData=cell(length(stims),1);
    allSubj2=cell(length(stims),1);
    for sti=1:length(stims)
        disp(stims{sti})
        allSubj=unique(data{1}(strcmp(data{5},stims{sti})));
        tempData=nan(4,numTrial*numBlocks*numLen*2,length(allSubj)); % 1st Dim: rt, serial (0)/parallel(1), pres(1)/absent(-1)?, numItem
        tempResp=nan(2,numTrial*numBlocks*numLen*2,length(allSubj));
        tempStim=nan(4,numTrial*numBlocks*2*2,length(allSubj));
        for si=1:length(allSubj)
            % If subject completed all trials
            if sum(strcmp(data{1}(strcmp(data{5},stims{sti})),allSubj{si}))==totTrials
                subjCount(sti)=subjCount(sti)+1;
                allSubj2{sti,subjCount(sti)}=allSubj{si};
                count=[0 0];
                corr=0;
                for bi=1:numBlocks
                    for ti=1:numTrials2
                        inds=strcmp(data{1},allSubj{si}).*strcmp(data{2},type).*(data{3}==bi).*(data{4}==ti).*(strcmp(data{5},stims{sti}));
                        inds2=find(inds);
                        inds3=inds2(1);
                        
                        isTarg=-1;
                        if sum(strcmp(data{7}(inds2),'t'))==1
                            count(1)=count(1)+1;
                            isTarg=1;
                        else
                            count(2)=count(2)+1;
                        end
                        if isTarg==data{11}(inds3)
                            tempData(:,ti+((bi-1)*numTrials2),si)=[data{10}(inds3) data{6}(inds3) isTarg length(inds2)];
                            
                            % 1st Dim: rt, serial (0)/parallel(1), pres(1)/absent(-1)?, numItem
                            corr=corr+1;
                        else
                            disp('')
                        end
                        tempStim(:,ti+((bi-1)*numTrials2),si)=find(strcmp(stims,data{5}(inds3)));
                        tempResp(:,ti+((bi-1)*numTrials2),si)=[isTarg data{11}(inds3)];
                    end
                end
                
            end
        end
        allData{sti}={tempData tempStim tempResp};
    end
    save(strcat(fname,'.mat'),'allData','subjCount','allSubj2')
else
    load(strcat(fname,'.mat'));
end
disp('Num. Subj')
disp(allSubj2)

%% Accuracy
for sti=1:length(stims)
    if subjCount(sti)>0
        allResp=allData{sti}{3};
        temp=allResp(1,:,:)==allResp(2,:,:);
        disp(strcat('Hit rate:',stims{sti}))
        disp(sum(temp(:))/numel(temp))
    end
end

%% Organize into serial vs parallel
serPar=[0 1];
presAbs=[-1 1];
rts=nan(2*numTrial,numLen,length(presAbs),numStims,max(subjCount)+1);
corrs=nan(2*numTrial,numLen,length(presAbs),numStims,max(subjCount)+1);
for sti=1:numStims
    disp(sti)
    currStim=allData{sti}{2};
    currData3=allData{sti}{1};
    for si=1:subjCount(sti)
        sel=currStim(:,:,si)==sti;
        if sum(sel(:))==4*48
            currData=currData3(:,:,si);
            currData2=reshape(currData(sel)',4,numTrials2*2);
            for ni=1:numLen
                for pai=1:length(presAbs)
                    inds=(currData2(3,:)==presAbs(pai)).*(currData2(4,:)==numItems(ni));
                    currRTs=currData2(1,logical(inds));
                    rts(1:length(currRTs),ni,pai,sti,si)=currRTs;
                end
            end
        end
    end
end
rts=rts;
Mrts2=(nanmedian(rts));

np_rts=squeeze(Mrts2(1,:,1,:,:));

rtDifs=squeeze(np_rts(2,:,:)-np_rts(1,:,:))/12;

% figure;set(gcf,'Color','white');
% hold on
% bar(1:numStims,nanmean(rtDifs,2))
% errorbar(1:numStims,nanmean(rtDifs,2),nanstd(rtDifs,[],2)./sqrt(sum(~isnan(rtDifs),2)),'k.')
% set(gca,'XTick',[1:numStims],'XTickLabel',stims)
% ylabel('Search slope (ms/item)')
% hold off

figure;set(gcf,'Color','white');
[a b]=sort(nanmean(rtDifs,2));
hold on
bar(1:numStims,nanmean(rtDifs(b,:),2))
errorbar(1:numStims,nanmean(rtDifs(b,:),2),nanstd(rtDifs(b,:),[],2)./sqrt(sum(~isnan(rtDifs(b,:)),2)),'k.')
set(gca,'XTick',[1:numStims],'XTickLabel',stims(b))
ylabel('Search slope (ms/item)')
hold off


end





