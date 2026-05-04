sro = comm.SampleRateOffset('Offset', 0);
impulse = [1; zeros(100, 1)]; % Single pulse
output = sro(impulse);
[~, idx] = max(abs(output));
algoDelay = idx - 1; 
fprintf('The current algorithmic delay is %d samples.\n', algoDelay);