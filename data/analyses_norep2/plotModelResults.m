function [pWhole pPart pColor sdSamp ...
    pWholeMu pPartMu pColorMu sdSampMu ...
    pWholeSE pPartSE pColorSE sdSampSE]=plotModelResults(params,stimtype)

%% Get params

pWhole=(params(:,1,:));
pPart=(params(:,2,:));
pColor=(params(:,3,:));
sdSamp=(params(:,4,:));

pWholeMu=nanmean(params(:,1,:),3);
pPartMu=nanmean(params(:,2,:),3);
pColorMu=nanmean(params(:,3,:),3);
sdSampMu=nanmean(params(:,4,:),3);

pWholeSE=nanstd(params(:,1,:),[],3)./sqrt(sum(~isnan(params(:,1,:)),3));
pPartSE=nanstd(params(:,2,:),[],3)./sqrt(sum(~isnan(params(:,2,:)),3));
pColorSE=nanstd(params(:,3,:),[],3)./sqrt(sum(~isnan(params(:,3,:)),3));
sdSampSE=nanstd(params(:,4,:),[],3)./sqrt(sum(~isnan(params(:,4,:)),3));

%% Plot
figure('Position', [100, 100, 895, 895]);set(gcf,'color','w');
hold on
errorbar(sdSampMu,pWholeMu,pWholeSE,'k.')
herrorbar(sdSampMu,pWholeMu,sdSampSE,'k.')
hXLabel=xlabel('SD');hYLabel=ylabel('Pr(Whole)');
disp('SD vs. Whole')
[a b]=corr(pPartMu,pWholeMu);
disp(strcat('r: ',num2str(a),' p: ',num2str(b)))
set( gca                       , ...
    'FontName'   , 'Helvetica','FontSize',40 );

set([hXLabel hYLabel], ...
    'FontName'   , 'Helvetica','Color',[.3 .3 .3] );
set([hXLabel hYLabel]  , ...
    'FontSize'   , 60          );
set([ hXLabel, hYLabel], ...
    'FontName'   , 'Helvetica','Color',[.3 .3 .3] );
set([hXLabel, hYLabel]  , ...
    'FontSize'   , 60          );
set(gca,'box','off')

set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'LineWidth'   , 1         );

scale = 0.15;
pos = get(gca, 'Position');
pos(2) = pos(2)+scale*pos(4);
pos(4) = (1-scale)*pos(4);
set(gca, 'Position', pos)
hold off

figure('Position', [100, 100, 895, 895]);set(gcf,'color','w');
hold on
errorbar(pPartMu,pWholeMu,pWholeSE,'k.')
herrorbar(pPartMu,pWholeMu,pPartSE,'k.')
hXLabel=xlabel('Pr(Part)');hYLabel=ylabel('Pr(Whole)');
disp('Part vs. Whole')
[a b]=corr(pPartMu,pWholeMu);
disp(strcat('r: ',num2str(a),' p: ',num2str(b)))
set( gca                       , ...
    'FontName'   , 'Helvetica','FontSize',40 );

set([hXLabel hYLabel], ...
    'FontName'   , 'Helvetica','Color',[.3 .3 .3] );
set([hXLabel hYLabel]  , ...
    'FontSize'   , 60          );
set([ hXLabel, hYLabel], ...
    'FontName'   , 'Helvetica','Color',[.3 .3 .3] );
set([hXLabel, hYLabel]  , ...
    'FontSize'   , 60          );
set(gca,'box','off')

set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'LineWidth'   , 1         );

scale = 0.15;
pos = get(gca, 'Position');
pos(2) = pos(2)+scale*pos(4);
pos(4) = (1-scale)*pos(4);
set(gca, 'Position', pos)
hold off

figure('Position', [100, 100, 895, 895]);set(gcf,'color','w');
hold on
errorbar(pPartMu,pColorMu,pColorSE,'k.')
herrorbar(pPartMu,pColorMu,pPartSE,'k.')
disp('Part vs. Color')
[a b]=corr(pPartMu,pColorMu);
disp(strcat('r: ',num2str(a),' p: ',num2str(b)))
hXLabel=xlabel('Pr(Part)');hYLabel=ylabel('Pr(Color)');
set( gca                       , ...
    'FontName'   , 'Helvetica','FontSize',40 );

set([hXLabel hYLabel], ...
    'FontName'   , 'Helvetica','Color',[.3 .3 .3] );
set([hXLabel hYLabel]  , ...
    'FontSize'   , 60          );
set([ hXLabel, hYLabel], ...
    'FontName'   , 'Helvetica','Color',[.3 .3 .3] );
set([hXLabel, hYLabel]  , ...
    'FontSize'   , 60          );
set(gca,'box','off')

set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'LineWidth'   , 1         );

scale = 0.15;
pos = get(gca, 'Position');
pos(2) = pos(2)+scale*pos(4);
pos(4) = (1-scale)*pos(4);
set(gca, 'Position', pos)
hold off

figure('Position', [100, 100, 895, 895]);set(gcf,'color','w');
hold on
errorbar(pColorMu,pWholeMu,pWholeSE,'k.')
herrorbar(pColorMu,pWholeMu,pColorSE,'k.')
disp('Color vs. Whole')
[a b]=corr(pColorMu,pWholeMu);
disp(strcat('r: ',num2str(a),' p: ',num2str(b)))

hXLabel=xlabel('Pr(Color)');hYLabel=ylabel('Pr(Whole)');
set( gca                       , ...
    'FontName'   , 'Helvetica','FontSize',40 );

set([hXLabel hYLabel], ...
    'FontName'   , 'Helvetica','Color',[.3 .3 .3] );
set([hXLabel hYLabel]  , ...
    'FontSize'   , 60          );
set([ hXLabel, hYLabel], ...
    'FontName'   , 'Helvetica','Color',[.3 .3 .3] );
set([hXLabel, hYLabel]  , ...
    'FontSize'   , 60          );
set(gca,'box','off')

set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'LineWidth'   , 1         );

scale = 0.15;
pos = get(gca, 'Position');
pos(2) = pos(2)+scale*pos(4);
pos(4) = (1-scale)*pos(4);
set(gca, 'Position', pos)
hold off