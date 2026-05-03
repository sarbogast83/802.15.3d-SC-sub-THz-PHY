% steve Arbogast

% Golay hardware sim
clear; close all
%% init 
addpath("testWaveforms\")
addpath('filters\')
load('testWaveforms\TXtestSig1.mat') % this will load all need params
Rchip = 1760e6;
Tchip = 1/Rchip;
FSample = Rchip * sps;
Tsample = 1/FSample;

% golay 
N = 7 ; % 2^N = 128

%% recovery 
% RRC 
load('RRCfitler.mat')
rxReceiveMatch = conv(txSymFrameRRC,RRC.h);
% still at sps = 4

%% frame detector