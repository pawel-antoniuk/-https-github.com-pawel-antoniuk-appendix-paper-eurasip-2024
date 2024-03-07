close all

T = readtable('mae_error_distribution.csv');

f = figure;
f.Position(3:4) = [500 400];

plot(T.val, T.err / sum(T.err))
xlabel('Error of Prediction')
ylabel('Frequency')
xtickformat('%g°')
xlim([-45 45])
xticks(linspace(-90, 90, 13))
% xticklabels(linspace(0, 90, 10))
grid on
% legend('Moving MAE', Location='southeast')

exportgraphics(f, 'imgs/mae_error_distribution.png', ...
    Resolution=300)
