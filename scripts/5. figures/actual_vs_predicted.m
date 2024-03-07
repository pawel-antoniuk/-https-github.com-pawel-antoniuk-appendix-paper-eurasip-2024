T = readtable('actual_vs_predicted.csv');

f = figure;
f.Position(3:4) = [500 400];

scatter(T.actual, T.predicted, 20, 'filled', ...
    MarkerFaceAlpha=0.1, ...
    MarkerEdgeAlpha=0.1)
xlim([0, 90])
ylim([0, 90])
xlabel('Actual Ensemble Width \fontsize{14}\omega')
ylabel('Predicted Ensemble Width \fontsize{14}\omega''')

xtickformat('%g°')
ytickformat('%g°')

hold on

plot([0, 180], [0, 180], LineWidth=2)
% 
% p = polyfit(T.predicted, T.actual, 5);
% px = linspace(0, 90);
% py = polyval(p, px);
% plot(px, py)

hold off

legend('Samples', 'One-to-one line', ...
    Location='southeast')
grid on

exportgraphics(f, 'imgs/actual_vs_predicted.png', ...
    Resolution=300)