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

%% 
N = 7;
W = [];
D = [1, 2, 4, 8, 16, 32, 64];
% Ga128 = 1:2^N; % test
for i = N:-1:1
    aPrior = Ga128(1:end/2);
    bPrior = Ga128(end/2+1:end);

    
end