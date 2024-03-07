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

recordingNmaes = {'IAmAlright', 'Siren', 'RumbaChonta'};

for recordingName = recordingNmaes
    audioFilenames = dirWithoutDots(params.RecordingsBaseDir);
    params.AudioFilename = audioFilenames(strcmp({audioFilenames.name}, recordingName));
    audioFilename = params.AudioFilename;
    [tracks,trackNames] = loadAudioTracks(audioFilename, params);
    
    params.Tracks = normalizeAudioTracks(tracks, params);
    params.TrackNames = trackNames;
    
    widths = [0 30 60 90];
    inputs = cell(1, length(widths));
    
    for iWidth = 1:length(widths)
        width = widths(iWidth);
    
        rng(11)
        params2 = params;
        params2.AzimuthEnsembleOffset = 0;
        params2.MaxWidth = width / 2; % from ensemble center
        [features, spatResults, spatMetaresults] = generateFeatures(params2);
    
        input = struct();
        input.Features = features;
        input.SpatMetaResults = spatMetaresults;
    
        inputs{1, iWidth} = input;
    end
    
    
    %%
    
    f = figure;
    f.Position(3:4) = [1200 1200];
    t = tiledlayout(4, 4);
    t.TileSpacing = 'compact';
    t.Padding = 'compact';
    
    
    for iWidth = 1:length(widths)
        input = inputs{1, iWidth};
    
        if isempty(input)
            continue
        end
    
        location = 0;
        width = widths(iWidth);
    
        fmt = @(x) sprintf('%0.1f', x / 1000);
        cfHz = arrayfun(fmt, input.Features.cfHz', 'UniformOutput', false);
        cfHzX = linspace(1, 64, 8);
        cfHz = cfHz(cfHzX);
    
        xtimeframe = floor(linspace(1, size(input.Features.ILD, 1), 8));
        timeframe = linspace(0, 7, 8);
    
        xtime = floor(linspace(1, size(input.Features.filterbankLeft, 1), 8));
        time = linspace(0, 7, 8);
    
        % Head
    
        nexttile
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
        ax2.Layout = ax.Layout;
        [img, ~, alpha] = imread('../figures/head2.png');
        image(ax2, 'CData', img, AlphaData=alpha);
        axis(ax2, 'image')
        axis(ax2, 'off');
        xlim([-60 800])
        hold off;
    
        txt = {
            ['\fontsize{16}\omega\fontsize{12} = ' num2str(width) '°']            
            };
        text(700, 500, txt)
      
        % ILD mean    
        nexttile
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
    
        xlabel('Frequency [kHz]')
        ylabel('Mean ILD')
        grid
        xlim([cfHzX(1) cfHzX(end)])
        xticks(cfHzX)
        xticklabels(cfHz)
    
        hold on
        hp = plot([cfHzX(1) cfHzX(end)], [0 0]);
        hp.Color = "#D95319";
        hold off
    
        ylim([-16 16])
        legend([hmean hstd], {'ILD', '\fontsize{12}\sigma'}, Location='southwest');

        if iWidth == 1
            title('ILD')
        end
    
        % ITD mean        
        nexttile
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
    
        xlabel('Frequency [kHz]')
        ylabel('Mean ITD')
        grid
        xlim([cfHzX(1) cfHzX(end)])
        xticks(cfHzX)
        xticklabels(cfHz)
    
        hold on
        hp = plot([cfHzX(1) cfHzX(end)], [0 0]);
        hp.Color = "#D95319";
        hold off
    
        ylim([-6e-4 6e-4])
        legend([hmean hstd], {'ITD', '\fontsize{12}\sigma'}, Location='southwest');

        if iWidth == 1
            title('ITD')
        end
    
        % IC mean       
        nexttile
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
    
        xlabel('Frequency [kHz]')
        ylabel('Mean IC')
        grid
        xlim([cfHzX(1) cfHzX(end)])
        xticks(cfHzX)
        xticklabels(cfHz)
    
        hold on
        hp = plot([cfHzX(1) cfHzX(end)], [1 1]);
        hp.Color = "#D95319";
        hold off
    
        ylim([0 1.1])
        legend([hmean hstd], {'IC', '\fontsize{12}\sigma'}, Location='southwest');

        if iWidth == 1
            title('IC')
        end
    
    end
    
    % Save
    
    name = sprintf('imgs/%s.png', params.AudioFilename.name);
    exportgraphics(f, name, Resolution=300)

end
