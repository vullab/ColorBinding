function [resid full_llk]=fullmodel7v2_llk(params,data)
% v3-Original model
% v4-Redistribute lost diagonal to other options, adding p_flip
% v5-Testing without redistribution...Looks exactly the same
% v6-Most basic, 1 noise, no flipping
% v6v2-Modified for old model with double guessing
p_whole=params(1);
p_partA=params(2);
p_partB=params(2);
p_colorA=params(3);
p_colorB=params(3);
wSamp=params(4);
pSamp=params(5);
cSamp=params(6);

Aopt=1:5;
Bopt=6:10;
% If parameters are within accepted range
if (p_colorA+p_colorB)<=1 && sum(params<0)==0 && (sum(params([1:3]))<=1)
    % Set up Laplace density function
    inds = [-2:2];
    wholeProb=pdfilaplace(inds,0,wSamp)/sum(pdfilaplace(inds,0,wSamp));
    partA_prob=pdfilaplace(inds,0,pSamp)/sum(pdfilaplace(inds,0,pSamp));
    partB_prob=pdfilaplace(inds,0,pSamp)/sum(pdfilaplace(inds,0,pSamp));
    colorA_prob=pdfilaplace(inds,0,cSamp)/sum(pdfilaplace(inds,0,cSamp));
    colorB_prob=pdfilaplace(inds,0,cSamp)/sum(pdfilaplace(inds,0,cSamp)); 
    guess_prob=ones(1,10)/10;
    
    %% Probability matrices
    
    % Whole object sampling
    whole_matrix=zeros(10,10); 
    whole_matrix(Aopt,Bopt)=diag(wholeProb);
    
    % A Part sampling
    Apart_Bpart_matrix=zeros(10,10); 
    Apart_Bpart_matrix(Aopt,Bopt)=partA_prob'*partB_prob;
    
    Apart_Acolor_matrix=zeros(10,10);
    Apart_Acolor_matrix(Aopt,Aopt)=partA_prob'*colorA_prob; 
    
    Apart_Bcolor_matrix=zeros(10,10); 
    Apart_Bcolor_matrix(Aopt,Bopt)=partA_prob'*colorB_prob;
    
    Apart_G_matrix=zeros(10,10);
    Apart_G_matrix(Aopt,:)=partA_prob'*guess_prob;
    
    % A color sampling
    Acolor_Bpart_matrix=zeros(10,10); 
    Acolor_Bpart_matrix(Aopt,Bopt)=colorA_prob'*partB_prob;
    Acolor_Acolor_matrix=zeros(10,10); 
    Acolor_Acolor_matrix(Aopt,Aopt)=colorA_prob'*colorA_prob; % Repeat
    
    Acolor_Bcolor_matrix=zeros(10,10); 
    Acolor_Bcolor_matrix(Aopt,Bopt)=colorA_prob'*colorB_prob;
    
    % B color sampling
    Bcolor_Bpart_matrix=zeros(10,10); 
    Bcolor_Acolor_matrix=zeros(10,10); 
    Bcolor_Bcolor_matrix=zeros(10,10); 
    G_Bpart_matrix=zeros(10,10); 
    Bcolor_Bpart_matrix(Bopt,Bopt)=colorB_prob' *partB_prob;
    
	Bcolor_Acolor_matrix(Bopt,Aopt)=colorB_prob' *colorA_prob;
	Bcolor_Bcolor_matrix(Bopt,Bopt)=colorB_prob' *colorB_prob;
    
    G_Bpart_matrix(:,Bopt)=guess_prob'*partB_prob;
    
    % Pure guessing
    GG_matrix=zeros(10,10); 
	GG_matrix(:,:)=guess_prob'*guess_prob;
    
    % Double guessing
    % Treat double guessing as remembering one of the correct parts with
    % noise
    G2_matrix=zeros(10,10); 
    G2_matrix(logical(eye(10)))=[partA_prob partB_prob];
    
    Acolor_DR_matrix=zeros(10,10); 
    Acolor_DR_matrix(Aopt,Aopt)=G2_matrix(Aopt,Aopt);
    
    Bcolor_DR_matrix=zeros(10,10); 
    Bcolor_DR_matrix(Bopt,Bopt)=G2_matrix(Bopt,Bopt);
    
    
    %% Full likelihood
    
    %% Prob whole object
    llk_whole=p_whole*whole_matrix;
    
    %% Sample Part A and do X for part B
    llk_partA=(p_partA * p_partB) * Apart_Bpart_matrix + ... % Sample A and B parts
        (1-p_partB) * (   ... % If you don't remember the B part...
        (p_partA *  p_colorA) * Apart_Acolor_matrix + ... % And you sample an A color
        (p_partA * p_colorB) * Apart_Bcolor_matrix + ... % And you sample a B color
        (p_partA *  (1 - p_colorA - p_colorB)) * Apart_G_matrix ); % And you decide to randomly guess
    
    %% If you don't get Part A...
    
    % And you guess an A color for A
    llk_AguessA=(p_colorA * p_partB) * Acolor_Bpart_matrix + ...
        (1-p_partB) * ( ...
        (p_colorA *  p_colorB) * Acolor_Acolor_matrix + ...
        (p_colorA * p_colorB) * Acolor_Bcolor_matrix) + ...
        (p_colorA * (1 - p_colorA - p_colorB)) * Acolor_DR_matrix ;
        % Erased repeated guessing
    
    % And you guess a B color for A
    llk_AguessB=(p_colorB * p_partB) * Bcolor_Bpart_matrix + ...
        (1-p_partB) * ( ...
        (p_colorB *  p_colorA) * Bcolor_Acolor_matrix + ...
        (p_colorB * p_colorB) * Bcolor_Bcolor_matrix) + ...
        (p_colorB * (1 - p_colorA - p_colorB)) * Bcolor_DR_matrix ;
        % Erased repeated guessing
    
    % And you guess any color for A
    llk_AguessRand=((1 - p_colorA - p_colorB) * p_partB) * G_Bpart_matrix;
    
    % And you don't get Part B either
    llk_guessAB=(1-p_partB) * ( ...
        ((1 - p_colorA - p_colorB) *  p_colorA) * Acolor_DR_matrix + ...
		((1 - p_colorA - p_colorB) * p_colorB) * Bcolor_DR_matrix + ...
        ((1 - p_colorA - p_colorB) * (1 - p_colorA - p_colorB)) * GG_matrix );
        % Erased repeated guessing
    
        
    % Full likelihood
    full_llk=llk_whole+(1-p_whole)*(llk_partA+ ...
        (1-p_partA)*(llk_AguessA+llk_AguessB+llk_AguessRand+llk_guessAB));
    
    simData=full_llk*sum(data(:));
    residTemp=simData-data;
    resid=sum(residTemp(:).^2);
else
    resid=100000000000;
end