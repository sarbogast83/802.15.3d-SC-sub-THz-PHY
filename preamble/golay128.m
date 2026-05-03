
%%
clear; close all;

% table 13-13 *** these must be copied exactly ***
a128_hex = '5A5599963C33FFF00F00CCC36966AAA5';
b128_hex = 'A5AA6669C3CC000F0F00CCC36966AAA5'; % issue was here
% a128_hex = 'EB'; 
% b128_hex = 'D8'; 
% 2. Convert to raw bits (No flipping, No reversing) From Gemini
a_bits = cell2mat(arrayfun(@(c) dec2bin(hex2dec(c), 4), a128_hex, 'UniformOutput', false)) - '0';
b_bits = cell2mat(arrayfun(@(c) dec2bin(hex2dec(c), 4), b128_hex, 'UniformOutput', false)) - '0';

% Ga = 1 - 2*a_bits; 
% Gb = 1 - 2*b_bits;
Ga = 2*a_bits - 1; % bipoler direction does not matter 
Gb = 2*b_bits - 1;


n = (0:127);
GaTx = Ga .*exp(1j*pi/2*n);
GbTx = Gb .*exp(1j*pi/2*n);

%% RRC 
sps = 4;
span = 8;
rolloff = 0.25;
RRC = rcosdesign(rolloff,span,sps,"sqrt");
RRC = RRC / sqrt(sum(RRC.^2));
RRC_delay = (length(RRC)-1)/2;
GaTxUp = upsample(GaTx,sps);
GbTxUp = upsample(GbTx,sps);
GaTxRRC = conv(GaTxUp,RRC);
GbTxRRC = conv(GbTxUp,RRC);
GaMatch = conv(GaTxRRC,RRC);
GbMatch = conv(GbTxRRC,RRC);



%% 
GaFilter = conj(flip(GaMatch));
GbFilter = conj(flip(GbMatch));

%% SFD
GaSFD = -1*GaTx;
GaSFDUp = upsample(GaSFD,sps);
GaSFDRRC = conv(GaSFDUp,RRC);
GaSFDMatch = conv(GaSFDRRC,RRC);
% y = conv(Ga,flip(Ga));
% x = conv(Gb,flip(Gb));
% test pi/2
y = conv(GaSFDMatch,GaFilter);
x = conv(GbMatch,GbFilter);
perfect_spike = abs(x + y);

%%
% 5. Plotting with precise limits
figure;
plot(imag(y), 'LineWidth', 2);
grid on; 
%%
% save("golay128.mat","Ga","Gb")
