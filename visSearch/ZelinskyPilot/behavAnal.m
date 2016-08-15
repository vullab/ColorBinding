%% Analyze Visual Search task
clc;
clear all;
close all;

%% Load data
fpath=cd;
fname=fullfile('pilotData');
datafile=fopen(fullfile(fpath,strcat(fname,'.txt')));
data =textscan(datafile,'%s %s %f %f %s %f %s %f %f %f %f', 'delimiter',';');

% Shift so starts at 1
data{3}=data{3}+1;
data{4}=data{4}+1;

%% Select data set
type='Zel1';
if strcmp(type,type)
    subjs={'TEST1','TEST2'};
    numSubj=length(subjs);
    stims={'oq'};
    numStims=length(stims);
    numTrials=6;
    numSize=[5 17];
    numTrials2=6*length(numSize)*2; % Trials x numSizes x pres/absent
    numBlocks=length(unique(data{3}(strcmp(data{2},type))));
    allData=nan(4,numTrials*numBlocks*2*2,length(stims),numSubj);
    % 1st Dim: rt, serial (0)/parallel(1), pres(1)/absent(-1)?, numItem
end

type='Zel2';
if strcmp(type,type)
    subjs={'A3ORE2BNURPVNI','ANK8K5WTHJ61C', 'A1BNQ6H4SJZ2X5','A1Q71TL2W0V6FE', ...
        'A1XLGIFFGB01EU','A1Y0Y6U906ABT5','A2A1D52ZPSW6L9','A3T7WG3I0BW1C1'};
    numSubj=length(subjs);
    stims={'oq'};
    numStims=length(stims);
    numTrials=6;
    numSize=[5 17];
    numTrials2=6*length(numSize)*2; % Trials x numSizes x pres/absent
    numBlocks=length(unique(data{3}(strcmp(data{2},type))));
    allData=nan(4,numTrials*numBlocks*2*2,length(stims),numSubj);
    % 1st Dim: rt, serial (0)/parallel(1), pres(1)/absent(-1)?, numItem
end

%% Organize all trials
for si=1:numSubj
    for sti=1:numStims
        for bi=1:numBlocks
            for ti=1:numTrials2
                inds=strcmp(data{1},subjs{si}).*strcmp(data{2},type).*strcmp(data{5},stims{sti}).*(data{3}==bi).*(data{4}==ti);
                inds2=find(inds);
                inds3=inds2(1);
                allData(:,ti+((bi-1)*numTrials2),sti,si)=[data{10}(inds3) data{6}(inds3) data{11}(inds3) length(inds2)];
                % 1st Dim: rt, serial (0)/parallel(1), pres(1)/absent(-1)?, numItem
            end
        end
        
    end
end

%% Organize reaction time by condition/trial type
serPar=[0 1];
presAbs=[-1 1];
rts=nan(numTrials,length(numSize),length(serPar),length(presAbs),numStims,numSubj);
for si=1:numSubj
    for sti=1:numStims
        currData=allData(:,:,sti,si);
        for ni=1:length(numSize)
            for spi=1:length(serPar)
                for pai=1:length(presAbs)
                    inds=(currData(2,:)==serPar(spi)).*(currData(3,:)==presAbs(pai)).*(currData(4,:)==numSize(ni));
                    currRTs=currData(1,logical(inds));
                    rts(:,ni,spi,pai,sti,si)=currRTs;
                end
            end
        end
    end
end
Mrts=(median(rts));

currStim=1; % Make this for loop for later version
figure;set(gcf,'color','white')
hold on
% Positive serial
ps_rts=squeeze(Mrts(1,:,1,2,currStim,:));
errorbar(numSize,mean(ps_rts,2),std(ps_rts,[],2)./sqrt(numSubj))

% Negative serial
ns_rts=squeeze(Mrts(1,:,1,1,currStim,:));
errorbar(numSize,mean(ns_rts,2),std(ns_rts,[],2)./sqrt(numSubj))

% Positive parallel
pp_rts=squeeze(Mrts(1,:,2,2,currStim,:));
errorbar(numSize,mean(pp_rts,2),std(pp_rts,[],2)./sqrt(numSubj))

% Negative parallel
np_rts=squeeze(Mrts(1,:,2,1,currStim,:));
errorbar(numSize,mean(np_rts,2),std(np_rts,[],2)./sqrt(numSubj))

xlabel('Num Items')
ylabel('RT (ms)')
title(stims{currStim})
hold off





