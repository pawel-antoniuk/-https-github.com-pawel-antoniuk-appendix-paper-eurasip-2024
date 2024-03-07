HRTFs = loadHRTFs(params);
audioFilename = params.AudioFilename;
[tracks,trackNames] = loadAudioTracks(audioFilename, params);
tracks = normalizeAudioTracks(tracks, params);