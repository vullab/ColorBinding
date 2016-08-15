function [p] = pdfilaplace(x, m, s)
    p = cdflaplace(x+0.5,m,s)-cdflaplace(x-0.5, m, s);
    