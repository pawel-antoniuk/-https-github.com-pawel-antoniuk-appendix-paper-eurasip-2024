load('features_sepctral_23_10_2023.mat')

fldNames = convertCharsToStrings(fieldnames(computedFeatures));

parfor iFeature = 1:length(computedFeatures)
    outTrecord = [];
    for iField = 1:length(fldNames)
        fldName = fldNames{iField};
        variableNames = "Features_" + fldName;
        outTrecord = [outTrecord array2table(features, VariableNames=variableNames)];
    end
    outT(iFeature, :) = outTrecord;
end

outT.AudioFilenames = audioFilenames';
outT.SongNames = songNames;
outT.EnsembleAcutalWidth = ensembleAcutalWidth;

writetable(outT,'features_spectral.csv');