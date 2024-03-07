load('features_computed_symmetrical_central.mat')

fldNames = convertCharsToStrings(fieldnames(computedFeatures));

for iFeature = 1:length(computedFeatures)
    outTrecord = [];
    for iField = 1:length(fldNames)
        fldName = fldNames{iField};
        features = computedFeatures(iFeature).(fldName);
        variableNames = "Features_" + fldName;
        outTrecord = [outTrecord array2table(features, VariableNames=variableNames)];
    end
    outT(iFeature, :) = outTrecord;
end

outT.AudioFilenames = audioFilenames';
outT.SongNames = songNames;
outT.EnsembleAcutalWidth = ensembleAcutalWidth;

writetable(outT,'features_symmetrical_central.csv');