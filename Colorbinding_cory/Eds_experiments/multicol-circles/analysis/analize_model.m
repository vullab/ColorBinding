clear all
close all



test14 = 2;

fpath = '../data/';
files = dir(sprintf('%s*_1.txt',fpath));

nsubs = 0;

for fi = [1:length(files)]
    curfile = fopen(sprintf('%s%s', fpath, files(fi).name));
    discard = fgetl(curfile);
    
    q = textscan(curfile,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f ', 'delimiter', ',');
    if((q{14}(1) == test14) & (length(q{14})>20))
        nsubs = nsubs+1;
        z{nsubs} = q;
    end
end


% plan
% h place
% h h/v
% v place
% v h/v


for s = [1:nsubs]
    
    counts{s} = zeros(5,2,5,2);
    hpos = z{s}{6};
    vpos = z{s}{7};
    h_hv = z{s}{9};
    v_hv = z{s}{3};
    for i = [1:length(hpos)]
        counts{s}(hpos(i)+3, h_hv(i), vpos(i)+3, v_hv(i)) = counts{s}(hpos(i)+3, h_hv(i), vpos(i)+3, v_hv(i)) + 1;
    end
end

%% some models
% 1. iid draws from scale*id pref

%% null model
ll = @(X, P)(sum(X(:).*log10(P(:))));

for s = [1:nsubs]
    params{1}(s) = 0;
    PA = ones(5,2,5,2).*1./100;
    LL{1}(s) = ll(counts{s}, PA);
    LLpN{1}(s) = LL{1}(s)./sum(counts{s}(:));
end

for s = [1:nsubs]
    fminfx = @(params)(-ll(counts{s}, mIID(params(1), params(2))));
    params{2}(:,s) = fminsearch(fminfx, [0 0.5]);
    LL{2}(s) = ll(counts{s}, mIID(params{2}(1,s), params{2}(2,s)));
    LLpN{2}(s) = LL{2}(s)./sum(counts{s}(:));
end

