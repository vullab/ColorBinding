function plotFrequencyLocation(correct)

figure('Position', [100, 100, 1049, 895]);set(gcf,'color','w');
hold on
errorbar(-2:2,mean(correct(1,:,:),3),std(correct(1,:,:),[],3)./sqrt(4),'b','LineWidth',4) % v for v
errorbar(-2:2,mean(correct(2,:,:),3),std(correct(2,:,:),[],3)./sqrt(4),'r','LineWidth',4) % h for v
xlim([-2.5 2.5])
[legh,objh,outh,outm] =legend('Correct Part-Type','Incorrect Part-Type','Location','NorthWest');
M = findobj(legh,'type','line');
m=findobj(legh);

hx1=text(-1.5,-.095,'Counterclockwise','HorizontalAlignment','center');
hx2=text(1.5,-.095,'Clockwise','HorizontalAlignment','center');
hXLabel=text(0,-.15,'Relative position to target','HorizontalAlignment','center');

set([hx1 hx2], ...
    'FontName'   , 'Helvetica','Color',[.3 .3 .3] );
set([hx1 hx2]  , ...
    'FontSize'   , 40          );

set([legh],'FontName'   , 'Helvetica','TextColor',[.3 .3 .3] )

set([legh],'FontName'   , 'Helvetica','TextColor',[.3 .3 .3] )
%hXLabel=xlabel('Relative position to target');
hYLabel=ylabel('Proportion of Responses');
set( gca                       , ...
    'FontName'   , 'Helvetica','FontSize',32 );

set([hXLabel hYLabel], ...
    'FontName'   , 'Helvetica','Color',[.3 .3 .3] );
set([hXLabel hYLabel]  , ...
    'FontSize'   , 60          );
set([ hXLabel, ], ...
    'FontName'   , 'Helvetica','Color',[.3 .3 .3] );
set([hXLabel]  , ...
    'FontSize'   , 60          );

set([ hYLabel]  , ...
    'FontSize'   , 50          );
set([ hYLabel], ...
    'FontName'   , 'Helvetica','Color',[.3 .3 .3] );
set([hXLabel, hYLabel]  , ...
    'FontSize'   , 50          );

set(gca,'box','off')
set(m(end-(3):end),'linewidth',4)
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
