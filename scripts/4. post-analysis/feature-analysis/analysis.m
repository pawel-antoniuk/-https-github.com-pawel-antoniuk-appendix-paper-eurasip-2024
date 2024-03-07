clear; clc; close all
%
% % startup
% parpool(16)
addpath('TwoEars-1.5')
startTwoEars
%% Spatialize

% Params
params.HRTFBaseDir = 'HRTFs';
params.RecordingsBaseDir = '../recordings-all';
params.RecordingsExpectedFs = 48000;
params.RecordingLoadRange = [2.5 inf];
params.RecordingSpatRange = [0.5 7];
params.RecordingFadeTime = [0.01 0.01];
params.RecordingLevelScale = 0.9;
params.NChannels = 2;
params.Elevations = [0];
params.IRmax = 3 * 512;
params.FadeDuration = 2*10^-3;
params.TargetTrackLoudness = -23; % db
params.NRepetitions = 4;
params.InverseAzimuthHRTFGroups = ["cipic"];

params.HRTFs = loadHRTFs(params);

audioFilenames = dirWithoutDots(params.RecordingsBaseDir);
params.AudioFilename = audioFilenames(strcmp({audioFilenames.name}, 'Siren'));
audioFilename = params.AudioFilename;
[tracks,trackNames] = loadAudioTracks(audioFilename, params);

params.Tracks = normalizeAudioTracks(tracks, params);
params.TrackNames = trackNames;


% locations = linspace(0, 45, 46);
% widths = [90];

locations = 0;
widths = linspace(0, 90, 91);
inputs = cell(46, 91);


for iLocation = 1:length(locations)
    parfor iWidth = 1:length(widths)
        location = locations(iLocation);
        width = widths(iWidth);

        fprintf('location: %d, width: %d, recording: %s\n', ...
            location, width, params.AudioFilename.name)

        rng(7)
        params2 = params;
        params2.AzimuthEnsembleOffset = location;
        params2.MaxWidth = width / 2; % from ensemble center
        [features, spatResults, spatMetaresults] = generateFeatures(params2);

        input = struct();
        input.Features = features;
%         input.SpatResults = spatResults;
        input.SpatMetaResults = spatMetaresults;

        inputs{iLocation, iWidth} = input;
    end
end

%%

locations = linspace(0, 45, 46);
iWidth = length(widths);

parfor iLocation = 1:length(locations)    
    location = locations(iLocation);
    width = widths(iWidth);

    fprintf('location: %d, width: %d, recording: %s\n', ...
        location, width, params.AudioFilename.name)

    rng(7)
    params2 = params;
    params2.AzimuthEnsembleOffset = location;
    params2.MaxWidth = width / 2; % from ensemble center
    [features, spatResults, spatMetaresults] = generateFeatures(params2);

    input = struct();
    input.Features = features;
%     input.SpatResults = spatResults;
    input.SpatMetaResults = spatMetaresults;

    inputs{iLocation, iWidth} = input;
end

% % save("analysis1.mat", "-v7.3")

%%

assert(all(~cellfun(@isempty, inputs(:, end))))
assert(all(~cellfun(@isempty, inputs(1, :))))

