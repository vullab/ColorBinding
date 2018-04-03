function residual=fullmodel2(params)
% Color binding model
% P-Whole, P-Part_A/B, P-Color_A/B, sd_whole, sd_part,sd_color

pWhole=params(1);
pPartA=params(2);
pPartB=params(2);
pColorA=params(3);
pColorB=params(3);
sdWhole=params(4);
sdPartA=params(5);
sdPartB=params(5);
sdColorA=params(5);
sdColorB=params(5);

prob_flip=0;

%% Run model
posCheck=sum(params<0)>0; % Make sure params are positive
probCheck=sum(params(1:3)>=1)>0; % Make sure probs <1

if  posCheck|| probCheck
    % Rule out impossible conditions
    residual=10000;
    
else 
    
    % laplace for each level
    wholeProb=pdfilaplace(inds,0,sdWhole)/sum(pdfilaplace(inds,0,sdWhole));
    partAprob=pdfilaplace(inds,0,sdPartA)/sum(pdfilaplace(inds,0,sdPartA));
    partBprob=pdfilaplace(inds,0,sdPartB)/sum(pdfilaplace(inds,0,sdPartB));
    colorAprob=pdfilaplace(inds,0,sdColorA)/sum(pdfilaplace(inds,0,sdColorA));
    colorBprob=pdfilaplace(inds,0,sdColorB)/sum(pdfilaplace(inds,0,sdColorB));
    
    guessProb=ones(10)/10;
    
    
    % Set up matrices
    wholeMatrix=nan(10);
    wholeMatrixSwap=nan(10);
end









