% Spatialize all audio trakcs routine
% spatResults shape (HRTF, dir, sample, ch)
function [outSpatResults,outSpatMetaResults] = spatializeSong(HRTFs, tracks, trackNames, audioName, params)    
    sz = [length(params.Elevations), ...
        length(HRTFs)];
    dur = params.RecordingSpatRange(2) * params.RecordingsExpectedFs;
    outSpatResults = zeros([sz ...
        dur params.NChannels]);
    outSpatMetaResults = cell(sz);
    trackNamesParts = split(trackNames, '.wav');
    trackNames = trackNamesParts(:, :, 1);
    
    for comb = allcomb(...
            1:length(params.Elevations), ...
            1:length(HRTFs))'
        cComb = num2cell(comb);
        [iElevation,iHRTF] = cComb{:};
        elevation = params.Elevations(iElevation);

        metaResults = getSceneMetaresult(HRTFs(iHRTF), audioName, ...
            trackNames, elevation, params);          
        
        spatResults = spatializeAudioTracks(...
            tracks, HRTFs(iHRTF), metaResults, params);

        outSpatResults(iElevation, iHRTF,:,:,:) = spatResults;
        outSpatMetaResults(iElevation, iHRTF) = {reshape(metaResults, 1, 1, [])};
    end
    
    outSpatMetaResults = cell2mat(outSpatMetaResults);
end
