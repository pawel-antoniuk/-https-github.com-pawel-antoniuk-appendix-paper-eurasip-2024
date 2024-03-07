close all

T = readtable('mae_moving.csv');

f = figure;
f.Position(3:4) = [500 400];

plot(T.val, T.mae)
xlabel('Actual Ensemble Width \fontsize{14}\omega')
ylabel('Mean Absolute Error')
xtickformat('%g°')
ytickformat('%g°')
xlim([0 90])
xticks(linspace(0, 90, 10))
yticks(linspace(0, 16, 9))
% yticklabels(linspace(0, 15, 13))
grid on
legend('Moving MAE', Location='southeast')

exportgraphics(f, 'imgs/mae_movng.png', ...
    Resolution=300)
