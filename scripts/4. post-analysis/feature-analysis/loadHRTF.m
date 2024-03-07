% Load HRTF routine
function HRTF = loadHRTF(id, filename, params)
    listing = dir(filename);
    fullFilename = fullfile(listing.folder, listing.name);
    filenameParts = split(listing.folder, filesep);
    SOFA = SOFAload(fullFilename);
    APV = SOFAcalculateAPV(SOFA);
    
    HRTF.Id = id;
    HRTF.Name = listing.name;
    HRTF.Folder = listing.folder;
    HRTF.HRTFGroup = filenameParts{end};
    HRTF.SOFA = SOFA;
    HRTF.Position = APV(:, 1:2);
    HRTF.Distance = unique(HRTF.SOFA.SourcePosition(:, 3));

    if any(strcmp(HRTF.HRTFGroup, params.InverseAzimuthHRTFGroups))
        HRTF.Position = HRTF.Position * [-1 0; 0 1];
    end
    
    if mod(HRTF.SOFA.API.N, 2) ~= 0
        tmpIR = HRTF.SOFA.Data.IR(:, :, 1:end-1); % Remove last sample
        HRTF.SOFA.Data.IR = tmpIR;
        HRTF.SOFA.API.N = size(tmpIR, 3);
    end    
end
