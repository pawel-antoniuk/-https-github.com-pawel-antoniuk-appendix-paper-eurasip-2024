% Spatialize audio routine
function spatResults = spatializeAudioTracks(...
    tracks, HRTF, metaResults, params)   

    spatResults = [];
    
    for iMetaresults = 1:length(metaResults)
        metaResult = metaResults(iMetaresults);
        interpHRTF = interpolateHRTF( ...
            HRTF.SOFA.Data.IR, ...
            HRTF.Position, ...
            metaResult.RandTrackAngles);
        spatResult = zeros(size(tracks,1) + size(interpHRTF,3) - 1, 2);        
        
        for iTrack = 1:size(interpHRTF, 1)
            track = tracks(:, iTrack); 
            spatTrack = [
                conv(squeeze(interpHRTF(iTrack, 1, :)), track) ...
                conv(squeeze(interpHRTF(iTrack, 2, :)), track)];
            spatResult = spatResult + spatTrack;
        end
        
        spatResult = trimAndFadeSignal(spatResult, params);

        if isempty(spatResults)
            spatResults = zeros([length(metaResults) size(spatResult)]);
        end
        spatResults(iMetaresults, :, :) = spatResult;
    end
end

