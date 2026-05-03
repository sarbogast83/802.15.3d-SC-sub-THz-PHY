% steve arbogast
% test frameDetector

clear;close all
addpath('../system/helper/')
%% 
load('phyShortPreamble.mat');

sps = 4;
span = 8;
rolloff = 0.25;
RRC = rcosdesign(rolloff,span,sps,"sqrt");
RRC = RRC / sqrt(sum(RRC.^2));
RRC_delay = (length(RRC)-1)/2;
preambleUp = upsample(preambleMod,sps);
preambleRRC = conv(RRC,preambleUp); 

%% noise
CNR = 16; 
numSamples = length(preambleRRC);
ebnoLin = 10.^(CNR/10);
realNoise = randn(numSamples ,1);
imagNoise = randn(numSamples ,1);
noiseVec = realNoise + 1j*imagNoise;
noiseScaler = 1./sqrt(2*ebnoLin);
theorBER = 0.5 * erfc(sqrt(ebnoLin));
scaledNoise = noiseScaler*noiseVec;

% preambleNoisy = preambleRRC + scaledNoise;
preambleNoisy = preambleRRC; % test without noise

%% match 
preambleMatch = conv(RRC,preambleNoisy);

%% frame detecoter
detectorObj = frameDetector('sps', sps);
[coursePeakSample, coursePhaseError] = detectorObj(preambleMatch);



