scale2 = 0.15;
pos = get(gca, 'Position');
pos(2) = pos(2)+scale2*pos(4);
pos(4) = (1-scale2)*pos(4);
set(gca, 'Position', pos)