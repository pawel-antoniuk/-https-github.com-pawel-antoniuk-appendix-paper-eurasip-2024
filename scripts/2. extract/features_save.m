% load('features_final_computed.mat')

fldNames = convertCharsToStrings(fieldnames(computedFeatures));

parfor iFeature = 1:length(computedFeatures)
    outTrecord = [];
    for iField = 1:length(fldNames)
        fldName = fldNames{iField};
        features = computedFeatures(iFeature).(fldName);
        variableNames = "Features_" + fldName + "_" + (1:length(features));
        outTrecord = [outTrecord array2table(features, VariableNames=variableNames)];
    end
    outT(iFeature, :) = outTrecord;
end

outT.AudioFilenames = audioFilenames';
outT.SongNames = songNames;
outT.EnsembleAcutalWidth = ensembleAcutalWidth;

writetable(outT,'features.csv');