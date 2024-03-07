clear
close all

T = readtable('mae_loc_width.csv');

locationSpace = linspace(-45, 45, 200);
widthSpace = linspace(0, 90, 200);
winWidth = 3;
map = zeros(length(locationSpace), length(widthSpace));

for iLocation = 1:length(locationSpace)
    locationStart = locationSpace(iLocation) - winWidth / 2;
    locationEnd = locationSpace(iLocation) + winWidth / 2;

    for iWidth = 1:length(widthSpace)
        widthStart = widthSpace(iWidth) - winWidth / 2;
        widthEnd = widthSpace(iWidth) + winWidth / 2;

        errors = T(T.location >= locationStart & T.location < locationEnd ...
            & T.width >= widthStart & T.width < widthEnd, :).error;
        mae = mean(abs(errors));
        map(iLocation, iWidth) = mae;
    end
end
f = figure;
f.Position(3:4) = [800 400];

imagesc(locationSpace, widthSpace, map')
set(gca,'YDir','normal')
set(gca, 'YTick', 0:15:90, 'YTickLabel', 0:15:90);
set(gca, 'XTick', -45:15:45, 'XTickLabel', -45:15:45);
xtickformat('%g°')
ytickformat('%g°')
ylabel('Ensemble Width \fontsize{14}\omega')
xlabel('Ensemble Location \fontsize{14}\phi')
set(gca,'TickDir', 'both')
grid on
% set(gca, 'LineWidth', 1)
set(gca, 'GridAlpha', 1)
colormap turbo
ylim([0 90])
xlim([-45 45])

c = colorbar;
c.Label.String = 'Mean Absolute Error';
c.Ruler.TickLabelFormat = '%g°';

% draw an ellipse
hold on
x0 = 0; % x-coordinate of the center
y0 = 45; % y-coordinate of the center
a = 30;  % semi-major axis length
b = 20;  % semi-minor axis length
theta = 0; % rotation angle in radians

t = linspace(0, 2*pi, 100); % Parameter t, from 0 to 2*pi
x = x0 + a*cos(t)*cos(theta) - b*sin(t)*sin(theta);
y = y0 + a*cos(t)*sin(theta) + b*sin(t)*cos(theta);

% Plotting the ellipse
plot(x, y, 'w', LineWidth=1.5)

exportgraphics(f, 'imgs/mae_loc_width.png', ...
    Resolution=300)

% set(gca, 'YTick', 0:10:100, 'XTickLabel', 0:10:90);
% set(gca, 'XTick', 1:10:20, 'XTickLabel', -90:10:90);

impixelinfo
