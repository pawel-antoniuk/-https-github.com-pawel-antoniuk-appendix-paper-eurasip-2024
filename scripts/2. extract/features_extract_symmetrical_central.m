% clear; clc;
% 
% % startup
% parpool(16)
addpath('TwoEars-1.5')
startTwoEars

audioFilenamePatterns = ...
	"../spatresults-symmetrical-central/spat/*.wav";

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

for iPartition = 1:nPartitions
	partBegin = floor((iPartition - 1) * length(params.AudioFullFilenames) / nPartitions + 1);
	partEnd = floor(iPartition * length(params.AudioFullFilenames) / nPartitions);
    partLen = length(partBegin:partEnd);
    proceed = [proceed partBegin:partEnd];

	parfor iFilename = partBegin:partEnd
		audioFullFilename = params.AudioFullFilenames(iFilename);
		[xy,fs] = audioread(audioFullFilename);
	
		xy = xy - ones(size(xy)) * diag(mean(xy)); % remove DC offset
    
		dataObj = dataObject(xy, fs, length(xy) / fs, 2);    
		managerObj = manager(dataObj, {'ild', 'itd', 'ic'}, params.TwoEarsParams);
		managerObj.processSignal();
	
		features(iFilename).ILD = managerObj.Data.ild{1}.Data(:);
		features(iFilename).ITD = managerObj.Data.itd{1}.Data(:);
		features(iFilename).IC = managerObj.Data.ic{1}.Data(:);

		dataObj.clearData
		managerObj.reset
		managerObj.cleanup
	end

%     if mod(iPartition, 5) == 0 
%         save ../features_symmetrical_central_progress_64 -v7.3
%     end

	tEnd = toc(start);
	fprintf('[progress %d:%2.f] %0.1f%% (from %d to %d)\n', ...
		floor(tEnd / 60), ...
		floor(rem(tEnd, 60)), ...
		iPartition / nPartitions * 100, ...
        partBegin, partEnd);
end

assert(issorted(proceed, 'strictascend'), 'proceed is not in order');
assert(proceed(1) == 1 & proceed(end) == length(params.AudioFullFilenames), ...
    'proceed has incorrent content');

toc(start)

save features_final_64_symmetrical_central -v7.3



