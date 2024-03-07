T = readtable('mae_pred_distribution.csv');

f = figure;
f.Position(3:4) = [500 400];

plot(T.vals, T.mae / sum(T.mae))
xlim([0 90])
xlabel('Predicted Ensemble Width')
ylabel('Frequency')
xtickformat('%g°')
grid on


exportgraphics(f, 'imgs/mae_pred_distribution.png', ...
    Resolution=300)
