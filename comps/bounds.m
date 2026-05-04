% sTeve Arbogast
% params 

clear
deltaFc = 60e-6; % +-carrier diviation ppm
deltaClock = 60e-6; % +- clock 
deltaSym = 60e-6; % +- sym rate
EVMmax = -7; % dB
FER = 1.3e-7; % per payload at 2^14 octets 
BER = 1e-12; % with FEC LDPC 14/15 in AWGN
sensorBPSK = -64; % dBm 
sensorQPSK = -67;


%% target 
Fc = 340.2e9; % channel 78
BW = 2.16e9; 
Rsymbol = 1.76e9;



%% phase error per block tracking PW
Nsym = 64; % symbols per block

maxFcError = Fc * deltaFc;      % ~20.4 MHz
minRsym = Rsymbol * (1 - deltaSym); % ~1.7599 GHz
maxPhaseErrorPW = (2*maxFcError * Nsym) / minRsym;
