clear all
close all

load_data;

logistic = @(x)(1./(1+exp(-x)));
logit = @(p)(log10(p./(1-p)));


%% plot n-way histograms

for T = [1:2]
    figure();
    imagesc(log10(p10x{T}), [-3 -0.5]), colormap gray;
    title(sprintf('%s', names{T}));
    hold on;
    plot([5.5 5.5], [0.5 10.5], 'm-', 'LineWidth', 2);
    plot([0.5 10.5], [5.5 5.5], 'm-', 'LineWidth', 2);
    set(gca, 'Xtick', [], 'Ytick', []);
end

%%

figure();
for T = [1:2]
    % Okay so this take the model, assigns a probability to each h-v sample
    % and then multiplies those probabilities by the frequency count (r10x)
    % and minimizes that product
    quickie = @(params)(fullmodel(params(1), params(2), params(3), params(4), params(5)));
    fx = @(params)(-sum(sum(log10(quickie(params)).*r10x{T})));
    PAR{T} = fminsearch(fx, [0 0 0 0 0]);

    subplot(2,3,(T-1)*3+1)
    imagesc(log10(p10x{T}), [-3 -0.5]), colormap gray;
    title(sprintf('%s real', names{T}));
    hold on;
    plot([5.5 5.5], [0.5 10.5], 'm-', 'LineWidth', 2);
    plot([0.5 10.5], [5.5 5.5], 'm-', 'LineWidth', 2);
    set(gca, 'Xtick', [], 'Ytick', []);
    
    
    subplot(2,3,(T-1)*3+2)
    imagesc(log10(quickie(PAR{T})), [-3 -0.5]), colormap gray;
    title(sprintf('%s model', names{T}));
    hold on;
    plot([5.5 5.5], [0.5 10.5], 'm-', 'LineWidth', 2);
    plot([0.5 10.5], [5.5 5.5], 'm-', 'LineWidth', 2);
    set(gca, 'Xtick', [], 'Ytick', []);
    
    subplot(2,3,(T-1)*3+3)
    imagesc((quickie(PAR{T}))-(p10x{T}));
    title(sprintf('%s error', names{T}));
    hold on;
    plot([5.5 5.5], [0.5 10.5], 'm-', 'LineWidth', 2);
    plot([0.5 10.5], [5.5 5.5], 'm-', 'LineWidth', 2);
    set(gca, 'Xtick', [], 'Ytick', []);
    
    fprintf('\n%s LL = %2.2f (min: %2.2f, max: %2.2f)\n', ...
        names{T}, ...
        -fx(PAR{T})./sum(r10x{T}(:)), ...
        sum(sum(log10(ones(10)./100).*r10x{T}))./sum(r10x{T}(:)), ...
        sum(sum(log10(p10x{T}).*r10x{T}))./sum(r10x{T}(:)));
end


%% fit data to off-diag quadrants

% for i = [1:size(r10x, 3)]
%     z2 = r10x(6:10, 1:5,i);
%     z1 = r10x(1:5, 6:10,i);
%     fx1 = @(params)(-sum(sum(log10(modelme(params(1), params(2), params(3))).*z1)));
%     fx2 = @(params)(-sum(sum(log10(modelme(params(1), params(2), params(3))).*z2)));
%     p1(i,1:3) = fminsearch(fx1, [0 0 0]);
%     p2(i,1:3) = fminsearch(fx2, [0 0 0]);
%     p1(i,4) = sum(z1(:));
%     p2(i,4) = sum(z2(:));
% end
% 
% p1s = p1;
% p1s(:,1) = max(-1, min(0.5, p1s(:,1)));
% p1s(:,2) = max(-1, min(0.5, p1s(:,2)));
% mu{1} = mean(p1s);
% mu{1} = std(p1s)./sqrt(length(p1s));
% 
% p2s = p2;
% p2s(:,1) = max(-1, min(0.5, p2s(:,1)));
% p2s(:,2) = max(-1, min(0.5, p2s(:,2)));
% mu{2} = mean(p2s);
% se{2} = std(p2s)./sqrt(length(p2s));

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
    qcx(i) = r10x(1,6,i) + r10x(2,7,i) + r10x(4,9,i) + r10x(5,10,i);
    qci(i) = r10x(5,6,i) + r10x(4,7,i) + r10x(2,9,i) + r10x(1,10,i);
    qix(i) = r10x(6,1,i) + r10x(7,2,i) + r10x(9,4,i) + r10x(10,5,i);
    qii(i) = r10x(6,5,i) + r10x(7,4,i) + r10x(9,2,i) + r10x(10,1,i);
end

[mean((qcx+smooth)./(qcx+qci+2.*smooth)) std((qcx+smooth)./(qcx+qci+2.*smooth))./sqrt(length(qcx))]
[mean(logistic((qcx+smooth)./(qcx+qci+2.*smooth))) std(logistic((qcx+smooth)./(qcx+qci+2.*smooth)))./sqrt(length(qci))]
[mean((qix+smooth)./(qix+qii+2.*smooth)) std((qix+smooth)./(qix+qii+2.*smooth))./sqrt(length(qix))]
[mean(logistic((qix+smooth)./(qix+qii+2.*smooth))) std(logistic((qix+smooth)./(qix+qii+2.*smooth)))./sqrt(length(qii))]

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

%%

