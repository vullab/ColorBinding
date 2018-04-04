function [resid full_llk]=fullmodel8_llk(params,data)
% v3-Original model
% v4-Redistribute lost diagonal to other options, adding p_flip
% v5-Testing without redistribution...Looks exactly the same
% v6-Most basic, 1 noise, no flipping
% v8-Redistributing lost diagonal probability differently
p_whole=params(1);
p_partA=params(2);
p_partB=params(2);
p_colorA=params(3);
p_colorB=params(3);
sdSamp=params(4);

Aopt=1:5;
Bopt=6:10;
% If parameters are within accepted range
if (p_colorA+p_colorB)<=1 && sum(params<0)==0 && (sum(params([1:3]))<=1)
    % Set up Laplace density function
    inds = [-2:2];
    wholeProb=pdfilaplace(inds,0,sdSamp)/sum(pdfilaplace(inds,0,sdSamp));
    partA_prob=pdfilaplace(inds,0,sdSamp)/sum(pdfilaplace(inds,0,sdSamp));
    partB_prob=pdfilaplace(inds,0,sdSamp)/sum(pdfilaplace(inds,0,sdSamp));
    colorA_prob=pdfilaplace(inds,0,sdSamp)/sum(pdfilaplace(inds,0,sdSamp));
    colorB_prob=pdfilaplace(inds,0,sdSamp)/sum(pdfilaplace(inds,0,sdSamp)); 
    guess_prob=ones(1,10)/9;
    
    %% Probability matrices
    
    % Whole object sampling
    whole_matrix=zeros(10,10); 
    whole_matrix(Aopt,Bopt)=diag(wholeProb);
    
    % A Part sampling
    Apart_Bpart_matrix=zeros(10,10); 
    Apart_Bpart_matrix(Aopt,Bopt)=partA_prob'*partB_prob;
    
    Apart_Acolor_matrix=zeros(10,10);
    Apart_Acolor_matrix(Aopt,Aopt)=partA_prob'*colorA_prob; 
    diagSum=sum(diag(Apart_Acolor_matrix(Aopt,Aopt)));
    Apart_Acolor_matrix(logical(eye(10)))=0;  
    currSum=sum(Apart_Acolor_matrix(:));
    other=ones(10,10);other(logical(eye(10)))=0;
    other(Bopt,Bopt)=0;
    other=other/sum(other(:));
    Apart_Acolor_matrix=Apart_Acolor_matrix+other*currSum;
    Apart_Acolor_matrix=Apart_Acolor_matrix/sum(Apart_Acolor_matrix(:));
    
    Apart_Bcolor_matrix=zeros(10,10); 
    Apart_Bcolor_matrix(Aopt,Bopt)=partA_prob'*colorB_prob;
    
    Apart_G_matrix=zeros(10,10);
    Apart_G_matrix(Aopt,:)=partA_prob'*guess_prob;
    Apart_G_matrix(logical(eye(10)))=0;
    
    % A color sampling
    Acolor_Bpart_matrix=zeros(10,10); 
    Acolor_Bpart_matrix(Aopt,Bopt)=colorA_prob'*partB_prob;
    Acolor_Acolor_matrix=zeros(10,10); 
    
    Acolor_Acolor_matrix(Aopt,Aopt)=colorA_prob'*colorA_prob; % Repeat
    diagSum=sum(diag(Acolor_Acolor_matrix(Aopt,Aopt)));
    Acolor_Acolor_matrix(logical(eye(10)))=0;
    currSum=sum(Acolor_Acolor_matrix(:));
    other=ones(10,10);other(logical(eye(10)))=0;
    other(Bopt,Bopt)=0;
    other=other/sum(other(:));
    Acolor_Acolor_matrix=Acolor_Acolor_matrix+other*currSum;
    Acolor_Acolor_matrix=Acolor_Acolor_matrix/sum(Acolor_Acolor_matrix(:));
    
    Acolor_Bcolor_matrix=zeros(10,10); 
    Acolor_Bcolor_matrix(Aopt,Bopt)=colorA_prob'*colorB_prob;
    
    % B color sampling
    Bcolor_Bpart_matrix=zeros(10,10); 
    Bcolor_Acolor_matrix=zeros(10,10); 
    Bcolor_Bcolor_matrix=zeros(10,10); 
    G_Bpart_matrix=zeros(10,10); 
    Bcolor_Bpart_matrix(Bopt,Bopt)=colorB_prob' *partB_prob;
    diagSum=sum(diag(Bcolor_Bpart_matrix(Bopt,Bopt)));
    Bcolor_Bpart_matrix(logical(eye(10)))=0;
    currSum=sum(Bcolor_Bpart_matrix(:));
    other=ones(10,10);other(logical(eye(10)))=0;
    other(Aopt,Aopt)=0;
    other=other/sum(other(:));
    Bcolor_Bpart_matrix=Bcolor_Bpart_matrix+other*currSum;
    Bcolor_Bpart_matrix=Bcolor_Bpart_matrix/sum(Bcolor_Bpart_matrix(:));
    
	Bcolor_Acolor_matrix(Bopt,Aopt)=colorB_prob' *colorA_prob;
	Bcolor_Bcolor_matrix(Bopt,Bopt)=colorB_prob' *colorB_prob;
    diagSum=sum(diag(Bcolor_Bcolor_matrix(Bopt,Bopt)));
    Bcolor_Bcolor_matrix(logical(eye(10)))=0;
    currSum=sum(Bcolor_Bcolor_matrix(:));
    other=ones(10,10);other(logical(eye(10)))=0;
    other(Aopt,Aopt)=0;
    other=other/sum(other(:));
    Bcolor_Bcolor_matrix=Bcolor_Bcolor_matrix+other*currSum;
    Bcolor_Bcolor_matrix=Bcolor_Bcolor_matrix/sum(Bcolor_Bcolor_matrix(:));
    
    G_Bpart_matrix(:,Bopt)=guess_prob'*partB_prob;
    G_Bpart_matrix(logical(eye(10)))=0;
    
    % Pure guessing
    GG_matrix=zeros(10,10); 
	GG_matrix(:,:)=guess_prob'*guess_prob;
    GG_matrix(logical(eye(10)))=0;
    
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
        (p_colorA * (1 - p_colorA - p_colorB)) * Apart_G_matrix ;
        % Erased repeated guessing
    
    % And you guess a B color for A
    llk_AguessB=(p_colorB * p_partB) * Bcolor_Bpart_matrix + ...
        (1-p_partB) * ( ...
        (p_colorB *  p_colorA) * Bcolor_Acolor_matrix + ...
        (p_colorB * p_colorB) * Bcolor_Bcolor_matrix) +...
        (p_colorB * (1 - p_colorA - p_colorB)) *G_Bpart_matrix; %If you remember the color of part B but don't remember anything else
        % Erased repeated guessing
    
    % And you guess any color for A
    llk_AguessRand=((1 - p_colorA - p_colorB) * p_partB) * G_Bpart_matrix;
    
    % And you don't get Part B either
    llk_guessAB=(1-p_partB) * ( ...
        (p_colorA * (1 - p_colorA - p_colorB)) * Apart_G_matrix + ...
        (p_colorB * (1 - p_colorA - p_colorB)) *G_Bpart_matrix + ...
        ((1 - p_colorA - p_colorB) * (1 - p_colorA - p_colorB)) * GG_matrix );
        % Erased repeated guessing
    
        
    % Full likelihood
    full_llk=llk_whole+(1-p_whole)*(llk_partA+ ...
        (1-p_partA)*(llk_AguessA+llk_AguessB+llk_AguessRand+llk_guessAB));
    
    simData=full_llk*sum(data(:));
    residTemp=simData-data;
    resid=sum(residTemp(:).^2);
else
    resid=sum(data(:))^2;
end