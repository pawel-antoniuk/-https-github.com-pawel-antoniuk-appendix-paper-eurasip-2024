% load spatialized_12_06_2023.mat

for iHRTF = 1:length(HRTFs)
    HRTF = HRTFs(iHRTF);
    positions = HRTF.Position;
    horiziontalPositions = unique(positions(:, 1));
    shiftedPositions1 = [horiziontalPositions(end); horiziontalPositions];
    shiftedPositions2 = [horiziontalPositions; horiziontalPositions(1)];
    differences = wrapTo360(shiftedPositions2 - shiftedPositions1);
    HRTFs(iHRTF).MeanHorizontalResolution = mean(differences);
    HRTFs(iHRTF).MedianHorizontalResolution = median(differences);
    HRTFs(iHRTF).MinHorizontalResolution = min(differences);
    HRTFs(iHRTF).MaxHorizontalResolution = max(differences);
end