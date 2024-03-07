close all; clear;
tlo = tiledlayout(2, 1);

nexttile
ax = gca;
ax.Visible = 'off';
ax = polaraxes(tlo);
ax.Layout.Tile = 1;
theta = linspace(0, 2*pi, 100);
rho = abs(sin(2*theta)) .* cos(2*theta);
p = polarplot(theta, rho);
hold on;

pax = ax;
paxPos = pax.Position;
ax2 = axes(tlo);

[img, ~, alpha] = imread('../figures/head.png');

x = 0.25;
y = 0.25;
width = 0.5;
height = 0.5;
image(ax2, 'CData', img, ...
    'XData', [x, x + width], ...
    'YData', [y, y + height], ...
    AlphaData=alpha);

axis(ax2, 'off');
xlim(ax2, [0 1]);
ylim(ax2, [0 1]);
pbaspect([1 1 1])
uistack(ax2, 'top');
hold off;

nexttile
plot(linspace(1,2,10))

