function [full_llk2 simData]=fullmodel5v2(params,data)
% v3-Original model
% v4-Redistribute lost diagonal to other options, adding p_flip
% 4v2-Return llks
% v4-Trying with diag redistribution...Looks exactly the same
p_whole=params(1);
p_partA=params(2);
p_partB=params(2);
p_colorA=params(3);
p_colorB=params(3);
sd_whole=params(4);
sd_partA=params(5);
sd_partB=params(5);
sd_colorA=params(6);
sd_colorB=params(6);
p_flip=params(7);

Aopt=1:5;
Bopt=6:10;

% Set up Laplace density function
inds = [-2:2];
wholeProb=pdfilaplace(inds,0,sd_whole)/sum(pdfilaplace(inds,0,sd_whole));
partA_prob=pdfilaplace(inds,0,sd_partA)/sum(pdfilaplace(inds,0,sd_partA));
partB_prob=pdfilaplace(inds,0,sd_partB)/sum(pdfilaplace(inds,0,sd_partB));
colorA_prob=pdfilaplace(inds,0,sd_colorA)/sum(pdfilaplace(inds,0,sd_colorA));
colorB_prob=pdfilaplace(inds,0,sd_colorB)/sum(pdfilaplace(inds,0,sd_colorA));
guess_prob=ones(1,10)/9;

%% Probability matrices

% Whole object sampling
whole_matrix=zeros(10,10);
whole_matrix(Aopt,Bopt)=diag(wholeProb);

% A Part sampling
Apart_Bpart_matrix=zeros(10,10);
Apart_Bpart_matrix(Aopt,Bopt)=partA_prob'*partB_prob;

Apart_Acolor_matrix=zeros(10,10);
Apart_Acolor_matrix(Aopt,Aopt)=partA_prob'*colorA_prob; % TO DO: Will need to account for diags later
diagSum=sum(diag(Apart_Acolor_matrix(Aopt,Aopt)));
Apart_Acolor_matrix(logical(eye(10)))=0;


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

Acolor_Bcolor_matrix=zeros(10,10);
Acolor_Bcolor_matrix(Aopt,Bopt)=colorA_prob'*colorB_prob;

% B color sampling
Bcolor_Bpart_matrix=zeros(10,10);
Bcolor_Acolor_matrix=zeros(10,10);
Bcolor_Bcolor_matrix=zeros(10,10);
G_Bpart_matrix=zeros(10,10);
G_Bpart_matrix=zeros(10,10);
Bcolor_Bpart_matrix(Bopt,Bopt)=colorB_prob' *partB_prob;
diagSum=sum(diag(Bcolor_Bpart_matrix(Bopt,Bopt)));
Bcolor_Bpart_matrix(logical(eye(10)))=0;

Bcolor_Acolor_matrix(Bopt,Aopt)=colorB_prob' *colorA_prob;
Bcolor_Bcolor_matrix(Bopt,Bopt)=colorB_prob' *colorB_prob;
diagSum=sum(diag(Bcolor_Bcolor_matrix(Bopt,Bopt)));
Bcolor_Bcolor_matrix(logical(eye(10)))=0;

G_Bpart_matrix(:,Bopt)=guess_prob'*partB_prob;
G_Bpart_matrix(logical(eye(10)))=0;

% Pure guessing
GG_matrix=zeros(10,10);
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
    (p_colorA * p_colorB) * Acolor_Bcolor_matrix);
% Erased repeated guessing

% And you guess a B color for A
llk_AguessB=(p_colorB * p_partB) * Bcolor_Bpart_matrix + ...
    (1-p_partB) * ( ...
    (p_colorB *  p_colorA) * Bcolor_Acolor_matrix + ...
    (p_colorB * p_colorB) * Bcolor_Bcolor_matrix);
% Erased repeated guessing

% And you guess any color for A
llk_AguessRand=((1 - p_colorA - p_colorB) * p_partB) * G_Bpart_matrix;

% And you don't get Part B either
llk_guessAB=(1-p_partB) * ( ...
    ((1 - p_colorA - p_colorB) * (1 - p_colorA - p_colorB)) * GG_matrix );
% Erased repeated guessing


% Full likelihood
full_llk=llk_whole+(1-p_whole)*(llk_partA+llk_AguessA+llk_AguessB+llk_AguessRand+llk_guessAB);

% Flip llk-Did people flip the colors?
flip_llk=rot90(rot90(full_llk));
full_llk2=((1-p_flip) * full_llk + p_flip * flip_llk);

simData=full_llk2*sum(data(:));
