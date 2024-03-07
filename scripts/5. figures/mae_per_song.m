close all

selSongs = {'Dionizetti', 'Verdi', 'Puccini', 'Siren', ...
    'Mahler', 'Nostalgic', 'StillFlyin', 'APlaceForUs', ...
    'Machines On Treadmills'};
selSongNacmes = {'Donizetti', 'Verdi', 'Puccini', 'Siren', ...
    'Mahler', 'Nostalgic', 'StillFlyin', 'APlaceForUs', ...
    'Machines On Treadmills'};
typos = {'Dionizetti'};
corrections = {'Donizetti'};

T = readtable('mae_per_song.csv');

f = figure;
f.Position(3:4) = [500 400];

scatter(T.count, T.mae, 50, 'filled', MarkerFaceAlpha=0.25)

hold on
% errorbar(T.count, T.mae, T.std, 'LineStyle','none');
Tsel = T(ismember(T.song, selSongs), :);

% Replace typos
for i = 1:length(typos)
    Tsel.song = cellfun(@(s) replace(s, typos{i}, corrections{i}), Tsel.song, 'UniformOutput', false);
end

text(Tsel.count+2, Tsel.mae, Tsel.song)

% T_NoOutliers = T(~ismember(T.song, {'Dionizetti', 'Nostalgic'}), :);
T_NoOutliers = T;

% Y = a*x^b+c
ftype = fittype('exp(a*x+b)+c');
[curve, goodness] = fit(T_NoOutliers.count, T_NoOutliers.mae, ftype, StartPoint=[-1 10 5]);
x_fit = linspace(-1000, 1000, 1000);
y_fit = feval(curve, x_fit);
plot(x_fit, y_fit)

[R, ~] = corrcoef(T_NoOutliers.mae, T_NoOutliers.count);
pearson_r = R(1, 2);
disp(['Pearson r: ', num2str(pearson_r)]);

disp(['R2: ', num2str(goodness.rsquare)])

% p = polyfit(T.count, T.mae, 2);
% px = linspace(0, 90);
% py = polyval(p, px);
% plot(px, py)

hold off

xlim([0, 80])
ylim([4, 13])
xlabel('Number of Sources')
ylabel('Mean Absolute Error')
ytickformat('%g°')
grid on
% legend('')

exportgraphics(f, 'imgs/mae_per_song.png', ...
    Resolution=300)
