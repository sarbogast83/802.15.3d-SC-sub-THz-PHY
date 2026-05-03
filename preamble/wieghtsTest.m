
clear; clc;
% table 13-13 *** these must be copied exactly ***
a128_hex = '5A5599963C33FFF00F00CCC36966AAA5';
b128_hex = 'A5AA6669C3CC000F0F00CCC36966AAA5'; % issue was here
a8_hex = 'EB'; 
b8_hex = 'D8'; 

% 2. Convert to raw bits (No flipping, No reversing) From Gemini
a128_bits = cell2mat(arrayfun(@(c) dec2bin(hex2dec(c), 4), a128_hex, 'UniformOutput', false)) - '0';
b128_bits = cell2mat(arrayfun(@(c) dec2bin(hex2dec(c), 4), b128_hex, 'UniformOutput', false)) - '0';
a8_bits = cell2mat(arrayfun(@(c) dec2bin(hex2dec(c), 4), a8_hex, 'UniformOutput', false)) - '0';
b8_bits = cell2mat(arrayfun(@(c) dec2bin(hex2dec(c), 4), b8_hex, 'UniformOutput', false)) - '0';

% Ga = 1 - 2*a_bits; 
% Gb = 1 - 2*b_bits;
Ga128 = 2*a128_bits - 1; % bipoler direction does not matter 
Gb128 = 2*b128_bits - 1;
Ga8 = 2*a8_bits - 1; % bipoler direction does not matter 
Gb8 = 2*b8_bits - 1;

% 1. 802.15.3d Parameters
N = 7; 
D = [1, 2, 4, 8, 16, 32, 64];       % 802.11ad/ay
W = [1, 1, 1, 1, 1, -1, 1];         % 802.11ad/ay

% 2. Generate Ga128/Gb128 Preamble
Ga = 1; 
Gb = 1;
for i = 1:N
    Ga_next = [Ga,  W(i)*Gb];
    Gb_next = [Ga, -W(i)*Gb];
    Ga = Ga_next; 
    Gb = Gb_next;
    if i == 3 % check G 8
        Ga8test = sum(Ga~=Ga8);
        Gb8test = sum(Gb~=Gb8);
    end
end
Ga128test = sum(Ga~=Ga128);
Gb128test = sum(Gb~=Gb128);

% 3. Simulate Received Signal (with π/2-BPSK common in THz-SC)
% Add zero-padding to simulate unknown arrival time
tx_preamble = Ga; 
rx_signal = [zeros(1, 100), tx_preamble, zeros(1, 100)];
rx_signal = awgn(rx_signal, 5, 'measured'); % Add Noise

% 4. Efficient Golay Correlator (EGC) Implementation
pa = rx_signal; 
pb = rx_signal;

for i = 1:N
    da = pa; db = pb;
    % Delay block: shift by D(i)
    delayed_db = [zeros(1, D(i)), db(1:end-D(i))];
    
    % Update paths (2N adders logic)
    pa = da + W(i) * delayed_db;
    pb = da - W(i) * delayed_db;
end

% 5. Results
figure;
plot(abs(pa), 'LineWidth', 1.5); grid on;
title('802.15.3d Preamble Detection (Ga128)');
xlabel('Sample Index'); ylabel('Correlation Magnitude');
legend('EGC Output (Correlation Peak)');
