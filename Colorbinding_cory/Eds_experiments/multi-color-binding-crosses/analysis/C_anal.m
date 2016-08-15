clear all
close all

ss = [1:9];

SCs = [0.0001 0.05 0.1];
Sdxs = [0.01 0.05 0.1 0.15 0.2 0.25 0.3];

% subj	trial	Sx	Sdx	I	Sc	Nt	No	Adjust	Setting	TrialDur

Smu = zeros(length(Sdxs), length(SCs), length(ss));
Ssd = zeros(length(Sdxs), length(SCs), length(ss));

tthresh = [5 120];

format = '%n\t%n\t%n\t%n\t%n\t%n\t%n\t%n\t%s\t%n\t%n';

% how to compute average setting?
fx = @(x)(x);%(log10(x));
fxi = @(x)(x);%(10.^(x));


for s = [1:length(ss)]
    filename = sprintf('../data/C_%d.csv', ss(s));
    
    [X{1:11}] = textread(filename, format, 'headerlines', 3);
    
    for i = [1:length(SCs)]
        for x = [1:length(Sdxs)]
            curidx = find( (X{11}>tthresh(1)) & ... % check that subjects spent sufficient time making this setting.
                           (X{11}<tthresh(2)) & ... % but not stupidly long
                           (X{6}==SCs(i)) & ... % get current I
                           (X{4}==Sdxs(x))); % and current SDX
            Smu(x,i,s) = nanmean(fx(X{10}(curidx)));
            Ssd(x,i,s) = nanstd(fx(X{10}(curidx)));
        end
    end
end

%% compute mean across subjects
close all

subMU = nanmean(Smu, 3);
subSE = nanstd(Smu, 0, 3)./sqrt(length(ss));

colors = getPlotColors(2);

figure();
for i = [1 3]
    H{i} = ploterr(subMU(:,i)', Sdxs', subSE(:,i)', [], 'ko-', 'logxy');
    hold on;
    for h = [1:length(H{i})]
        set(H{i}(h),  colors{i,:});
%         set(H{i}(2),  colors{i,:});
    end
end
xlabel('\sigma_x');
ylabel('\sigma_{dx}');
axis tight
prettyFont();


% 
% 
%     SX_CI{1}(:,i) = fxi([Sdx_L10_mu(:,i,:)-Sdx_L10_sd(:,i,:)./sqrt(length(Ss))]);
%     SX_CI{2}(:,i) = fxi([Sdx_L10_mu(:,i,:)+Sdx_L10_sd(:,i,:)./sqrt(length(Ss))]);
%     SX_CI{3}(:,i) = fxi([Sdx_L10_mu(:,i,:)]);
%     
%     SDX_CI{1}(:,i) = fxi([Sx_L10_mu(:,i,:)-Sx_L10_sd(:,i,:)./sqrt(length(Ss))]);
%     SDX_CI{2}(:,i) = fxi([Sx_L10_mu(:,i,:)+Sx_L10_sd(:,i,:)./sqrt(length(Ss))]);
%     SDX_CI{3}(:,i) = fxi([Sx_L10_mu(:,i,:)]);
% 
