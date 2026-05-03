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
GaFilter = conj(flip(GaMatch));

%% recovery 
PreUp = upsample(preambleMod,sps);
PreRRC = conv(PreUp,RRC.h);
PreMatch = conv(PreRRC,RRC.h);

% still at sps = 4

%% frame detector
detectPeaks = conv(PreMatch,GaFilter);
figure
plot(real(detectPeaks))