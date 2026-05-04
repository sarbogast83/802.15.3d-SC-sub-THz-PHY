%% gen golay filters 

 % Ga128 for preamble sunc and SFD 
a128_hex = '5A5599963C33FFF00F00CCC36966AAA5';
a_bits = cell2mat(arrayfun(@(c) dec2bin(hex2dec(c), 4), a128_hex, 'UniformOutput', false)) - '0';
n = 0:length(a_bits)-1;
Ga = 2*a_bits(:) - 1;
GaRotated = Ga .*exp(1j*pi/2*n(:));
GaUp = upsample(GaRotated,sps);
GaRRC = conv(GaUp,RRC.h);
GaMatch = conv(GaRRC,RRC.h);
GaMatch = GaMatch(2*RRC.delay+1:end-2*RRC.delay);
GaFilter = conj(flip(GaMatch));
save('GaFilter',"GaFilter")

% Ga8 fro PW
a8_hex = 'EB';
a_bits = cell2mat(arrayfun(@(c) dec2bin(hex2dec(c), 4), a8_hex, 'UniformOutput', false)) - '0';
n = 0:length(a_bits)-1;
Ga = 2*a_bits(:) - 1;
GaRotated = Ga .*exp(1j*pi/2*n(:));
GaUp = upsample(GaRotated,sps);
GaRRC = conv(GaUp,RRC.h);
GaMatch = conv(GaRRC,RRC.h);
GaMatch = GaMatch(2*RRC.delay+1:end-2*RRC.delay);
PWFilter = conj(flip(GaMatch));
save('PWFilter',"PWFilter")
