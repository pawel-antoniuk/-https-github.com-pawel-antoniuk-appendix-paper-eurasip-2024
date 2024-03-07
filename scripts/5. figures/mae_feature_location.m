close all
clear

featuresOrder = {'IC', 'ITD', 'ILD', ...
    'ITD+IC', 'ILD+IC', 'ILD+ITD', 'ILD+ITD+IC'};

T = readtable('../post-analysis/stats-feature-location.csv');



[groupIds, groupNames] = findgroups(T.features);
maes = splitapply(@(x) {x}, T.mae, groupIds);
stds = splitapply(@(x) {x}, T.std, groupIds);
maes = reshape(vertcat(maes{:}), 2, []).';
stds = reshape(vertcat(stds{:}), 2, []).';

nameStrings = upper(strrep(groupNames, '_', '+'));
names = categorical(nameStrings);
names = reordercats(names, featuresOrder');

f = figure;
f.Position(3:4) = [500 400];

b=bar(names, maes);

[ngroups,nbars] = size(maes);
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end


hold on
er = errorbar(x', maes, stds, 'k', linestyle='None');
hold off

% maetooltips = repmat('°', length(maes), 1);
% maetooltips = [num2str(maes'), maetooltips];
% 
% stdtooltips = repmat('±', length(stds), 1);
% stdtooltips = [stdtooltips, num2str(stds')];
% stdtooltips = [stdtooltips, repmat('°', length(stds), 1)];

% tooltips = [maetooltips, repmat(newline, length(maes), 1), stdtooltips];

% text(1:length(maes), maes + stds, tooltips, ...
%     'vert','bottom', ...
%     'horiz','center');

ylim([6.2, 8.5])
xlabel('Features')
ylabel('Mean Absolute Error')
ytickformat('%g°')

ax = gca;
ax.XGrid = 'off';
ax.YGrid = 'on';

lgd = legend('Center','Off-Center');
t = title(lgd,'Ensamble Location')

exportgraphics(f, 'imgs/mae_feature_location.png', ...
    Resolution=300)



function y = something(x)
disp(x)
y = {x};
end
