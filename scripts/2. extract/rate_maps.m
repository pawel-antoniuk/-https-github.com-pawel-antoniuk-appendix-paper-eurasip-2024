% clear; clc;
% 
% % startup
% parpool(16)
addpath('TwoEars-1.5')
startTwoEars

audioFilenamePatterns = ...
	"../spatresults/spat/*.wav";

contents = dir(audioFilenamePatterns);
audioFilenames = convertCharsToStrings({contents.name});
audioFolders = convertCharsToStrings(squeeze(split({contents.folder}, filesep)));
audioFullFilenames = fullfile({contents.folder}, {contents.name});
audioFullFilenames = convertCharsToStrings(audioFullFilenames);
nAudioFilenames = length(audioFilenames);

audioInfo = audioinfo(audioFullFilenames(1));
audio.SampleRate = audioInfo.SampleRate;
audio.Duration = audioInfo.Duration;
audio.TotalSamples = audioInfo.TotalSamples;

filenameParts = arrayfun(@(x) strsplit(x, filesep), audioFilenames, 'UniformOutput', false);
filenameParts = [filenameParts{:}];
filenameParts = arrayfun(@(x) strsplit(x, '_'), filenameParts, 'UniformOutput', false);
filenameParts = cat(1, filenameParts{:});

ensembleAcutalWidth = str2double(erase(filenameParts(:,4), "width"));
ensembleElevation = str2double(erase(filenameParts(:,5), "el"));
songNames = filenameParts(:,1);

frameDuration = 0.02;
hopFactor = 0.5; 
nFilterBankChannels = 64;

twoEarsParams = genParStruct(...
	'pp_bRemoveDC', true, ...
	'pp_cutoffHzDC', 20, ...
	'fb_type', 'gammatone', ...
	'fb_nChannels', nFilterBankChannels, ...
	'fb_lowFreqHz', 100, ...
	'fb_highFreqHz', 16000, ...
	'ihc_method', 'dau', ...
	'ild_wSizeSec', frameDuration, ...
	'ild_hSizeSec', hopFactor* frameDuration,...
	'ild_wname', 'hann', ...
	'cc_wSizeSec', frameDuration, ...
	'cc_hSizeSec', hopFactor* frameDuration,...
	'cc_wname', 'hann', ...
	'cc_maxDelaySec', 0.0011,...
	'rm_wSizeSec', frameDuration, ...
	'rm_hSizeSec', hopFactor*frameDuration,...
	'rm_scaling', 'power', ...
	'rm_decaySec', 8E-3, ...
	'rm_wname', 'hann');

% extract
params.AudioFullFilenames = audioFullFilenames;
params.TwoEarsParams = twoEarsParams;

featureNames = ["Features_mean_ILD_" + (1:64), ...
	"Features_mean_ITD_" + (1:64), ...
	"Features_mean_IC_" + (1:64), ...
	"Features_std_ILD_" + (1:64), ...
	"Features_std_ITD_" + (1:64), ...
	"Features_std_IC_" + (1:64)];

featureNames = convertStringsToChars(featureNames);

start = tic;
nPartitions = 20;
proceed = [];

% iPartitionBegin = iPartition + 1;

for iFilename = 1:1
	audioFullFilename = params.AudioFullFilenames(iFilename);
	[xy,fs] = audioread(audioFullFilename);

	xy = xy - ones(size(xy)) * diag(mean(xy)); % remove DC offset

	dataObj = dataObject(xy, fs, length(xy) / fs, 2);    
	managerObj = manager(dataObj, {'ratemap'}, params.TwoEarsParams);
	managerObj.processSignal();

% 	dataObj.clearData
% 	managerObj.reset
% 	managerObj.cleanup
end




