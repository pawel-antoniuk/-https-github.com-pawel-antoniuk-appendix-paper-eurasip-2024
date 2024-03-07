function HRTFs = loadHRTFs(params)
    HRTFFilenames = dir(fullfile(params.HRTFBaseDir, '*', '*.sofa'));
    
    % HRTF struct definition
    HRTFs = struct('Id', [], ...
        'Name', [], ...
        'Folder', [], ...
        'HRTFGroup', [], ...
        'SOFA', [], ...
        'Position', [], ...
        'Distance', []);
    HRTFGroupData = containers.Map;
    
    for iHRTF = 1:length(HRTFFilenames)
        filename = HRTFFilenames(iHRTF);
        fullFilename = fullfile(filename.folder, filename.name);
        
        HRTFs(iHRTF) = loadHRTF(iHRTF, fullFilename, params);   
        
        if HRTFs(iHRTF).SOFA.Data.SamplingRate ~= params.RecordingsExpectedFs
            [loadStatus,HRTFs(iHRTF)] = tryLoadResampledHRTF(iHRTF, ...
                HRTFs(iHRTF), params);
            if ~loadStatus
                resampleAndSave(HRTFs(iHRTF), params);
                [loadStatus,HRTFs(iHRTF)] = tryLoadResampledHRTF(iHRTF, ...
                    HRTFs(iHRTF), params);
                
                if ~loadStatus
                    error('Cannot find previously resampled HRTF');
                end
            end
        end

        ir =  HRTFs(iHRTF).SOFA.Data.IR;
        if size(ir, 3) > params.IRmax
            Nfadeout = params.FadeDuration*params.RecordingsExpectedFs;
            fade = [repelem(1,params.IRmax-Nfadeout), ...
                (cos(linspace(0,pi,Nfadeout))+1)/2];
            fade = reshape(fade,1,1,[]);
            ir = ir(:, :, 1:params.IRmax);
            HRTFs(iHRTF).SOFA.Data.IR = ir .* fade;
        end
        
        if ~isKey(HRTFGroupData, HRTFs(iHRTF).HRTFGroup)
            HRTFGroupData(HRTFs(iHRTF).HRTFGroup) = [];
        end
    
        HRTFGroupData(HRTFs(iHRTF).HRTFGroup) = [...
            HRTFGroupData(HRTFs(iHRTF).HRTFGroup) iHRTF];   
        
        fprintf('[%s][%s] azimuth: [%d, %d]; elevation: [%d, %d]; distance: %d\n', ...
            HRTFs(iHRTF).HRTFGroup, ...
            HRTFs(iHRTF).Name, ...
            min(HRTFs(iHRTF).Position(:, 1)), ...
            max(HRTFs(iHRTF).Position(:, 1)), ...
            min(HRTFs(iHRTF).Position(:, 2)), ...
            max(HRTFs(iHRTF).Position(:, 2)), ...
            HRTFs(iHRTF).Distance);
        
        if HRTFs(iHRTF).SOFA.Data.SamplingRate ~= params.RecordingsExpectedFs
            error('[%s][%s] Resampling from %d Hz to %d Hz', ...
                HRTF.HRTFGroup, HRTF.Name, ...
                HRTF.SOFA.Data.SamplingRate, ...
                params.RecordingsExpectedFs);
        end
    end
end
