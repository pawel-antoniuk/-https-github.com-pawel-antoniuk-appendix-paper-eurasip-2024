
directoryPath = '.';
mFiles = dir(fullfile(directoryPath, '*.m'));
[~, scriptName, ~] = fileparts(mfilename('fullpath'));

for k = 1:length(mFiles)
    [~, fileName, ~] = fileparts(mFiles(k).name);
    if ~strcmp(fileName, scriptName)
        filePath = fullfile(directoryPath, mFiles(k).name);
        fprintf('Running %s\n', filePath);
        run(filePath);
    else
        fprintf('Skipping %s\n', mFiles(k).name);
    end
end
