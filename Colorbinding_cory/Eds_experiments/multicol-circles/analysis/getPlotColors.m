function colored = getPlotColors(ii)

red = [0.7 0 0]; 
green = [0 .6 0]; 
blue = [0 0 .9]; 
orange=[.8 .5 0]; 
black = [0 0 0]; 
g1 = [.25 .25 .25]; 
g2 = [.5 .5 .5]; 
g3 = [.75 .75 .75];
purple = [.4 0 .8]; 
yellow = [0.5 0.5 0]; 
cyan=[0.3 .6 1];

colors{1} = { 'Color', red, 'LineWidth', 2, 'MarkerSize', 6, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [0 0 0];
           'Color', green, 'LineWidth', 2, 'MarkerSize', 6, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [0 0 0];
           'Color', blue, 'LineWidth', 2, 'MarkerSize', 6, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [0 0 0];
           'Color', orange, 'LineWidth', 2, 'MarkerSize', 6, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [0 0 0];
           'Color', yellow, 'LineWidth', 2, 'MarkerSize', 6, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [0 0 0];
           'Color', cyan, 'LineWidth', 2, 'MarkerSize', 6, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [0 0 0]};
           
colors{2} = { 'Color', red, 'LineWidth', 3, 'MarkerSize', 8, 'MarkerFaceColor', red, 'MarkerEdgeColor', red;
           'Color', green, 'LineWidth', 3, 'MarkerSize', 8, 'MarkerFaceColor', green, 'MarkerEdgeColor', green;
           'Color', blue, 'LineWidth', 3, 'MarkerSize', 8, 'MarkerFaceColor', blue, 'MarkerEdgeColor', blue;
           'Color', orange, 'LineWidth', 3, 'MarkerSize', 8, 'MarkerFaceColor', orange, 'MarkerEdgeColor', orange;
           'Color', yellow, 'LineWidth', 3, 'MarkerSize', 8, 'MarkerFaceColor', yellow, 'MarkerEdgeColor', yellow;
           'Color', cyan, 'LineWidth', 3, 'MarkerSize', 8, 'MarkerFaceColor', cyan, 'MarkerEdgeColor', cyan};
           
       colored = colors{ii};