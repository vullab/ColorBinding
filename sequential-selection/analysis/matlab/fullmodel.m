function bigp = fullmodel(sh,sv,pswap,prep,pguess)

sh = 10.^sh; % Discrete Laplace spatial sampling for h component
sv = 10.^sv; % Discrete Laplace spatial sampling for v component
pswap = 1./(1+exp(-pswap)); % Probability swap
prep = 1./(1+exp(-prep)); % Probability repeat guess
pguess = 1./(1+exp(-pguess)); % Probability guess

x = [-2:2];
y = [-2:2];

px = pdfilaplace(x,0,sh);
py = pdfilaplace(y,0,sv);

px = (1-pguess).*px./sum(px)+pguess.*ones(1,5)./5;
py = (1-pguess).*py./sum(py)+pguess.*ones(1,5)./5;

PX = [px.*pswap (1-pswap).*py];
PY = [px.*(1-pswap) pswap.*py];

[BX BY] = ndgrid(PY,PX);

D = (PX+PY)./2;

bigp = (1-prep).*BX.*BY + prep.*diag(D);

