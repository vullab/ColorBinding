function PA = mIID(b,a)
    b = 10.^b;
    a = max(0, min(1, a));
    
    
% bhh: pdf for H-h
% bhv: pdf for H-v
% bvv: pdf for V-V
% bvh: pdf for V-h


    p1 = pdfilaplace([-2:2], 0, b);
    p1 = p1 ./ sum(p1);

    [P1 P2] = ndgrid([p1.*a p1.*(1-a)], [p1.*(1-a)  p1.*(a)]);
    PA = reshape(P1.*P2, [5 2 5 2]);