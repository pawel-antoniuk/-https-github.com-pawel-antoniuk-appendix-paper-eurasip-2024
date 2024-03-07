% Try load resampled HRTF routine
function [loadStatus, HRTF] = tryLoadResampledHRTF(id, HRTF, params)
    resampledSOFAdir = fullfile(params.HRTFBaseDir, ...
        ['_resampled_' num2str(params.RecordingsExpectedFs)], ...
        HRTF.HRTFGroup);
    resampledSOFAfilename = ['_resampled_' ...
        num2str(params.RecordingsExpectedFs) '_' HRTF.Name];
    fullSOFAfilename = fullfile(resampledSOFAdir, resampledSOFAfilename);
    
    if ~exist(fullSOFAfilename, 'file')
        loadStatus = false;
    else
        loadStatus = true;
        HRTF = loadHRTF(id, fullSOFAfilename, params);
    end
end