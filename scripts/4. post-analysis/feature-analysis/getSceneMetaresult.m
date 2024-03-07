
function metaResults = getSceneMetaresult(HRTF, audioName, trackNames, elevation, params)
    width = params.MaxWidth;    

    randTrackAngles = rand(floor(length(trackNames) / 2) + 1, 1);
    randTrackAngles = rescale(randTrackAngles, 0, width);
    randTrackAngles = randTrackAngles(randTrackAngles ~= 0);
    randTrackAngles = [randTrackAngles; -flip(randTrackAngles)];

    if mod(length(trackNames), 2) ~= 0
        middleIndex = ceil((length(randTrackAngles) + 1) / 2); 
        randTrackAngles = [randTrackAngles(1:middleIndex-1); 0; randTrackAngles(middleIndex:end)];
    end

    assert(all(randTrackAngles + flip(randTrackAngles) == 0))

    randTrackAngles = [randTrackAngles; zeros(length(trackNames) - length(randTrackAngles), 1)];
    randTrackAngles = randTrackAngles(randperm(length(randTrackAngles)));
    randTrackAngles = wrapTo180(randTrackAngles);
    randTrackAngles = randTrackAngles + params.AzimuthEnsembleOffset;
    randTrackAngles(:, 2) = elevation;

    assert(size(randTrackAngles, 1) == length(trackNames))

    metaResults.AudioName = audioName;
    metaResults.TrackNames = trackNames;
    metaResults.HRTFId = HRTF.Id;
    metaResults.RandTrackAngles = randTrackAngles;
    metaResults.Elevation = elevation;
    metaResults.SceneWidth = width;
    metaResults.AzimuthEnsembleOffset = params.AzimuthEnsembleOffset;
end
