function bigp = fullmodel2(sh2,sv2,pswap2,pguess2)
% v2-Probability mass erased from diagonal is being redirected to the other
% quadrants. 

% h by v
sh = 10.^sh2; % Discrete Laplace spatial sampling for h component
sv = 10.^sv2; % Discrete Laplace spatial sampling for v component
pswap = 1./(1+exp(-pswap2)); % Probability swap
pguess = 1./(1+exp(-pguess2)); % Probability guess

x = [-2:2];
y = [-2:2];

% Probability of sampling from a nearby location
px = pdfilaplace(x,0,sh);
py = pdfilaplace(y,0,sv);

BX2=nan(10,10);
BY2=nan(10,10);
for bi=1:10
    filter=ones(1,10);
    %filter(bi)=0;
    
    % For x
    tempX=[px py];
    tempX=tempX.*filter;
    
    tempX=(1-pguess).*tempX+pguess.*filter./10;
    tempX(1:5)=tempX(1:5)*(1-pswap);
    tempX(6:10)=tempX(6:10)*(pswap);
    BX2(bi,:)=tempX;
    
    %For Y
    tempY=[px py];
    tempY=tempY.*filter;
    
    tempY=(1-pguess).*tempY+pguess.*filter./10;
    tempY(1:5)=tempY(1:5)*(pswap);
    tempY(6:10)=tempY(6:10)*(1-pswap);
    
    BY2(:,bi)=tempY;
    
end

% Redistribute probabilities
BXextra=sum(BX2(logical(eye(10))));
BX3=BX2;
BX3(logical(eye(10)))=0;

BYextra=sum(BY2(logical(eye(10))));
BY3=BY2;
BY3(logical(eye(10)))=0;

bigp=BX3.*BY3+diag(10)*10^-10;


% % Adjust for actually sampling object vs. randomly guessing that
% px = (1-pguess).*px./sum(px)+pguess.*ones(1,5)./5;
% py = (1-pguess).*py./sum(py)+pguess.*ones(1,5)./5;
% 
% PX = [px.*pswap (1-pswap).*py];
% PY = [px.*(1-pswap) pswap.*py];
% 
% [BX BY] = ndgrid(PY,PX);
% 
% bigp = BX.*BY ;

