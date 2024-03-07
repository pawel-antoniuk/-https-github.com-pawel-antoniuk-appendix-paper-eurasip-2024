function plotAudioScene(HRTFs, spatMetaresults, params)
    
    if ~exist(params.FinalResultsOutputDir, 'dir')
        mkdir(params.FinalResultsOutputDir);
    end
    
    HRTFGroups = convertCharsToStrings(unique({HRTFs.HRTFGroup}));
    
    for iHRTFGroup = 1:length(HRTFGroups)
        fig = figure('Position', [0, 0, 1400, 1200]);
        
        HRTFGroupName = HRTFGroups(iHRTFGroup);    
        HRTFidx = strcmp({HRTFs.HRTFGroup}, HRTFGroupName);        
            
        for iHRTF = find(HRTFidx)
            selectedSpatMetaresults = spatMetaresults(:, iHRTF, :);
            spatMetaresult = reshape(selectedSpatMetaresults, 1, []);

            randTrackAngles = cat(1,spatMetaresult.RandTrackAngles);    
            HRTFpos = unique(cat(1, HRTFs(iHRTF).Position), 'rows');

            [x, y, z] = sph2cart(deg2rad(HRTFpos(:, 1)), ...
                deg2rad(HRTFpos(:, 2)), 1); 
            scatter3(x, y, z, 1, 'k.');          

            hold on                                        

            [x, y, z] = sph2cart(...
                deg2rad(randTrackAngles(:, 1)), ...
                deg2rad(randTrackAngles(:, 2)), 1);        
            
            h = scatter3(x, y, z, 20, 'filled', 'b');
            set(h, 'MarkerEdgeAlpha', 0.5, 'MarkerFaceAlpha', 0.5);                    
        end
        hold off

        xlim([-1.25 1.25])
        ylim([-1.25 1.25])
        zlim([-1.25 1.25])
        pbaspect([1 1 1])                    
        xlabel('x')
        ylabel('y')
        zlabel('z')
        colormap jet;  
        cb = colorbar; ylabel(cb, 'Count');

        sgtitle(HRTFGroupName);    
        saveas(fig, fullfile(params.FinalResultsOutputDir, ...
            HRTFGroupName + '.png'));
    end
end