for iLocation = 1:length(locations)
    for iWidth = 1:length(widths)
        input = inputs{iLocation, iWidth};

        if isempty(input)
            continue
        end

        location = locations(iLocation);
        width = widths(iWidth);

        fprintf('location: %d, width: %d, recording: %s\n', ...
            location, width, params.AudioFilename.name)

        fmt = @(x) sprintf('%0.1f', x / 1000);
        cfHz = arrayfun(fmt, input.Features.cfHz', 'UniformOutput', false);
        cfHzX = linspace(1, 64, 10);
        cfHz = cfHz(cfHzX);

        xtimeframe = floor(linspace(1, size(input.Features.ILD, 1), 8));
        timeframe = linspace(0, 7, 8);

        xtime = floor(linspace(1, size(input.Features.filterbankLeft, 1), 8));
        time = linspace(0, 7, 8);

        f = figure('visible','off');
        f.Position(3:4) = [1200 1200];
        t = tiledlayout(4, 7);
        t.TileSpacing = 'compact';
        t.Padding = 'compact';

        % Head

        nexttile([1 2])
        theta = deg2rad(input.SpatMetaResults.RandTrackAngles(:, 1));
        rho = ones(length(theta));
        polarplot(theta, rho, 'o', MarkerFaceColor='#0072BD')
        ax = gca;
        ax.ThetaDir = 'clockwise';
        ax.RLim = [0 1];
        ax.ThetaLim = [-90 90];
        ax.RTick = [];
        ax.ThetaTick = linspace(-90, 90, 13);

        hold on;
        pax = ax;
        paxPos = pax.Position;
        ax2 = axes(t);
        ax2.Layout.Tile = 1;
        ax2.Layout.TileSpan = [1 2];
        [img, ~, alpha] = imread('../figures/head.png');
        image(ax2, 'CData', img, AlphaData=alpha);
        axis(ax2, 'image')
        axis(ax2, 'off');
        xlim([-350 2200])
        hold off;

        txt = ['Recording: ' params.AudioFilename.name];
        a = annotation('textbox', [0.15 0.76 0 0], 'String', txt, ...
            'FitBoxToText', 'on');
        a.LineStyle = 'none';

        txt = {...
            ['\fontsize{16}\phi\fontsize{12} = ' num2str(location) '°']
            ['\fontsize{16}\omega\fontsize{12} = ' num2str(width) '°']            
            };
        a = annotation('textbox', [0.22 0.97 0 0], 'String', txt, ...
            'FitBoxToText', 'on');
        a.LineStyle = 'none';

        % Gammatone output

        nexttile([1 5])
        sdb = input.Features.filterbankLeft;
        surf(sdb');
        hcb = colorbar;
        hcb.Title.String = "Amplitude";
        ax = gca;
        ax.CLim = [-0.3 0.3];
        set(gca,'TickDir', 'both');
        title('Gammatone Filter Bank Output - Left Channel')
        xlabel('Time [s]')
        ylabel('Frequency [kHz]')
        xlim([xtime(1) xtime(end)])
        ylim([cfHzX(1) cfHzX(end)])
        grid
        shading('interp')
        view(0, 90)
        xticks(xtime)
        xticklabels(time)
        yticks(cfHzX)
        yticklabels(cfHz)

        % ILD mean

        nexttile([1 2])
        meanILD = mean(input.Features.ILD, 1);
        stdILD = std(input.Features.ILD);
        
        x = 1:64;
        xconf = [x x(end:-1:1)] ;         
        yconf = [meanILD + stdILD, meanILD(end:-1:1) - stdILD(end:-1:1)];
     
        hstd = fill(xconf, yconf, 'red', 'FaceAlpha', 0.1);
        hstd.EdgeColor = 'none';           
        
        hold on
        hmean = area(x, meanILD, ...
            'FaceAlpha', 0.05, ...
            'EdgeColor', '#0072BD', ...
            'FaceColor', '#0072BD');
        hold off

        set(gca,'XDir','reverse')
        xlabel('Frequency [kHz]')
        ylabel('Mean ILD')
        set(gca,'YAxisLocation','right')
        grid
        camroll(-90)
        xlim([cfHzX(1) cfHzX(end)])
        xticks(cfHzX)
        xticklabels(cfHz)

        hold on
        hp = plot([cfHzX(1) cfHzX(end)], [0 0]);
        hp.Color = "#D95319";
        hold off
        minLim = -6;
        maxLim = 6;

        if min(meanILD) <= minLim
            lowerYLim = min(meanILD);
        else 
            lowerYLim = minLim;
        end

        if max(meanILD) >= maxLim
            higherYLim = max(meanILD);
        else 
            higherYLim = maxLim;
        end

        ylim([lowerYLim higherYLim])
        legend([hmean hstd], {'ILD', '\fontsize{12}\sigma'}, Location='southwest');

        % ILD-gram

        nexttile([1 5])
        surf(input.Features.ILD')
        set(gca,'YDir','normal')
        hcb = colorbar;
        hcb.Title.String = "ILD";
        xlabel('Time [s]')
        ax = gca;
        ax.CLim = [-30 30];
        set(gca,'TickDir','both');
        title('ILD')
        xlim([xtimeframe(1) xtimeframe(end)])
        ylim([cfHzX(1) cfHzX(end)])
        ylabel('Frequency [kHz]')
        grid
        shading('interp')
        view(0, 90)
        xticks(xtimeframe)
        xticklabels(timeframe)
        yticks(cfHzX)
        yticklabels(cfHz)        

        % ITD mean
        
        nexttile([1 2])
        meanITD = mean(input.Features.ITD, 1);
        stdITD = std(input.Features.ITD);
        
        x = 1:64;
        xconf = [x x(end:-1:1)] ;         
        yconf = [meanITD + stdITD, meanITD(end:-1:1) - stdITD(end:-1:1)];
     
        hconf = fill(xconf, yconf, 'red', 'FaceAlpha', 0.1);
        hconf.EdgeColor = 'none';
        
        hold on
        hmean = area(x, meanITD, ...
            'FaceAlpha', 0.05, ...
            'EdgeColor', '#0072BD', ...
            'FaceColor', '#0072BD');
        hold off

        set(gca,'XDir','reverse')
        xlabel('Frequency [kHz]')
        ylabel('Mean ITD')
        set(gca,'YAxisLocation','right')
        grid
        camroll(-90)
        xlim([cfHzX(1) cfHzX(end)])
        xticks(cfHzX)
        xticklabels(cfHz)

        hold on
        hp = plot([cfHzX(1) cfHzX(end)], [0 0]);
        hp.Color = "#D95319";
        hold off
        minLim = -6e-4;
        maxLim = 6e-4;

        if min(meanITD) <= minLim
            lowerYLim = min(meanITD);
        else 
            lowerYLim = minLim;
        end

        if max(meanITD) >= maxLim
            higherYLim = max(meanITD);
        else 
            higherYLim = maxLim;
        end

        ylim([lowerYLim higherYLim])
        legend([hmean hstd], {'ITD', '\fontsize{12}\sigma'}, Location='southwest');

        % ITD-gram

        nexttile([1 5])
        surf(input.Features.ITD')
        set(gca,'YDir','normal')
        hcb = colorbar;
        hcb.Title.String = "ITD";
        xlabel('Time [s]')
        ax = gca;
        ax.CLim = [-1e-3 1e-3];
        set(gca,'TickDir','both');
        title('ITD')
        xlim([xtimeframe(1) xtimeframe(end)])
        ylim([cfHzX(1) cfHzX(end)])
        ylabel('Frequency [kHz]')
        grid
        shading('interp')
        view(0, 90)
        xticks(xtimeframe)
        xticklabels(timeframe)
        yticks(cfHzX)
        yticklabels(cfHz)

        % IC mean
        
        nexttile([1 2])
        meanIC = mean(input.Features.IC, 1);
        stdIC = std(input.Features.IC);
        
        x = 1:64;
        xconf = [x x(end:-1:1)] ;         
        yconf = [meanIC + stdIC, meanIC(end:-1:1) - stdIC(end:-1:1)];
     
        hconf = fill(xconf, yconf, 'red', 'FaceAlpha', 0.1);
        hconf.EdgeColor = 'none';      
        
        hold on
        hmean = area(meanIC, ...
            'FaceAlpha', 0.05, ...
            'EdgeColor', '#0072BD', ...
            'FaceColor', '#0072BD');
        hold off

        set(gca,'XDir','reverse')
        xlabel('Frequency [kHz]')
        ylabel('Mean IC')
        set(gca,'YAxisLocation','right')
        grid
        camroll(-90)
        xlim([cfHzX(1) cfHzX(end)])
        xticks(cfHzX)
        xticklabels(cfHz)

        hold on
        hp = plot([cfHzX(1) cfHzX(end)], [1 1]);
        hp.Color = "#D95319";
        hold off

        ylim([0 1.1])
        legend([hmean hstd], {'IC', '\fontsize{12}\sigma'}, Location='southwest');

        % IC-gram

        nexttile([1 5])
        surf(input.Features.IC')
        set(gca,'YDir','normal')
        hcb = colorbar;
        hcb.Title.String = "IC";
        xlabel('Time [s]')
        ax = gca;
        ax.CLim = [0 1];
        set(gca,'TickDir','both');
        title('IC')
        xlim([xtimeframe(1) xtimeframe(end)])
        ylim([cfHzX(1) cfHzX(end)])
        ylabel('Frequency [kHz]')
        grid
        shading('interp')
        view(0, 90)
        xticks(xtimeframe)
        xticklabels(timeframe)
        yticks(cfHzX)
        yticklabels(cfHz)


        % Save

        dirpath = sprintf('imgs/%s', params.AudioFilename.name);

        if ~exist(dirpath,'dir') 
            mkdir(dirpath); 
        end

        name = sprintf('%s/l%02dw%02drec%s.png', ...
            dirpath, location, width, params.AudioFilename.name);
        exportgraphics(f, name, Resolution=100)

        close(f)
    end
end
