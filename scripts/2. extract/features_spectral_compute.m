% load('features_sepctral_23_10_2023')

featureNames = fieldnames(features);
parfor ii = 1:length(features)

    for iFeature = 1:length(featureNames)
        featureName = featureNames{iFeature};
        computedFeatures(ii).("Mean_" + featureName) = mean(features(ii).(featureName), 1);
        computedFeatures(ii).("Std_" + featureName) = std(features(ii).(featureName), 0, 1);
    end
end

save('../features_spectral_computed.mat', 'featureNames', ...
    'computedFeatures', 'audioFilenames', 'audioFullFilenames', ...
    'ensembleAcutalWidth', 'songNames', '-v7.3')
