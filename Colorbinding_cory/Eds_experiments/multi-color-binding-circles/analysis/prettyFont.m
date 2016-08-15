function prettyFont()
set(gca, 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold')
h_l{1} = get(gca,'XLabel');
h_l{2} = get(gca,'YLabel');
h_l{3} = get(gca,'ZLabel');
h_l{4} = get(gca,'title');
for i = [1:4]
    set(h_l{i},'FontName', 'Arial', 'FontSize', 16, 'FontWeight', 'bold');
end