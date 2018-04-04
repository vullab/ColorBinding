function [p]=cdflaplace(x,m,s)
    p = 0.5.*(1+sign(x-m).*(1-exp(-abs(x-m)./s)));