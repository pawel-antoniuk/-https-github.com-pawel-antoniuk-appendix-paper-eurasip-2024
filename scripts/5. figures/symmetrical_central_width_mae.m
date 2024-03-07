close all

T = readtable('../post-analysis/stats_symmetrical_central.csv');

f = figure;
f.Position(3:4) = [500 400];

plot(T.Width, T.Mean_ILD)
hold on
plot(T.Width, T.Mean_ITD)
plot(T.Width, T.Mean_IC)
hold off

xlabel('Actual Ensemble Width \fontsize{14}\omega')
ylabel('Mean Absolute Error')
xtickformat('%g°')
ytickformat('%g°')
xlim([0 90])
xticks(linspace(0, 90, 10))
yticks(linspace(0, 18, 10))
% xticklabels(linspace(0, 90, 10))
grid on
legend('ILD', 'ITD', 'IC', Location='southeast')

exportgraphics(f, 'imgs/stats_symmetrical_central.png', ...
    Resolution=300)
