meanIC = mean(input.Features.IC, 1);
stdIC = std(input.Features.IC);

x = 1:64;
xconf = [x x(end:-1:1)] ;         
yconf = [meanIC + stdIC, meanIC(end:-1:1) - stdIC(end:-1:1)];

p = fill(xconf, yconf, 'red');
hold off
p.FaceColor = [1 0.8 0.8];      
p.EdgeColor = 'none';      

hold on
area(meanIC, ...
    'FaceAlpha', 0.3, ...
    'EdgeColor', '#0072BD', ...
    'FaceColor', '#0072BD')
hold off

set(gca,'XDir','reverse')
xlabel('Frequency [kHz]')
ylabel('Mean IC')
set(gca,'YAxisLocation','right')
grid
% camroll(-90)
xlim([cfHzX(1) cfHzX(end)])
xticks(cfHzX)
xticklabels(cfHz)

hold on
hp = plot([cfHzX(1) cfHzX(end)], [0 0]);
hp.Color = "#D95319";
hold off

ylim([0 1])
