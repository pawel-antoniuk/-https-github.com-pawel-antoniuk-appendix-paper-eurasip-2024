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
params.iAudioFilename = 54;

params.HRTFs = loadHRTFs(params);

audioFilenames = dirWithoutDots(params.RecordingsBaseDir);
params.AudioFilename = audioFilenames(194);
audioFilename = params.AudioFilename;
[tracks,trackNames] = loadAudioTracks(audioFilename, params);

params.Tracks = normalizeAudioTracks(tracks, params);
params.TrackNames = trackNames;


% locations = linspace(0, 45, 46);
% widths = [90];

locations = 0;
widths = linspace(0, 90, 91);
inputs = cell(1, length(widths));


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

meanILDS = zeros(size(inputs{1}.Features.ILD, 2), length(inputs));

for ii = 1:length(inputs)
    meanILD = mean(inputs{ii}.Features.ILD, 1);
    meanILDS(:, ii) = meanILD;
end

close all;
f = figure;
f.Position(3:4) = [600 400];
hs = surf((1:size(meanILDS, 2))-1, ...
            inputs{1}.Features.cfHz / 1000, ...
            meanILDS);
grid
shading('interp')
view(0,90)
xlim([0, 90])
ylim([0.1 16])
xlabel('Ensemble Width \fontsize{16}\omega')
ylabel('Frequency [kHz]')
hcb = colorbar;
hcb.Title.String = "ILD";
set(h,'edgecolor','k')
set(hs,'EdgeAlpha', 0.2)
set(gca,'TickDir','both');

exportgraphics(f, name, Resolution=100)


