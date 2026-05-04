% steve Arbogast

% Golay hardware sim
clear; close all
%% init 
addpath("testWaveforms\")
addpath('filters\')
load('testWaveforms\TXtestSig1.mat') % this will load all need params
load('phyShortPreamble.mat');
Rchip = 1760e6;
Tchip = 1/Rchip;
FSample = Rchip * sps;
Tsample = 1/FSample;

%% golay 
load('RRCfitler.mat')
a128_hex = '5A5599963C33FFF00F00CCC36966AAA5';
a_bits = cell2mat(arrayfun(@(c) dec2bin(hex2dec(c), 4), a128_hex, 'UniformOutput', false)) - '0';
n = 0:length(a_bits)-1;
Ga = 2*a_bits(:) - 1;
Ga = Ga .*exp(1j*pi/2*n(:));
GaUp = upsample(Ga,sps);
GaRRC = conv(GaUp,RRC.h);
GaMatch = conv(GaRRC,RRC.h);
GaMatch = GaMatch(2*RRC.delay+1:end-2*RRC.delay);
GaFilter = conj(flip(GaMatch));

%% recovery 
CNR = 0; % dB 
PreUp = upsample(preambleMod,sps);
PreRRC = conv(PreUp,RRC.h);
noisyPre = awgnNoise(CNR,PreRRC);
PreMatch = conv(noisyPre,RRC.h);

% still at sps = 4

%% frame detector
detectPeaks = conv(PreMatch,GaFilter);
figure
plot(real(detectPeaks))


function noisySig = awgnNoise(CNR,sig)
   numSamples = length(sig);
   ebnoLin = 10.^(CNR/10);
   realNoise = randn(numSamples ,1);
   imagNoise = randn(numSamples ,1);
   noiseVec = realNoise + 1j*imagNoise;
   noiseScaler = 1./sqrt(2*ebnoLin);
   scaledNoise = noiseScaler*noiseVec;
   noisySig = sig + scaledNoise;
end