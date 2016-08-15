function bigp = modelme(sx,sy,p)
% sx = 1;
% sy = 1;
% p = 0.9;

sx = 10.^sx;
sy = 10.^sy;
p = 1./(1+exp(-p));

x = [-2:2];
y = [-2:2];

px = pdfilaplace(x,0,sx);
py = pdfilaplace(y,0,sy);

px = px./sum(px);
py = py./sum(py);

[PX PY] = ndgrid(px,py);

bigp = p.*(PX.*PY)+(1-p)./numel(PX);

