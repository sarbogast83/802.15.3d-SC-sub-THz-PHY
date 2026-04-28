% 

clear

a128_hex = '5A5599963C33FFF00F00CCC36966AAA5'; % tab 13-3
b128_hex = 'A5AA6669C3CC000FFFF0CCC36966AAA5';

% 2. Convert to raw 1s and 0s (Human-readable, MSB first) Gemini
a128_bin_str = cell2mat(arrayfun(@(c) dec2bin(hex2dec(c), 4), a128_hex, 'UniformOutput', false));
b128_bin_str = cell2mat(arrayfun(@(c) dec2bin(hex2dec(c), 4), b128_hex, 'UniformOutput', false));

a128_bits = str2num(a128_bin_str(:))'; 
b128_bits = str2num(b128_bin_str(:))'; 



Ga128 = zeros(1, 128);
Gb128 = zeros(1, 128);
for i = 0:15
    byte = (i*8 + (1:8));
    aByte = a128_bits(byte);
    Ga128(byte) = flip(aByte); 
    bByte = b128_bits(byte);
    Gb128(byte) = flip(bByte); 
end

%% check 
Ga128sym = Ga128*2-1;
y = conv(Ga128sym, flip(Ga128sym));
figure
plot(y)
title('Autocorrelation of Ga128 (Has Sidelobes)')

%% 
Gb128sym = Gb128*2-1; % FIX 1: Map Gb128 instead of duplicating Ga128
x = conv(Gb128sym, flip(Gb128sym)); % FIX 2: Autocorrelate Gb with Gb (using bipolar 'sym')
figure
plot(x)
title('Autocorrelation of Gb128 (Has Sidelobes)')

% Perfect Cancellation
figure 
plot(x + y)
title('Sum of Autocorrelations (Perfect Spike)')
xlabel('Lag');
ylabel('Amplitude');


%%
clear; close all;

% 1. EXACT HEX FROM IEEE 802.15.3d-2017
a128_hex = '5A5599963C33FFF00F00CCC36966AAA5';
b128_hex = 'A5AA6669C3CC000F0F00CCC36966AAA5'; % Ensure this matches exactly!

% 2. Convert to raw bits (No flipping, No reversing)
a_bits = cell2mat(arrayfun(@(c) dec2bin(hex2dec(c), 4), a128_hex, 'UniformOutput', false)) - '0';
b_bits = cell2mat(arrayfun(@(c) dec2bin(hex2dec(c), 4), b128_hex, 'UniformOutput', false)) - '0';

% 3. THE FIX: Standard Bipolar Mapping
% This maps 0 -> +1 and 1 -> -1
Ga = 1 - 2*a_bits; 
Gb = 1 - 2*b_bits;

% 4. Sum of Autocorrelations
% Summing these MUST equal exactly 256 at center and 0 elsewhere
y = xcorr(Ga);
x = xcorr(Gb);
perfect_spike = x + y;

% 5. Plotting with precise limits
figure;
plot(perfect_spike, 'LineWidth', 2);
grid on; 
title('IEEE 802.15.3d: Final Verified Zero-Sidelobe Spike');
xlabel('Lag'); ylabel('Amplitude');
ylim([-10, 270]); % If there are wiggles, they will show here

% 6. Numerical Verification
max_sidelobe = max(abs(perfect_spike([1:127, 129:end])));
fprintf('The peak value is: %f\n', perfect_spike(128));
fprintf('The maximum sidelobe level is: %f\n', max_sidelobe);
