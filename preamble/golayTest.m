clear; close all;

% 1. Recursive generation of Golay Complementary Sequences
% This is the standard generator used for 802.11 and 802.15 128-bit pairs
A = [1, 1];
B = [1, -1];

for i = 1:6
    A_new = [A, B];
    B_new = [A, -B];
    A = A_new;
    B = B_new;
end

% A and B are now exactly 128 elements long.
Ga128sym = A;
Gb128sym = B;
Ga = wlanGolaySequence(128);
check = sum(Ga128sym~=Ga');
% 2. Calculate aperiodic autocorrelations
y = conv(Ga128sym, flip(Ga128sym));
x = conv(Gb128sym, flip(Gb128sym));

% 3. Check and Plot Results
figure('Position', [100, 100, 800, 600]);

subplot(3,1,1);
plot(y, 'b', 'LineWidth', 1.5);
title('Autocorrelation of Ga128 (Contains Sidelobes)');
grid on;

subplot(3,1,2);
plot(x, 'r', 'LineWidth', 1.5);
title('Autocorrelation of Gb128 (Contains Sidelobes)');
grid on;

subplot(3,1,3);
% This is the magic of Golay pairs: the sidelobes cancel perfectly!
plot(x + y, 'g', 'LineWidth', 2);
title('Sum of Autocorrelations (Perfect Zero-Sidelobe Spike)');
xlabel('Lag');
ylabel('Amplitude');
ylim([-20, 280]);
grid on;

% Command window verification
disp(['Max value (Peak): ', num2str(max(x + y))]);
% Check that everything outside the peak is exactly zero
peak_idx = find((x+y) == max(x+y));
out_of_phase = x + y;
out_of_phase(peak_idx) = 0;
disp(['Max out-of-phase sidelobe level: ', num2str(max(abs(out_of_phase)))]);
