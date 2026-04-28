
%%
clear; close all;

% table 13-13 *** these must be copied exactly ***
a128_hex = '5A5599963C33FFF00F00CCC36966AAA5';
b128_hex = 'A5AA6669C3CC000F0F00CCC36966AAA5'; % issue was here

% 2. Convert to raw bits (No flipping, No reversing) From Gemini
a_bits = cell2mat(arrayfun(@(c) dec2bin(hex2dec(c), 4), a128_hex, 'UniformOutput', false)) - '0';
b_bits = cell2mat(arrayfun(@(c) dec2bin(hex2dec(c), 4), b128_hex, 'UniformOutput', false)) - '0';

% Ga = 1 - 2*a_bits; 
% Gb = 1 - 2*b_bits;
Ga = 2*a_bits - 1; % bipoler direction does not mater 
Gb = 2*b_bits - 1;


y = conv(Ga,flip(Ga));
x = conv(Gb,flip(Gb));
perfect_spike = x + y;

% 5. Plotting with precise limits
figure;
plot(perfect_spike, 'LineWidth', 2);
grid on; 

