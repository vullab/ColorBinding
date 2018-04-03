function [rtDifs stims]=behavAnalysis2()
% v2-For next object set
%% Analyze object visual search
clear all

%% Load data

fpath=cd;
fname=fullfile('needHayData2');
datafile=fopen(fullfile(fpath,strcat(fname,'.txt')));
data =textscan(datafile,'%s %s %f %f %s %f %s %f %f %f %f', 'delimiter',';');

% Shift so starts at 1
data{3}=data{3}+1;
data{4}=data{4}+1;

type='Zel4';
if strcmp(type,type)
    subjs={'A4TAQBKTB06BG','A2631BM7J7H37K','A1W8EUA2YVAANQ','A15NH461BKAYCX', ...
        'A3OMUSG91MTI3H','AG4MMHVYMTXFD','A2XUADP5L61HQ5', ...
        'ARQHSPUFMBMA5','A2QSSS14HVUS42','AMNSX3GEWYDAH','A21LJN2RQBOTEA', ...
        'A20H0JHSC0K14P','A74EYSZ2A1Z3V','A7V4CVENA0DYV','A2DB5PGPTMYVSD', ...
        'A2PB7WC0Y3T77L','A16S6A7KRJEQYD','A2GS6VJEP91PA9','A2H5FQFR4C014A', ...
        'AIYGT8I9PZ9CC', 'A2J5DN5UMU0A3Z','A325BIJIG3AK1T','A2X2PIPDCZJD2A'...
        'A2EAN17FAA9AQF', ...
    };
    % ,'A3E73BVSABJ7LM'
    numSubj=length(subjs);
    stims={'eggs','dotbo','empty'};
    numStims=length(stims);
    numTrials=6;
    numSize=[5 17];
    numTrials2=6*length(numSize)*2; % Trials x numSizes x pres/absent
    numBlocks=length(unique(data{3}(strcmp(data{2},type))));
    allData=nan(4,numTrials*numBlocks*2*2,numSubj); % 1st Dim: rt, serial (0)/parallel(1), pres(1)/absent(-1)?, numItem
    allStim=nan(4,numTrials*numBlocks*2*2,numSubj);
    allResp=nan(2,numTrials*numBlocks*2*2,numSubj); 
    
end

%% Organize data

if ~exist('procData2.mat')
    for si=1:numSubj
        count=[0 0];
        for bi=1:numBlocks
            for ti=1:numTrials2
                inds=strcmp(data{1},subjs{si}).*strcmp(data{2},type).*(data{3}==bi).*(data{4}==ti);
                inds2=find(inds);
                inds3=inds2(1);
                
                isTarg=-1;
                if sum(strcmp(data{7}(inds2),'t'))==1
                    count(1)=count(1)+1;
                    isTarg=1;
                else
                    count(2)=count(2)+1;
                end
                allData(:,ti+((bi-1)*numTrials2),si)=[data{10}(inds3) data{6}(inds3) isTarg length(inds2)];
                allStim(:,ti+((bi-1)*numTrials2),si)=find(strcmp(stims,data{5}(inds3)));
                % 1st Dim: rt, serial (0)/parallel(1), pres(1)/absent(-1)?, numItem
                allResp(:,ti+((bi-1)*numTrials2),si)=[isTarg data{11}(inds3)];
                
            end
        end
        if count(1)~=count(2)
           disp('') 
        end
    end
    save('procData2.mat','allData','allStim','allResp')
else
    load('procData2.mat')
end

temp=allResp(1,:,:)==allResp(2,:,:);
disp('Hit rate')
disp(sum(temp(:))/numel(temp))

%% Organize reaction time by condition/trial type
serPar=[0 1];
presAbs=[-1 1];
rts=nan(numTrials,length(numSize),length(serPar),length(presAbs),numStims,numSubj);
corrs=nan(numTrials,length(numSize),length(serPar),length(presAbs),numStims,numSubj);
for si=1:numSubj
    disp(si)
    for sti=1:numStims
        sel=allStim(:,:,si)==sti;
        currData=allData(:,:,si);
        currData2=reshape(currData(sel)',4,numTrials2*2);
        for ni=1:length(numSize)
            for spi=1:length(serPar)
                for pai=1:length(presAbs)
                    inds=(currData2(2,:)==serPar(spi)).*(currData2(3,:)==presAbs(pai)).*(currData2(4,:)==numSize(ni));
                    currRTs=currData2(1,logical(inds));
                    rts(:,ni,spi,pai,sti,si)=currRTs;
                end
            end
        end
    end
end
Mrts=(median(rts));

%% Are the orange-blue/blue-orange different for any of the stimuli?

% For the negative conditions, were any of the colors significantly harder?
obCol=(Mrts(1,:,1,1,:,:));
boCol=(Mrts(1,:,2,1,:,:));

rtDif=squeeze(obCol)-squeeze(boCol);

disp('Are any of the colors particularly more difficult?')
for sti=1:numStims
    rtDifTemp=squeeze(rtDif(:,sti,:));
    rtDifTemp=rtDifTemp(:);
    [h p ci stats]=ttest(rtDifTemp);
    disp(stims{sti})
    disp(strcat('p: ',num2str(p)))
end

%% Find differences for each condition

% Ignore serPar this time
presAbs=[-1 1];
serPar=[0 1];
rts=nan(numTrials*length(serPar),length(numSize),length(presAbs),numStims,numSubj);
for si=1:numSubj
    for sti=1:numStims
        sel=allStim(:,:,si)==sti;
        currData=allData(:,:,si);
        currData2=reshape(currData(sel)',4,numTrials2*2);
        for ni=1:length(numSize)
            for pai=1:length(presAbs)
                inds=(currData2(3,:)==presAbs(pai)).*(currData2(4,:)==numSize(ni));
                currRTs=currData2(1,logical(inds));
                rts(:,ni,pai,sti,si)=currRTs;
            end
        end
        
    end
end
Mrts2=(median(rts));

np_rts=squeeze(Mrts2(1,:,1,:,:));

rtDifs=squeeze(np_rts(2,:,:)-np_rts(1,:,:));

% figure;set(gcf,'Color','white');
% hold on
% bar(1:3,mean(rtDifs,2))
% errorbar(1:3,mean(rtDifs,2),std(rtDifs,[],2)./sqrt(numSubj),'k.')
% set(gca,'XTick',[1 2 3 ],'XTickLabel',stims)
% ylabel('Reaction time (ms)')
% hold off






