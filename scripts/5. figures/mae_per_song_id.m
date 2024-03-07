close all

T = readtable('mae_per_song.csv');
T.song = transformSongNames(T.song);
T_sorted = sortrows(T, 'mae');
songsPerPlot = 64;
totalPlots = ceil(height(T_sorted) / songsPerPlot);

f = figure;
f.Position(3:4) = [1400 1200];

for i = 1:totalPlots
    startIdx = (i - 1) * songsPerPlot + 1;
    endIdx = min(i * songsPerPlot, height(T_sorted));
    subplot(totalPlots, 1, i);
    T_subset = T_sorted(startIdx:endIdx, :);

    bar(T_subset.mae)
    xlabel('Music Recording')
    ylabel('Mean Absolute Error')
    ytickformat('%g°')
    grid on
    xticks(1:length(T_subset.song))
    yticks(1:2:15)
    xticklabels(T_subset.song)
    ylim([0 15])
end

exportgraphics(f, 'imgs/mae_per_song_id.png', ...
    Resolution=300)

function transformedNames = transformSongNames(songNames)
    transformedNames = cell(size(songNames));
    for i = 1:length(songNames)
        name = songNames{i};
        transformedName = regexprep(name, '(?<!^)([A-Z])', ' $1');
        transformedNames{i} = transformedName;
    end
end

