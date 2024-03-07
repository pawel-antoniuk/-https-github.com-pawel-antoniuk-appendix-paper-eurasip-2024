close all;
T = readtable('../post-analysis/mae_per_skewness_and_song.csv');

selSongs = {'Nostalgic', 'Machines On Treadmills', 'Mahler', 'StillFlyin', ...
    'SchoolboyFascination', 'Ubiquitous', 'RunRunRun', 'Gravediggers', ...
    'TimesUp', 'Song For John', 'CUNextTime', 'Copper', 'APlaceForUs', ...
    'RabbitHole'};

f = figure;
f.Position(3:4) = [600 400];

scatter(T.skewness, T.mae, 'filled')

T_NoOutliers = T(~ismember(T.SongNames, {'Dionizetti', 'Nostalgic'}), :);

hold on
ftype = fittype('poly1');
[curve, goodness] = fit(T_NoOutliers.skewness, T_NoOutliers.mae, ftype, normalize='off');
x_fit = linspace(0, 15, 100);
y_fit = feval(curve, x_fit);
plot(x_fit, y_fit)
disp(['R2: ', num2str(goodness.rsquare)]);

[R, ~] = corrcoef(T_NoOutliers.skewness, T_NoOutliers.mae);
pearson_r = R(1, 2);
disp(['Pearson r: ', num2str(pearson_r)]);

xlabel('Mean Spectral Skewness')
ylabel('Mean Absolute Error')
ytickformat('%g°')
grid on
Tsel = T(ismember(T.SongNames, selSongs), :);
text(Tsel.skewness + 0.05, Tsel.mae, Tsel.SongNames)
xlim([2 4.8])

% Enable data cursor mode
dcm_obj = datacursormode(f);
set(dcm_obj,'UpdateFcn',{@myupdatefcn, T})

exportgraphics(f, 'imgs/plot_mae_per_skewness_and_song.png', ...
    Resolution=300)

function txt = myupdatefcn(~,event_obj,T)
% Get index of the selected point
idx = event_obj.DataIndex;

% Custom text for each point
songName = T.SongNames{idx};
txt = {['Skewness: ', num2str(T.skewness(idx))], ...
    ['MAE: ', num2str(T.mae(idx))], ...
    ['Song: ', songName]};
end
