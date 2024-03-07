
% Postprocess spatialization results routine
function spatResults = posprocessSpatResults(spatResults, params)    
    % Peak normalization and scaling
    peakLevel = max(abs(spatResults), [], [3 4 5]);
    spatResults = params.RecordingLevelScale * spatResults ./ peakLevel;
    
    % DC equalization
    spatResults = spatResults - mean(spatResults, 3);
end


