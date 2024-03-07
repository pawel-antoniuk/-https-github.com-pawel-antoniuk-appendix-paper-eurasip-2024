% Trim and fade signal routine
function y = trimAndFadeSignal(x, params)    
    range = params.RecordingSpatRange * params.RecordingsExpectedFs - [0 1];
    y = x(range(1):sum(range), :);
    
    env = envGen(params.RecordingFadeTime(1), ...
        params.RecordingSpatRange(2), ...
        params.RecordingFadeTime(2), ...
        params.RecordingsExpectedFs, 2, 'sinsq')';
    y = y .* env;
end
