clear all
close all


test14 = 1;

fpath = '../data/';
files = dir(sprintf('%s*_1.txt',fpath));

nsubs = 0;

for fi = [1:length(files)]
    curfile = fopen(sprintf('%s%s', fpath, files(fi).name));
    discard = fgetl(curfile);
    
    q = textscan(curfile,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f ', 'delimiter', ',');
    if((q{14}(1) == test14) & (length(q{14})>100))
        nsubs = nsubs+1;
        z{nsubs} = q;
    end
end
nsubs
% columns!
%  1    cue-length
%  2    ms-precue
%  3    resp-v-hv
%  4    ms-st-cue
%  5    nitems
%  6    resp-h-pos
%  7    resp-v-pos
%  8    ms-stimon
%  9    resp-h-hv
% 10    cue-loc-int
% 11    cue=loc-x
% 12    cue-loc-y
% 13    radius
% 14    bars-or-spot
% 15    npractice
% 16    ntrials

resps = zeros(5, 5, 2, 2, nsubs);
r10 = zeros(10, 10, nsubs);
r10x = zeros(10, 10, nsubs);

for s = [1:nsubs]
    
    hpos = z{s}{6};
    vpos = z{s}{7};
    h_hv = z{s}{9};
    v_hv = z{s}{3};
    
    idxbad = (hpos == vpos) & (h_hv == v_hv);
    badap(s) = sum(idxbad)./length(idxbad);
%     
%     hpos(idxbad) = [];
%     vpos(idxbad) = [];
%     h_hv(idxbad) = [];
%     v_hv(idxbad) = [];
    
    h_c = h_hv==1;
    v_c = v_hv==2;
    
    
    varhmarg(s) = var(hpos);
    varvmarg(s) = var(vpos);
    q = cov(hpos,vpos);
    covhvmarg(s) = q(1,2);
    mhhv(s) = mean(h_hv);
    mvhv(s) = mean(v_hv);
    
    % divided into things
    idx12 = h_hv==1 & v_hv==2;
    idx21 = h_hv==2 & v_hv==1;
    idx22 = h_hv==2 & v_hv==2;
    
    % 11
    for h = [1:2]
        for v = [1:2]
            idx = h_hv==h & v_hv==v;
            
            varh{h}{v}(s) = var(hpos(idx));
            varv{h}{v}(s) = var(vpos(idx));
            q = cov(hpos(idx),vpos(idx));
            covhv{h}{v}(s) = q(1,2);
            n(h,v,s) = sum(idx);
        end
    end
    
    
    for i = [1:length(hpos)]
%         resps(hpos(i)+3, vpos(i)+3, h_hv(i)+1, v_hv(i)+1, s) = resps(hpos(i)+3, vpos(i)+3, h_hv(i)+1, v_hv(i)+1, s)+1;
        idxh = hpos(i)+3 + 5.*(h_c(i));
        idxv = vpos(i)+3 + 5.*(v_c(i));

        r10(idxh, idxv,s) = r10(idxh,idxv,s) +1;
        
        idxh = hpos(i)+3 + 5.*(h_hv(i)-1);
        idxv = vpos(i)+3 + 5.*(v_hv(i)-1);

        r10x(idxh, idxv,s) = r10x(idxh,idxv,s) +1;
    end
end

%%

for h = [1:2]
    for v = [1:2]
        vh.m(h,v) = mean(varh{h}{v});
        vh.s(h,v) = std(varh{h}{v})./sqrt(length(varh{h}{v}));
        vv.m(h,v) = mean(varv{h}{v});
        vv.s(h,v) = std(varv{h}{v})./sqrt(length(varv{h}{v}));
        cv.m(h,v) = mean(covhv{h}{v});
        cv.s(h,v) = std(covhv{h}{v})./sqrt(length(covhv{h}{v}));
    end
end
        


%%

p10x = sum(r10x,3)./sum(r10x(:));
q10x = p10x;
q10x(eye(size(p10x))==1) = 0;

figure();
imagesc(sqrt(p10x)), colormap gray;

figure();
plot(sum(p10x,1), 'r', 'LineWidth', 2);
hold on;
plot(sum(p10x,2), 'b', 'LineWidth', 2);

% diags = [-9:9];
% for i = [1:length(diags)]
%     meandiag(i) = mean(diag(p10x,diags(i)));
% end
% figure();
% plot(diags, meandiag, 'k', 'LineWidth', 2);

%% make 

% pg = 0.1;
% pr = 0.25;
% phhv = 0.8;
% pvhv = 0.2;
% phspa = [0.1 0.15 0.5 0.15 0.1];
% pvspa = [0.1 0.15 0.5 0.15 0.1];
% 
% ph = pg./10+(1-pg).*[phhv.*phspa (1-phhv).*phspa];
% pv = pg./10+(1-pg).*[pvhv.*pvspa (1-pvhv).*pvspa];
% 
% ptot = ph'*pv;
% 
% figure();
% imagesc(ptot-p10x)

%% marginal estimators

% p10x = sum(r10x,3)./sum(r10x(:));
% 
% phest = sum(p10x');
% pvest = sum(p10x);
% phhv = sum(phest(1:5));
% pvhv = sum(pvest(1:5));


for i = [1:size(r10x, 3)]
z2 = r10x(6:10, 1:5,i);
z1 = r10x(1:5, 6:10,i);
fx1 = @(params)(-sum(sum(log10(modelme(params(1), params(2), params(3))).*z1)));
fx2 = @(params)(-sum(sum(log10(modelme(params(1), params(2), params(3))).*z2)));
p1(i,1:3) = fminsearch(fx1, [0 0 0]);
p2(i,1:3) = fminsearch(fx2, [0 0 0]);
p1(i,4) = sum(z1(:));
p2(i,4) = sum(z2(:));
end

p1s = p1;
p1s(:,1) = max(-1, min(0.5, p1s(:,1)));
p1s(:,2) = max(-1, min(0.5, p1s(:,2)));
mu{1} = mean(p1s);
se{1} = std(p1s)./sqrt(length(p1s));

p2s = p2;
p2s(:,1) = max(-1, min(0.5, p2s(:,1)));
p2s(:,2) = max(-1, min(0.5, p2s(:,2)));
mu{2} = mean(p2s);
se{2} = std(p2s)./sqrt(length(p2s));

%%

logistic = @(p)(log10(p./(1-p)));

for i = [1:size(r10x,3)]
    qc(i) = r10x(1,6,i) + r10x(2,7,i) + r10x(4,9,i) + r10x(5,10,i);
    qi(i) = r10x(6,1,i) + r10x(7,2,i) + r10x(9,4,i) + r10x(10,5,i);
end

smooth = 0.5;
[mean((qc+smooth)./(qc+qi+2.*smooth)) std((qc+smooth)./(qc+qi+2.*smooth))./sqrt(length(qc))]
[mean(logistic((qc+smooth)./(qc+qi+2.*smooth))) std(logistic((qc+smooth)./(qc+qi+2.*smooth)))./sqrt(length(qc))]
%%

logistic = @(p)(log10(p./(1-p)));

for i = [1:size(r10x,3)]
    z1 = r10x(1:5,6:10,i);
    z2 = r10x(6:10,1:5,i);
    a = z1;
    a(:,3) = [];
    a(3,:) = [];
    qc(i) = sum(a(:));
    a = z2;
    a(:,3) = [];
    a(3,:) = [];
    qi(i) = sum(a(:));
end

smooth = 0.5;
[mean((qc+smooth)./(qc+qi+2.*smooth)) std((qc+smooth)./(qc+qi+2.*smooth))./sqrt(length(qc))]
[mean(logistic((qc+smooth)./(qc+qi+2.*smooth))) std(logistic((qc+smooth)./(qc+qi+2.*smooth)))./sqrt(length(qc))]

%%

for i = [1:size(r10x,3)]
    qc(i) = sum(r10x(3,5+3,i));
    qi(i) = sum(r10x(3+5,3,i));
end
smooth = 0.5;
[mean((qc+smooth)./(qc+qi+2.*smooth)) std((qc+smooth)./(qc+qi+2.*smooth))./sqrt(length(qc))]
[mean(logistic((qc+smooth)./(qc+qi+2.*smooth))) std(logistic((qc+smooth)./(qc+qi+2.*smooth)))./sqrt(length(qc))]


%%
for i = [1:size(r10x,3)]
    z1 = r10x(1:5,6:10,i);
    z2 = r10x(6:10,1:5,i);
    qc(i) = sum(z1(3,[1:2 4:5]))+sum(z1([1:2 4:5],3));
    qi(i) = sum(z2(3,[1:2 4:5]))+sum(z2([1:2 4:5],3));
end
smooth = 0.5;
[mean((qc+smooth)./(qc+qi+2.*smooth)) std((qc+smooth)./(qc+qi+2.*smooth))./sqrt(length(qc))]
[mean(logistic((qc+smooth)./(qc+qi+2.*smooth))) std(logistic((qc+smooth)./(qc+qi+2.*smooth)))./sqrt(length(qc))]
