load('features_final_64_symmetrical_central')

% parpool(16)
parfor ii = 1:length(features)
    for deltaWindowLength = [3 5 9]
        deltaFrontSkip = deltaWindowLength;
    
        deltaILD = audioDelta(features(ii).ILD, deltaWindowLength);
        deltaITD = audioDelta(features(ii).ITD, deltaWindowLength);
        deltaIC = audioDelta(features(ii).IC, deltaWindowLength);
    
        deltaILD = deltaILD((1+deltaFrontSkip):end,:);
        deltaITD = deltaITD((1+deltaFrontSkip):end,:);
        deltaIC = deltaIC((1+deltaFrontSkip):end,:);
    
        computedFeatures(ii).("Mean_ILD_Raw") = mean(features(ii).ILD, 1);
        computedFeatures(ii).("Mean_ITD_Raw") = mean(features(ii).ITD, 1);
        computedFeatures(ii).("Mean_IC_Raw") = mean(features(ii).IC, 1);

        computedFeatures(ii).("Std_ILD_Raw") = std(features(ii).ILD, 0, 1);
        computedFeatures(ii).("Std_ITD_Raw") = std(features(ii).ITD, 0, 1);
        computedFeatures(ii).("Std_IC_Raw") = std(features(ii).IC, 0, 1);

        computedFeatures(ii).("Mean_ILD_Delta" + deltaWindowLength) = mean(deltaILD, 1);
        computedFeatures(ii).("Mean_ITD_Delta" + deltaWindowLength) = mean(deltaITD, 1);
        computedFeatures(ii).("Mean_IC_Delta" + deltaWindowLength) = mean(deltaIC, 1);

        computedFeatures(ii).("Std_ILD_Delta" + deltaWindowLength) = std(deltaILD, 0, 1);
        computedFeatures(ii).("Std_ITD_Delta" + deltaWindowLength) = std(deltaITD, 0, 1);
        computedFeatures(ii).("Std_IC_Delta" + deltaWindowLength) = std(deltaIC, 0, 1);
    end
end

save('features_computed_symmetrical_central.mat', 'computedFeatures', 'audioFilenames', 'audioFullFilenames', 'ensembleAcutalWidth', 'songNames', '-v7.3')
